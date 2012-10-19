##########################################################################
#
#   Copyright (c) 2003-2012 Aymargeddon Development Team
#
#   This file is part of "Last days of Aymargeddon" - a massive multi player
#   online game of strategy	
#   
#        This program is free software: you can redistribute it and/or modify
#	 it under the terms of the GNU Affero General Public License as
#        published by the Free Software Foundation, either version 3 of the
#	 License, or (at your option) any later version.
#    
#        This program is distributed in the hope that it will be useful,
#	 but WITHOUT ANY WARRANTY; without even the implied warranty of
#	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#    See the GNU Affero General Public License for more details.
#    
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#    
###########################################################################
#

#
#  basic command object used by the scheduler
use strict;
use Date::Parse qw(str2time);
use Date::Calc qw(Time_to_Date);
use FROGS::DataBase;
use FROGS::Config qw ($conf);
require "$::conf->{-GAME_NAME}.pm";

package Command;
use Data::Dumper;

sub new {
  my ($type, $dbhash, $dbobj)  = @_;

  Util::log("$type->new()",2);

  my $self = {-dbhash => $dbhash,
	      -db => $dbobj,
	      -player => $dbhash->{'PLAYER'},
	      -game => $dbhash->{'GAME'},
	      -id => $dbhash->{'ID'},
	      -location => $dbhash->{'LOCATION'},
	      -class => $type,
	     };
  bless( $self, $type );

  # create an GAME_NAME context object
  $self->{-context} = $::conf->{-GAME_NAME}->new($dbhash->{'GAME'},
						 $dbhash->{'PLAYER'},
						 $dbobj);

  $self->{-speed} = $self->{-context}->get_speed();

  # end of the game?
  if($self->{-speed} < 0){
    Util::log("Game over, no commands anymore!",1);
    $self->done();
    return 0;
  }

  # set language according to PLAYER.LANGUAGE
  my ($lang) = $dbobj->read_player($self->{-player},'LANGUAGE');
  $dbobj->set_language($lang);

  $self->{-args} = $self->parse_args( $self->{-dbhash}->{'ARGUMENTS'} );

  if (defined  $self->{-dbhash}->{'ACK'} and
      $self->{-dbhash}->{'ACK'} ne '0000-00-00 00:00:00'){
    $self->{-phase} = 2;
  }else{
    $self->{-phase} = 1;
    $self->{-duration} = $::conf->{-DURATION}->{"-$type"} || 0;
  }

  if(not $::conf->{-MESSAGE_IN_LOG} and $type eq 'SEND_MSG'){
    Util::log('',1);
  }else{
    my $logstring = "\nCommand $type (ID: $self->{-dbhash}->{'ID'}): ".
      "Phase $self->{-phase}, ".
	"Player $self->{-dbhash}->{'PLAYER'}, ".
	  "Game $self->{-dbhash}->{'GAME'}, ".
	    "Arguments $self->{-dbhash}->{'ARGUMENTS'}";
    $logstring .= ", Location $self->{-dbhash}->{'LOCATION'}, "
      if defined $self->{-dbhash}->{'LOCATION'};
    Util::log($logstring,1);
  }

  return $self;
}

sub is_valid {
  my ($self, @required_args) = @_;

  # all arguments avaiable?
  # TODO PERFORMANCE: maybe this check only in phase1?
  return 0 unless $self->required_args($self->{-args}, @required_args);

  # does the player still exists?
  if($self->{-player} == -1){
    $self->{-role} = $self->{-context}->charname(-1);
  }else{
    my ($id,$role) = $self->{-context}->read_role($self->{-player},'PLAYER,ROLE');
    if($id != $self->{-player}){
      Util::log("COMMAND->is_valid: Player $self->{-player} does not exist!\n",0);
      return 0;
    }
    # set role for later use
    # print "ROLE(is_valid): $role\n";
    $self->{-role} = $role;
  }
  return 1;
}

