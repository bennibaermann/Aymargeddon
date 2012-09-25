#!/usr/bin/perl -w
##########################################################################
#
#   Copyright (c) 2003-2012 Aymargeddon Development Team
#
#   This file is part of "Last days of Aymargeddon" - a massive multi player
#   onine game of strategy	
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

# generell Game-specific functions
#

use strict;
use FROGS::DataBase;
use FROGS::Util;

package Game;
use Data::Dumper;

sub new{
  my ($class,$game,$user,$db) = @_;

  my $self = {};

  # create database-object, if not given with call
  if (defined $db) {
    $self->{-db} = $db;
  } else {
    $self->{-db} = DataBase->new();
  }
  # $db->set_language($lang);

  $self->{-game} = $game;
  $self->{-user} = $user;

  bless($self,$class);
}

sub insert_command{
  my ($self,$cmd,$args,$loc,$player,$exec) = @_;
  $player = $self->{-user} unless defined $player;
  my $db = $self->{-db};

  my ($now) = $db->single_select("SELECT NOW()");

  # insert MOBILE Argument in the database-field if any
  my $mobile = 0;
  if($args =~ /MOBILE\s*=\s*(\d+)/){
    $mobile = $1;
  }

  my $hash = {'GAME' => $self->{-game},
	      'SUBMIT' => $now,
	      'PLAYER' => $player,
	      'COMMAND' => $cmd,
	      'ARGUMENTS' => $args,
	      'MOBILE' => $mobile,
	     };
  if(defined $exec){
    # insert a phase-2 command
    $hash->{'EXEC'} = $exec;
    $hash->{'ACK'} = $now;
  }else{
    $hash->{'EXEC'} = $now;
  }
  $hash->{'LOCATION'} = $loc if defined $loc;
  $db->insert_hash('COMMAND',$hash);
  Util::log("command inserted: $cmd, $args, $loc, $player",1);
}

sub read_map{
  my ($self, $fields) = @_;
  # $fields should NOT be empty
  return $self->{-db}->select_array('MAP',"LOCATION,$fields","GAME=$self->{-game}");
}

#
# Message handling
#

sub read_messages{
  my ($self, $fields) = @_;
  $fields = ','.$fields if $fields;
  $fields = 'ID'.$fields;
  my $cond = "GAME=$self->{-game} AND (MTO=0 OR MTO=$self->{-user})";
  return $self->{-db}->select_array('MESSAGE', $fields, $cond, 'TIME desc');
}

# sends a raw text, if $hash is not a hash. if it is one, it generates
# a tag with arguments usable by DataBase::long_loc()
sub send_message_to{
  my($self,$user,$hash) = @_;

  $hash->{'MTO'} = $user;
  $hash->{'GAME'} = $self->{-game};

  $self->{-db}->send_message($hash);

}

sub send_message_to_me{
  my ($self,$hash) = @_;

  $self->send_message_to($self->{-user},$hash);
}

sub send_message_to_list{
  my ($self,$msg_hash,@list) = @_;

  Util::log("send_message_to_list(@list)",2);

  for my $user (@list) {
    my %copy = (%$msg_hash);
    $self->send_message_to($user,\%copy);
  }
}

sub send_message_to_all{
  my ($self,$hash) = @_;

  my @roles = $self->get_all_roles();
  $self->send_message_to_list($hash,@roles);
}

sub show_message{
  my ($self,$id) = @_;

  my ($time, $from, $text, @args) = $self->{-db}->read_message($id);

  my $other = $from;
  # lookup sender
  $from = $from == 0 ? "Server" : $self->charname($from);

  my $return = "<strong>$from $time:</strong> $text";
  $return .= ' <a href="player.epl?cmd=SEND_MSG&other='.$other
    .'">reply</a>' unless $other == 0;
  return $return;
}