sub isSecond {
	my $self = shift;
	return 2 == $self->{-phase};
}

sub isFirst {
	my $self = shift;
	return 1 == $self->{-phase};
}

sub execute {
  my $self = shift;
  my $db=$self->{-db};

  #if($self->{-speed} < 0){
  #  Util::log('*',-1);
  #  $self->done();
  #  return;
  #}
  # determine phase of command and do it.
  if ($self->isFirst() ) {
    $db->update_hash("COMMAND","ID = $self->{-dbhash}->{'ID'}",{ 'ACK' => $db->now() });
    my $ret = $self->first_phase();

    if ($self->getDuration() > 0 and $ret > 0) {
      my $exec = $self->getPhase2exec();
      if($self->{-end_of_game}){
	$self->done();
      }else{
	$db->update_hash("COMMAND",
			 "ID = $self->{-dbhash}->{'ID'}",
			 { 'EXEC' => $exec });
      }
    }elsif ($self->getDuration() == 0 or $ret == 0){
      $self->done();
    } else {
      # in this case the command has set its EXEC by itself. we do nothing
      $self->done() if $self->{-end_of_game};
    }		
  } elsif ($self->isSecond() ) {
    $self->second_phase();
    $self->done();
  } else {
    Util::log("command->execute ($self->{-class}) : Unknown or undefined Command phase",0);
    die;
  }
}

sub done {
# a command will use this func to declare it's terminated
# it is called by Scheduler after secondPhase anyway, so a
# command has to use it only explicitley in a member if it wants to
# terminate NOW! (but still have to exit action for itself)
  my $self = shift;
  my $db=$self->{-db};

  my $id = $self->{-id};

  $db->update_hash("COMMAND","ID = $id",{ 'DONE' => $db->now() });
  if ($::conf->{-DEBUG} == 0 or $::conf->{-DELETE_OLD_COMMANDS}) {
    $db->delete_from("COMMAND","ID=$id");
    Util::log(ref($self)."-Command $id deleted.",1);
    # TODO: dont delete PRODUCE-Command if game not runnning, but waiting
  }
  # TODO?: send messages
}

sub setDuration {
# sets the duration of the command in units. Sheduler will schedule
# the Phase 2 then for gametime+units*pace(game).
# this function will have to be called explicitely during phase 1 by the
# implementation of the command
# If it is not called at least once (or set to 0), Scheduler will assume the command has
# no second phase and will call done() after completion of firstPhase().
	my $self = shift;
	$self->{-duration} = shift;
}

sub getDuration {
# get command duration in units
	my $self = shift;
	return $self->{-duration};
}

sub getDurationInSec{
# get command duration in secs according to the *current* gamespeed
	my $self = shift;

	my $ret = $self->getDuration() *  $self->{-speed};	
	
	Util::log("Duration in sec: $ret",1) unless defined $self->{-duration_logged};
	$self->{-duration_logged} = 1;

	$self->{-end_of_game} = 1 unless $ret >= 0;
	return $ret;
}

sub getPhase2exec {
	# only valid during phase 1 returns start of phase 2 in game
	# time, GMT (YYYY-MM-DD HH:MM:SS). If Duration wasn't set, or
	# phase is wrong it returns undef.
	my $self = shift;
	if ($self->getDuration() == 0 || $self->isSecond() ) {
		return undef;
	}
	my $firstExecTimeUnix = &::str2time($self->{-dbhash}->{'EXEC'},'GMT');
#	my $firstExecTimeUnix = &::str2time($self->{-dbhash}->{'EXEC'});
	$firstExecTimeUnix += $self->getDurationInSec();
	my ($year,$month,$day, $hour,$min,$sec) = &::Time_to_Date($firstExecTimeUnix);
	return  sprintf ("%04u-%02u-%02u %02u:%02u:%02u",$year,$month,$day, $hour,$min,$sec);
}