sub delete_all_messages{
  my ($self,$time) = @_;
  # $::conf->{-EPL_DEBUG} = 2;
  # print "time: $time<p>";
  $self->{-db}->delete_from('MESSAGE',"GAME=$self->{-game} AND MTO=$self->{-user}".
			    " AND TIME < '$time'");
  # $::conf->{-EPL_DEBUG} = 0;
}

# send message to all players, who see this field
sub send_message_to_field{
  my($self,$loc,$hash) = @_;

  return unless $::conf->{-SEND_MESSAGE_TO_FIELD};

  my @players = $self->player_see_field($loc);
  $self->send_message_to_list($hash,@players);
}

#
# events
#

# returns a ref to a list of Event-IDs for a role
# it includes all game-events and all events on locations seen by the role
# TODO: accept additional parameter N to return the N newest events
sub role_events{
  my $self = shift;

  my $db = $self->{-db};
  my @loc = $self->seen_locations();

  my $k = $db->select_hash('EVENT','LOCATION','ID',"GAME=$self->{-game}");

  my @ret = ();
  for my $l (@loc) {
    push @ret, $k->{$l}    if (defined $k->{$l});

  }
  # print "@ret";
  return \@ret;
}
# returns a ref to a list of Event-IDs for a field
# it includes all events on locations
sub field_events{
  my ($self, $loc) = @_;
  my $db = $self->{-db};
  my $qloc = $db->quote($loc);
  return $db->select_hash('EVENT','ID',0,"GAME=$self->{-game} AND LOCATION=$qloc");
}

sub show_event{
  my ($self, $id, $show_field) = @_;

  $show_field = 1 unless defined $show_field and $show_field == 0;

  my ($from, $time, $text, @args) = $self->{-db}->read_event($id);

  # lookup sender
  if ($from != 'Game') {
    $from = '<a href ="mapframe.epl?field='.$from.'">'."$from</a>";
  }


  $time = $self->{-db}->relative($time);
  $from = "" unless $show_field;
  return "<strong>$from $time:</strong> $text";
}

sub search_event{
  my ($self,$tag,$location) = @_;

  $tag = 'EVENT_' . $tag;
  ($tag,$location) = $self->{-db}->quote_all($tag,$location);
  return $self->{-db}->single_hash_select('EVENT',"TAG=$tag and LOCATION=$location");
}

#
#
#

# Should be overloaded by derived class
sub seen_locations{
  my ($self) = @_;
  return ();
}

sub read_field{
  my ($self,$field,$loc) = @_;
  $loc = $self->{-db}->quote($loc);
  my $stmt = "SELECT $field from MAP where GAME=$self->{-game} AND LOCATION=$loc";
  return $self->{-db}->single_select($stmt);
}

sub read_player_relations{
  my ($self, $user) = @_;
  $user = $self->{-user} unless defined $user;

  # print "user: $user\n";
  my $r = $self->{-db}->select_hash('ALLIANCE', 'OTHER', 'STATUS',
				    "GAME=$self->{-game} AND PLAYER=$user");
  # print Dumper $r;
  return $r;
}

sub read_single_relation{
  my ($self,$me,$you) = @_;
  my $hash = $self->{-db}->single_hash_select('ALLIANCE',
					      "GAME=$self->{-game} AND ".
					      "PLAYER=$me AND ".
					      "OTHER=$you");
  my $ret = $hash->{'STATUS'};
  return $ret ? $ret : 'NEUTRAL';
}


sub reverse_player_relations{
  my ($self) = @_;
  return $self->{-db}->select_hash('ALLIANCE', 'PLAYER', 'STATUS',
				   "GAME=$self->{-game} AND OTHER=$self->{-user}");
}

sub read_mobile {
  my ($self,$fields,$type,$loc,$only_available) = @_;
  $only_available = 0 unless defined $only_available;
  #  print "read_mobile($fields,$type,$loc,$only_available)\n";
  my $cond = "GAME=$self->{-game} AND LOCATION=$loc";
  if ($only_available > 0) {
    $cond .= " AND AVAILABLE=Y";
  } elsif ($only_available < 0) {
    $cond .= " AND AVAILABLE=N";
  }
  $cond .= " AND TYPE=$type" if $type;
  return $self->{-db}->select_array('MOBILE', $fields, $cond);
}

sub read_mobile_condition{
  my ($self,$fields,$cond,$loc) = @_;
  $cond = "GAME=$self->{-game} AND $cond";
  $cond .= " AND LOCATION=$loc" if defined $loc;
  $self->{-db}->select_array('MOBILE',$fields,$cond);
}

# counts available mobiles of TYPE and OWNER (or all owners) in LOCATION
# TODO: we can do this in SQL with "select sum(COUNT) from MOBILE where ..."
sub count_mobile{
  my ($self,$type,$loc,$owner) = @_;

  my $mobs = $self->read_mobile('COUNT,OWNER',$type,$loc,1);
  my $count = 0;
  for my $mob (@$mobs) {
    my $nr = $mob->[0];
    if (defined $owner) {
      $count += $nr if $mob->[1] == $owner;
    } else {
      $count += $nr;
    }
  }
  return $count;
}

# count all people in $loc from $player
sub count_people{
  my($self,$loc,$player) = @_;
  $player = $self->{-user} unless defined $player;

  my $cond =  $self->{-db}->quote_condition("GAME=$self->{-game} ".
					    "AND OWNER=$player ".
					    "AND AVAILABLE=Y ".
					    "AND LOCATION=$loc");
  my $stmt = "select sum(COUNT) from MOBILE where $cond";
  my ($ret) = $self->{-db}->single_select($stmt);
  return $ret;
}
  # stupid, GAME not necessary: ID is unique between different games
sub get_mobile_info {
  my ($self, $mob_id, $fields) = @_;
  my $stmt = "SELECT $fields from MOBILE where GAME=$self->{-game} AND ID=$mob_id";
  return $self->{-db}->single_select($stmt);
}

# WARNING: in Aymargeddon, this is overloaded in Aymargeddon.pm
sub own_in_mobile{
  my($self,$loc,$player,$active) = @_;
  # $loc = $self->{-db}->quote($loc);
  my $cond = "GAME=$self->{-game} AND LOCATION=$loc".
    " AND (OWNER=$player OR ADORING=$player)";
  if (defined $active) {
    # my $y = $self->{-db}->quote('Y');
    $cond .= " AND AVAILABLE=Y";
  }
  return $self->{-db}->select_array('MOBILE','ID',$cond);
}

sub read_role{
  my ($self,$player,$field) = @_;
  my $stmt = "SELECT $field from ROLE where GAME=$self->{-game} AND PLAYER=$player";
  return $self->{-db}->single_select($stmt);
}

sub get_all_roles{
  my ($self,$role) = @_;

  my $cond = "GAME=$self->{-game}";
  if (defined $role) {
    # $role = $self->{-db}->quote($role);
    $cond .= " AND ROLE=$role";
  }
  my @roles = @{$self->{-db}->select_array('ROLE','PLAYER',$cond)};
  for my $i (0..$#roles) {
    $roles[$i] = $roles[$i]->[0];
  }
  return @roles;
}

sub get_speed {
  my $self = shift;
  my ($ret,$run) =  $self->{-db}->single_select("select SPEED, RUNNING from GAME".
						" where GAME = $self->{-game} ");
  return $run eq 'Y' ? $ret : - $ret;
}

sub charname{
  my ($self,$player,$do) = @_;
  return $self->{-db}->loc('UNASSIGNED') if $player < 1;
  my @list = $self->read_role($player, 'NICKNAME');
  return $list[0];
}

sub role{
  my ($self,$player) = @_;
  return 'OBSERVER' if $player < 1;
  my @role = $self->read_role($player, 'ROLE');
  return $role[0];
}

1;