#############################################
#
# Tools to be used by concrete commands
#

# TODO: Bug mit messages
sub parse_args {
	my ( $self, $arg_string ) = @_;

	my @key_value_pairs = split /,/, $arg_string; # TODO: wrong for messages

	# remove leading/trailing whitespace
	@key_value_pairs = map { $_ =~ s/^\s*(\S*)\s*$/$1/; $_ } @key_value_pairs;

	my %hash;
	for my $kv (@key_value_pairs) {
		my ( $k, $v ) = split /=/, $kv; # TODO: wrong for messages

		# remove leading/trailing whitespace again
		( $k, $v ) = map { $_ =~ s/^\s*(\S*)\s*$/$1/; $_ } ( $k, $v );

		$hash{$k} = $v;
	}
	# use Data::Dumper; print Dumper \%hash;
	return \%hash;
}

sub required_args {
  my ( $self, $args, @ra ) = @_;

  for my $a (@ra) {
    unless ( exists $args->{$a} ) {
      Util::log("We need argument $a",1);
      return 0;
    }
  }
  return 1;
}



# general testfunction.
# sends error message and return false
# unless &$cond() gives true

sub test{
  my ($self, $cond, $tag, @args) = @_;

  unless(&$cond()){
    # (@args) = $self->{-db}->quote_all(@args);

    my $sendhash = {'MFROM' => 0,
		    'MSG_TAG' => $tag};
    # TODO: localize command-strings!
    $sendhash->{'ARG1'} = $self->{-class};
    for my $a (1..($#args+1)){
      $sendhash->{"ARG$a"} = $args[$a-1];
    }

    $self->{-context}->send_message_to($self->{-player},$sendhash);

    Util::log("Test failed: $tag, args @args",1);

    return 0;
  }
  return 1;
}

#sub test{
#  my ($self, @all) = @_;
#
#  if($self->test_without_done(@all)){
#    return 1;
#  }else{
#    # delete me from database
#    $self->done();
#    return 0;
#  }
#}

# set a mobilehash if available, sends errormessage otherwise
sub validate_mobile{
  my ($self,$mob_id) = @_;

  my $mob = $self->{-db}->read_single_mobile($mob_id);

  # mobile correct?
  if($self->{-phase} == 1){
    return 0 unless $self->test(sub {defined $mob},
				'MSG_NO_SUCH_MOBILE',
				$mob_id);
  }
  $self->{-mob} = $mob;
  return 1;
}

# errormessage unless one of valid roles
sub validate_role{
  my ($self, @valid_roles) = @_;

  return 1 if $self->{-player} < 0;

  Util::log("validate_role($self->{-role})",2);

  unless(Util::is_in($self->{-role},@valid_roles)){
    return 0 unless $self->test(sub {0},
				'MSG_ROLE_CANT_DO',
				$self->{-role},
				ref($self));
  }
  return 1;
}

sub validate_this_role{
  my($self,$player,@valid_roles) = @_;

  # fake identity
  my $role = $self->{-role};
  my ($id,$r) = $self->{-context}->read_role($player,'PLAYER,ROLE');
  $self->{-role} = $r;
  my $ret = $self->validate_role(@valid_roles);
  $self->{-role} = $role;
  return 0 unless $ret;
  return 1;
}

# takes a mobile_hash, a count and a diff_hash. creates another mobile
# with count members in the database with the different fields given
# in diff_hash. if $available, than the new mob is available

#  returns
# ID of newmob (newmob is in some sense really the old mob, because
# diff is apllied to old mob) , returns the new ID (of the old mob).

sub split_mobile{
  my ($self, $mob, $count, $diff, $available) = @_;
  my $db = $self->{-db};
  Util::log(ref($self).": split mobile $mob->{'ID'}",1);

  # create new mobile
  my %newmob = %$mob;
  my $newmob = \%newmob;
  $newmob->{'ID'} = $self->{-db}->find_first_free('MOBILE','ID');
  my $newid = $newmob->{'ID'};

  %$mob = (%$mob,%$diff);
  # print Dumper $mob; exit;
  # %$newmob = (%$oldmob, %$newmob);

  # calculate new count and available
  $mob->{'COUNT'} = $count;
  $mob->{'AVAILABLE'} = $available ? 'Y' : 'N';

  my $id = $mob->{'ID'};
  delete $mob->{'ID'};
  # print Dumper $mob;
  $self->{-db}->update_hash('MOBILE',"ID=$id",$mob);
  Util::log("mobile $id updated",1);

  # reduce count of old one
  $newmob->{'COUNT'} -= $count;

  # print Dumper $newmob;
  $self->{-db}->insert_hash('MOBILE',$newmob);
  Util::log("new mobile $newid",1);

  return $newid;
}

# this function splits a mobile if it necessary, update else.
# usage of parameters: see split_mobile
# returns the new ID of the old mob (see split_mobile)
sub conditional_split_mobile{
  my ($self, $mob, $count, $diff, $available) = @_;

  # print "count: $count\n";
  # print Dumper $mob;

  my $db = $self->{-db};

  # split it, if neccessary
  if($count < $mob->{'COUNT'}){

    return $self->split_mobile($mob,$count,$diff,$available);

  }elsif($count == $mob->{'COUNT'}){
    $diff->{'AVAILABLE'} = $available ? 'Y' : 'N';
    $db->update_hash('MOBILE',
		     "ID=$mob->{'ID'}",
		     $diff);
    return $mob->{'ID'};
  }else{
    Util::log("SPLIT MOBILE: Error! impossible case. not enough mobiles. ".
	      "we need $count and have only $mob->{'COUNT'}",0);
    return 0;
  }
}

sub event{
  my ($self, $loc, $tag, @args) = @_;

  # read execution time
  my $exec_time = $self->getPhase2exec();

  unless($exec_time){
    my $cmd = $self->{-db}->single_hash_select('COMMAND',
					       "ID=$self->{-dbhash}->{'ID'}");
    $exec_time = $cmd->{'EXEC'};
  }

  my $event = {'TAG' => $tag,
	       'LOCATION' => $loc,
	       'GAME' => $self->{-game},
	       'TIME' => $exec_time,
	       'COMMAND_ID' => $self->{-dbhash}->{'ID'},
	       };
  $event->{'ARG1'} = $self->{-context}->charname($self->{-player});
  for my $a (0..$#args){
    $event->{'ARG'.($a+2)} = $args[$a];
  }
  $self->{-db}->write_event($event);
}

# this function re-inserts the same command in the queue again
sub do_it_again{
  my ($self,$arguments) = @_;

  my $now = $self->{-db}->now();
  # we need a new ID
  delete $self->{-dbhash}->{'ID'};
  # reset timestamps
  $self->{-dbhash}->{'SUBMIT'} = $now;
  $self->{-dbhash}->{'EXEC'} = $now;
  $self->{-dbhash}->{'ACK'} = 'NULL'; # TODO: wrong way to insert NULL?
  $self->{-dbhash}->{'DONE'} = 'NULL';
  if (defined $arguments){
    # these arguments are allready there in the database
    my $hash = $self->parse_args($self->{-dbhash}->{'ARGUMENTS'});
    # we put some additional ones into hash
    for my $k (keys %$arguments){
      $hash->{$k} = $arguments->{$k};
    }
    # rearrange hash into string
    my $new_string = '';
    my ($key,$value);
    while (($key,$value) = each %$hash){
      $new_string .= "$key=$value, ";
    }
    $new_string =~ s/, $//;
    $self->{-dbhash}->{'ARGUMENTS'} = $new_string;
  }
  # write new command to database
  $self->{-db}->insert_hash('COMMAND', $self->{-dbhash});
}

1;
