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

#
#  Aymargeddon specific command clsses used by the scheduler
#  generic FROGS-Command is in FROGS/Command.pm
#

use strict;
use FROGS::Util;
use FROGS::HexTorus;
use Data::Dumper;

##########################################################
#
# Base Class for Aymargeddon specific commands
#

package AymCommand;
use Data::Dumper;
@AymCommand::ISA = qw(Command);

sub end_of_the_game{
  my $self = shift;

  $self->{-context}->send_message_to_all({'MFROM' => 0,
					  'MSG_TAG' => 'END_OF_GAME'});

  Util::log("*****************************\n" .
	    "***    End of the Game!   ***\n" .
	    "*****************************",0);

  $self->{-db}->update_hash('GAME',
			    "GAME=$self->{-game}",
			    {'RUNNING' => 'N'});

}

# just a wrapper
sub avatar_available{
  my ($self,$loc,$god) = @_;
  $god = $self->{-player} unless defined $god;
  return $self->{-context}->avatar_available($loc,$god,$self->{-class});
}

# just another wrapper
sub get_neighbours{
  my ($self,$loc) = @_;
  $loc = $self->{-dbhash}->{'LOCATION'} unless defined $loc;

  my $map = HexTorus->new($self->{-context}->get_size());
  my $location = Location->from_string($loc);
  my @neighbours = $map->neighbours($location);
  return map {$_ = $_->to_string();} @neighbours;
}

# FIGHT_EARTHLING and Pestilenz
sub casualties{
  my ($self,$victim,$death_count,$no_conquer) = @_;
  $self->{-looser} = $victim unless defined $self->{-looser};
  my $other;
  unless(defined $no_conquer){
    $other = ($victim != $self->{-winner}) ? $self->{-winner} : $self->{-looser};
  }

  Util::log("death_count for $victim: $death_count",1);

  $self->{-dead}->{$victim} = {'A' => 0,
			       'H' => 0,
			       'P' => 0,
			       'K' => 0,
			       'C' => 0}; # conquered arks

  return unless $death_count;

  my $dying = $::conf->{-DEFAULT_DYING};
  unless($self->{-looser} < 0){
    my $earthling = $self->{-db}->single_hash_select('EARTHLING',
						     "PLAYER=$self->{-looser} AND ".
						     "GAME=$self->{-game}");
     $dying = $earthling->{'DYING'};
  }
  $dying .= 'A';
  my $big_dying = {'P' => 'PRIEST',
		   'K' => 'WARRIOR',
		   'H' => 'HERO',
		   'A' => 'ARK'};

  # print Dumper $dying;

  # rearrange mobiles in a hash
  # TODO PERFORMANCE,DESIGN: we should have read $self->{-mobiles}
  #      as a hash from database earlier, should be better in all cases.
  my %victims_mobiles = ();
  for my $mob (@{$self->{-mobiles}}){
    my ($id,$type,$own,$count,$stat) = @$mob;
    next unless $own == $victim;
    $victims_mobiles{$id} = $mob;
  }

  # print Dumper \%victims_mobiles;

  my ($row, $carry, $share, $conquered_arks) = (0,0,0,0);
  my $to_kill = $death_count;
  my @small_dying = split //,$dying;
  while(int($to_kill) > 0 and %victims_mobiles){
    my $small_dying = $small_dying[$row];
    #    for my $small_dying (split //,$dying){
    $carry += $death_count * $::conf->{-DEATH_SHARE_ROW}->[$row];
    $share = int($carry);
    $carry -= $share;
    $share = $to_kill if($share > $to_kill);

    Util::log("type: $small_dying, share: $share, carry: $carry, to_kill: $to_kill",2);

    while( my ($key,$value) = each %victims_mobiles){
      my ($id,$type,$own,$count,$stat) = @$value;
      # next unless $own == $victim;
      next unless $type eq $big_dying->{$small_dying};
      Util::log("id: $id, count: $count, share: $share, ".
		"carry: $carry, to_kill: $to_kill",2);

      my $dead_men = Util::min($count,$share);
      $self->{-dead}->{$victim}->{$small_dying} += $dead_men;
      if($small_dying eq 'H'){
	# dead heros fights for gods in last battle
	my ($god) = $self->{-context}->get_mobile_info($id,'ADORING');
	Util::log("adored god: $god",1);
	my ($actual) = $self->{-db}->single_select("SELECT DEATH_HERO FROM GOD WHERE ".
						   "GAME=$self->{-game} AND ".
						   "PLAYER=$god");
	Util::log("HERO dying: adds $dead_men heros ".
		  "to last-battle-strength of $god",1);
	$self->{-db}->update_hash('GOD',
				  "GAME=$self->{-game} AND PLAYER=$god",
				  {'DEATH_HERO' => $actual + $dead_men});
      }elsif($small_dying eq 'A' and $victim == $self->{-looser} 
	     and not defined $no_conquer){
	# special case ark (can change owner)
	my $random_value = rand($dead_men);
	Util::log("random value of $dead_men: $random_value",1);
	$conquered_arks = int($random_value+0.5);
	# $dead_men -= $conquered_arks;
	Util::log("ark in battle: $conquered_arks change owner to $other, ".
		  "$dead_men arks sinking or conquered.",1);
	$self->{-dead}->{$victim}->{'C'} += $conquered_arks;
      }

      if($count > $dead_men){
	my $new_count = $count - $dead_men;
	$self->{-db}->update_hash('MOBILE',
				  "ID=$id",
				  {'COUNT' => $new_count});
	$victims_mobiles{$id}->[3] = $new_count;
	Util::log("Mobile $id ($small_dying) looses $dead_men people ".
		  "and have now $new_count.",1);
	$to_kill -= $dead_men;
	last;
      }else{
	$share -= $count;
	$to_kill -= $count;
	$self->{-db}->delete_from('MOBILE',"ID=$id");
	$self->{-db}->update_hash('MOBILE',
				  "MOVE_WITH=$id",
				  {'MOVE_WITH' => 0});
	Util::log("Mobile $id ($small_dying) with $dead_men people is deleted",1);
	delete $victims_mobiles{$id};
      }
    }

    $carry += $share;
    $row = ($row + 1)%4;
  }

  unless(defined $no_conquer){
    my $total_conquered_arks = $self->{-dead}->{$victim}->{'C'};
    if($total_conquered_arks){
      # now conquered arks are (re-)created
      my $mob = {'ID' => $self->{-db}->find_first_free('MOBILE','ID'),
		 'GAME' => $self->{-game},
		 'LOCATION' => $self->{-location},
		 'TYPE' => 'ARK',
		 'OWNER' => $self->{-winner},
		 'COUNT' => $self->{-dead}->{$victim}->{'C'},
		 'AVAILABLE' => 'Y',
		 'COMMAND_ID' => $self->{-id},
		};
      $self->{-mob} = $mob;
      my %mobcopy = (%$mob);
      $self->{-db}->insert_hash('MOBILE',\%mobcopy);
      $self->unify_mobiles($mob,$self->{-location},$self->{-winner});
      Util::log("$total_conquered_arks conquered arks for $self->{-winner}.",1);
      $self->{-dead}->{$victim}->{'A'} -= $total_conquered_arks;
    }
  }

  $self->change_priest_on_temple($self->{-location});
}

sub move_with{
  my ($self,$id,$target,$count) = @_;

  # read mobile
  my $mobile = $self->{-db}->single_hash_select('MOBILE',"ID=$id");

  # split mobile
  $self->conditional_split_mobile($mobile,$count,
				  {'MOVE_WITH' => $target},1);
  Util::log("$count mobiles from id $id now moves with mobile $target",1);

  # reread mobile, because split destroys it
  $mobile = $self->{-db}->single_hash_select('MOBILE',"ID=$id");

  # all mobiles which already move with this now move with the target
  if($target != 0){
    my $mob = $self->{-context}->mobiles_available($mobile->{'LOCATION'});
    # my $mobcount = $#{@$mob}+1;
    my $mobcount = @$mob;
    for my $i (0..$mobcount-1){
      my ($oid,$otype,$oown,$oado,$ocnt,$ostat,$omove) = @{$mob->[$i]};
      next if($omove != $id);
      $self->{-db}->update_hash('MOBILE',"ID=$oid",
				{'MOVE_WITH' => $target});
      Util::log("therefor all mobiles from id $oid now moves with mobile $target",1);
    }
  }

  # unify
  $self->unify_mobiles($mobile,$mobile->{'LOCATION'});
}

# this function is called, if an earthling leave an field and let it possible empty
sub empty_field{
  my ($self,$loc,$player) = @_;
  $player = $self->{-player} unless defined $player;
  my $db = $self->{-db};
  my $aym = $self->{-context};
  my $oim = $aym->own_in_mobile($loc,$player,1);

  my ($home,$ter,$occ,$temple) =
    $aym->read_field('HOME,TERRAIN,OCCUPANT,TEMPLE',$loc);
  $home=0 if $ter eq 'MOUNTAIN';

  unless(@$oim){
    my $keep_owner = 0;
    $keep_owner = 1 if $home==$occ and $ter eq 'CITY' and $::conf->{-HOMECITY_KEEP_OWNER};
    $keep_owner = 1 if exists $::conf->{-KEEP_OWNER}->{$ter};
    $keep_owner = 1 if $::conf->{-TEMPLE_KEEP_OWNER} and $temple eq 'Y';

    if($keep_owner){
      Util::log("leaving occupant $occ in field $loc",1);
    }else{
      Util::log("reset old occupant $home in field $loc.",1);
      # delete all PRODUCE and PRAY-Commands if any
      $self->{-db}->delete_from('COMMAND',
				"(COMMAND=PRODUCE OR COMMAND=PRAY) AND ".
				"LOCATION=$loc AND GAME=$self->{-game}");
      # delete all PRODUCE-EVENTS
      $self->{-db}->delete_from('EVENT',
				"(TAG=EVENT_PRODUCE_WARRIOR OR TAG=EVENT_PRODUCE_PRIEST)".
				" AND LOCATION=$loc AND GAME=$self->{-game}");
      $db->update_hash('MAP',
		       "LOCATION=$loc AND GAME=$self->{-game}",
		       {'OCCUPANT' => $home});
    }
  }
  $self->change_priest_on_temple($loc);
}

# this check, if there is still a priest on a temple
# and if there is a new priest on temple
sub change_priest_on_temple{
  my ($self,$loc) = @_;
  my $aym = $self->{-context};

  my ($home,$temple,$occ) = $aym->read_field('HOME,TEMPLE,OCCUPANT',$loc);
  return unless $temple eq 'Y';

  my $produce = $self->{-db}->count('COMMAND',
				    "LOCATION=$loc AND GAME=$self->{-game} AND ".
				    "COMMAND=PRODUCE");

  my $priests = $self->{-db}->count('MOBILE',
				    "LOCATION=$loc AND GAME=$self->{-game} AND ".
				    "TYPE=PRIEST AND ADORING=$home AND ".
				    "AVAILABLE=Y");

  Util::log("priests: $priests, produce: $produce",1);

  if($priests and not $produce){
    $aym->insert_command('PRODUCE', "ROLE=$occ", $loc);
  }

  if(not $priests and $produce){
    Util::log("delete produce-command and event",1);
    # delete all PRODUCE -Commands if any
    $self->{-db}->delete_from('COMMAND',
			      "COMMAND=PRODUCE AND ".
			      "LOCATION=$loc AND GAME=$self->{-game}");
    # delete all PRODUCE-EVENTS
    $self->{-db}->delete_from('EVENT',
			      "(TAG=EVENT_PRODUCE_PRIEST)".
			      " AND LOCATION=$loc AND GAME=$self->{-game}");
  }
}

# do we fight? do we conquer? do we join?
# TODO: turn_around if no ark and terrain==water
# TODO:   could happen if location is flooded during movement.
sub enter_field{
  my ($self,$loc,$ignore_friend) = @_;
  $ignore_friend = 0 unless defined $ignore_friend;

  Util::log("enter_field($loc,$ignore_friend)",2);

  # print "LOC: $loc\n";
  my ($occ,$att,$temple,$home,$terrain) = 
    $self->{-context}->read_field('OCCUPANT,ATTACKER,TEMPLE,HOME,TERRAIN',$loc);
  $self->{-occupant} = $occ;

  my $relation = $self->{-context}->get_relation($occ);

  $relation = 'FOE' if $ignore_friend;

  # if there is allready an ongoing fight
  if($att){
    # do nothing if we are allready involved
    if($self->{-player} == $occ or $self->{-player} == $att){

      Util::log("join the ongoing fight in $loc",1);
      delete $self->{-multimove};
      return;
    }else{
      # turn around otherwise
      Util::log("in $loc: There is allready a fight between $occ and $att ".
		"... turn around.",1);
      $self->turn_around($loc);
      delete $self->{-multimove};
      return;
    }
  }

  if($relation eq 'FRIEND' or $relation eq 'ALLIED'){
    # a friend has allready occupied this place, just turn around.
    Util::log("in $loc: $occ is a friend of $self->{-player} ... turn around.",1);
    $self->turn_around($loc);
    delete $self->{-multimove};
    return;
  }

  if($self->is_new_earthling_fight($loc,$relation,$terrain)){
    Util::log("new fight between earthlings in $loc:".
	      " attacker $self->{-player}, defender $occ",1);

    # we are the attacker
    $self->do_earthling_fight($loc);
    delete $self->{-multimove};
    return;
  }

  if($occ == $self->{-player}){
    # was already our field
    Util::log("$loc is allready field of $occ.",2);
    $self->unify_mobiles($self->{-mob},$loc) unless defined $self->{-multimove};
  }else{
    # we are the new occupant
    $self->conquer($loc,$self->{-player});
  }

  $self->change_priest_on_temple($loc);
}

# peoples without arks drown
sub drowning{
  my ($self,$loc) = @_;

  # dont drown on islands or land
  my ($terrain) = $self->{-context}->read_field('TERRAIN',$loc);
  return unless $terrain eq 'WATER';

  # is there still an active ark?
  my $arks = $self->{-context}->read_mobile('TYPE','ARK',$loc,1);
  # print Dumper $arks;
  my @aa = @$arks;
  return if $#aa >= 0;

  # get active mobiles
  my $mobs = $self->{-context}->read_mobile('ID,TYPE,COUNT,OWNER','',$loc,1);

  my ($id,$type,$count,$owner);
  for my $mob (@$mobs){
    ($id,$type,$count,$owner) = @$mob;

    next if $type eq 'ARK' or $type eq 'PROPHET';

    # drown mobile
    $self->{-db}->delete_from('MOBILE',"ID=$id");
    Util::log("No ark: $count $type from $owner drowned in $loc.",1);

    $self->{-context}
      ->send_message_to($owner,
			{'MFROM' => 0,
			 'MSG_TAG' => 'MSG_MOBILE_DRAWN',
			 'ARG1' => $count,
			 'ARG2' => $self->{-context}->mobile_string($type,$count),
			 'ARG3' => $self->{-context}->charname($owner),
			 'ARG4' => $loc});
  }
  $self->empty_field($loc,$owner) if $owner;
}

sub conquer{
  my ($self,$loc,$player) = @_;

  Util::log("$player conquers $loc.",1);
  $self->{-db}->update_hash('MAP',"LOCATION=$loc AND GAME=$self->{-game}",
			    {'OCCUPANT' => $player});

  # conquer existing arks
  $self->{-db}->update_hash('MOBILE',"LOCATION=$loc AND GAME=$self->{-game} AND TYPE=ARK",
			    {'OWNER' => $player});

  # insert new PRODUCE-command and delete existent one and PRODUCE-events
  my ($terrain,$temple,$home) = $self->{-context}->read_field('TERRAIN,TEMPLE,HOME',$loc);

  if ((not $home and $terrain eq 'CITY')){
    $self->{-db}->delete_from('COMMAND', "COMMAND=PRODUCE AND LOCATION=$loc".
			     " AND GAME=$self->{-game}");
    $self->{-db}->delete_from('EVENT',"TAG=EVENT_PRODUCE_WARRIOR AND LOCATION=$loc ".
			      "AND GAME=$self->{-game}");
    $self->{-context}->insert_command('PRODUCE', "ROLE=$player", $loc);
  }

  #if ($temple eq 'Y'){
    # PRAY at temples
  #  $self->{-db}->delete_from('COMMAND', "COMMAND=PRAY AND LOCATION=$loc".
  #" AND GAME=$self->{-game}");
  #
  # }
}

sub enter_field_avatar{
  my ($self,$loc,$mob) = @_;

  Util::log("enter_field_avatar() in $loc",1);
  # print Dumper $mob;

  # if we are in Aymargeddon, do nothing special
  my ($terrain) = $self->{-context}->read_field('TERRAIN',$loc);
  if($terrain eq 'AYMARGEDDON'){
    Util::log("enter_field_avatar(AYMARGEDDON): do nothing",1);
    delete $self->{-multimove};
    return;
  }

  # mob can be ID or hash
  $mob = $self->{-db}->read_single_mobile($mob) unless ref($mob);
  # print Dumper $mob;
  # get all avatars allready here from me and other owners
  my $avatars = $self->{-context}->read_mobile_condition('ID,OWNER,STATUS',
							 "LOCATION=$loc ".
							 "AND TYPE=AVATAR ".
							 "AND AVAILABLE=Y");
  # print Dumper $avatars;

  # restructure data
  my $own_avatars_here = 0;
  my $own_avatar_status = 'IGNORE';
  my %other_avatar_owner = ();
  my %other_avatar_status = ();
  for my $a (@$avatars){
    my ($id,$own,$stat) = @$a;
    next if($id == $mob->{'ID'});
    # print "own: $own\n";
    if($own == $mob->{'OWNER'}){
      $own_avatars_here = $id;
      $own_avatar_status = $stat;
    }elsif(!defined $other_avatar_owner{$own}){
      $other_avatar_owner{$own} = 1;
      $other_avatar_status{$own} = $stat;
      Util::log("found other avatar-owner $own in $loc",1);
    }else{
      Util::log("other avatar-owner $own allready found in $loc",1);
    }
  }

  # if we are there allready with other avatars:
  if($own_avatars_here){
    # set STATUS of newcomer to the STATUS in the field
    if ($own_avatar_status ne $mob->{'STATUS'}){
      $self->{-db}->update_hash('MOBILE',
				"ID=$mob->{'ID'}",
				{'STATUS' => $own_avatar_status});
    }
    Util::log("enter_field_avatar():Avatars (ID:$mob->{'ID'}) ".
	      "have to join other avatars with status $own_avatar_status in $loc.",1);
    $self->unify_mobiles($mob);
  }else{
    #   for each other avatar-owner
    for my $other (keys %other_avatar_owner){
      my $oas = $other_avatar_status{$other};
      # read alliance to each other owner (and vice versa)
      my $allianceA = $self->{-context}
	->simplyfied_single_relation($other,$mob->{'OWNER'});
      my $allianceB = $self->{-context}
	->simplyfied_single_relation($mob->{'OWNER'},$other);
      # insert FIGHT-command, if necessary
      if($self->is_avatar_fight($allianceA,$allianceB,$mob->{'STATUS'},$oas)){
	$self->{-context}->insert_command('FIGHT_GOD',
					  "A=$other, B=$mob->{'OWNER'}",
					  $loc);
	Util::log("enter_field_avatar():Avatars from $mob->{'OWNER'} ".
		  "have to fight with $other in $loc.",1);
	delete $self->{-multimove};
      }
    }
  }
}

sub is_avatar_fight{
  my ($self,$allA,$allB,$statA,$statB) = @_;

  Util::log("is_avatar_fight(): ".
	    "allA: $allA, allB: $allB, statA: $statA, statB: $statB",1);

  return 0 unless $statA eq 'BLOCK' or $statB eq 'BLOCK';
  my $status = 'NEUTRAL';
  if(($allA eq 'FOE') or ($allB eq 'FOE')){
    $status = 'FOE';
  }elsif(($allA eq 'FRIEND') or ($allB eq 'FRIEND')){
    $status = 'FRIEND';
  }

  return 1 if ($status eq 'FOE');
  return 1 if ($status eq 'NEUTRAL') and $statA eq 'BLOCK' and $statB eq 'BLOCK';
  return 0;
}

# unify identical mobiles
# $mob still exists after function. all other of same
# TYPE, MOVE_WITH, ADORING will be deleted.
sub unify_mobiles{
  my ($self,$mob,$location,$owner) = @_;

  # mob can be ID or hash
  $mob = $self->{-db}->read_single_mobile($mob) unless ref($mob);

  $location = $mob->{'LOCATION'} unless defined $location;
  $owner = $self->{-player} unless defined $owner;

  Util::log("unify_mobiles() in $location for mobile $mob->{'ID'} of $owner",1);

  return if $self->{-db}->count('COMMAND',
				"MOBILE=$mob->{'ID'} AND ID != $self->{-dbhash}->{'ID'}");

  my $type = $mob->{'TYPE'};

  my $mobs = $self->{-context}->read_mobile('ID,COUNT,ADORING,OWNER,MOVE_WITH',
					    $type,
					    # $mob->{'LOCATION'},
					    $location,
					    1
					   );

  my $count = $mob->{'COUNT'};
  for my $m (@$mobs){
    my ($oid,$ocount,$oado,$oown,$omove) = @$m;

    next if $oown ne $owner; # and $type ne 'ARK';
    next if $oid eq $mob->{'ID'};
    if(Util::is_in($type,'PRIEST','PROPHET','HERO')){
      next if $oado ne $mob->{'ADORING'};
    }

    next if(defined $mob->{'MOVE_WITH'} and $mob->{'MOVE_WITH'} ne $omove);

    next if $self->{-db}->count('COMMAND',"MOBILE=$oid");

    $count += $ocount;

    $self->{-db}->delete_from('MOBILE',"ID=$oid");

    # set new MOVE_WITH, if deleted unit has some companions
    $self->{-db}->update_hash('MOBILE',
			      "MOVE_WITH=$oid",
			      {'MOVE_WITH' => $mob->{'ID'}});

  }
  $self->{-db}->update_hash('MOBILE',
			    "ID=$mob->{'ID'}",
			    {'COUNT' => $count}) if $count != $mob->{'COUNT'};

  # rekursion for every companion of $mob
  my $companions = $self->{-context}->read_mobile_condition('ID,OWNER',
					   "LOCATION=$location ".
					   "AND MOVE_WITH=$mob->{'ID'}");
  for my $m (@$companions){
    my ($mid,$mown) = @$m;
    # does it still exist?
    my $comp = $self->{-db}->read_single_mobile($mid);
    next unless defined $comp;
    $self->unify_mobiles($comp,$location,$mown);
  }
}

# the move-command will be set up again in the oposite direction
sub turn_around{
  my ($self,$loc) = @_;

  # first we have to check, if we are here because of an MOVE-COMMAND
  # or out of some other reason
  if($self->{-dbhash}->{'COMMAND'} eq 'MOVE'){
    my $mob = $self->{-mob};
    my $dir = $self->{-args}->{'DIR'};
    my $rev = {'S' => 'N',
	       'N' => 'S',
	       'SW' => 'NE',
	       'NE' => 'SW',
	       'SE' => 'NW',
	       'NW' => 'SE',};
    $dir = $rev->{uc($dir)};
    Util::log("we ($mob->{'ID'} in $loc) are friends ".
	      "and come from $dir. we turn around...",1);
    $self->{-context}->insert_command('MOVE',
				      "DIR=$dir, MOBILE=$mob->{'ID'}, ".
				      "COUNT=$mob->{'COUNT'}, AUTO=1",$loc);
  }else{
    #
  }
}

# do we start a fight here?
sub is_new_earthling_fight{
  my ($self,$location,$relation,$terrain) = @_;
  my $mob = $self->{-mob};
  my $attacker = $self->{-player};
  my $occupant = $self->{-occupant};

  # no fight on some neutral territories
  return 0 unless $occupant or exists $::conf->{-FIGHTS_WITHOUT_OWNER}->{$terrain};

  # no new fight, if allready one started
  return 0 if $self->{-context}->earthling_fight($location);

  return 0 if $attacker == $occupant or
    $relation eq 'FRIEND' or
      $relation eq 'ALLIED';

  my $qloc = $self->{-db}->quote($location);
  $self->{-db}->update_hash('MAP',"GAME=$self->{-game} AND LOCATION=$qloc",
			  {'ATTACKER' => $attacker});

}

# start a fight!
sub do_earthling_fight{
  my ($self,$loc) = @_;

  # write the fight command

  $self->{-context}->insert_command('FIGHT_EARTHLING',
				    "ATTACKER=$self->{-player}, ".
				    "DEFENDER=$self->{-occupant}",
				    $loc);
}

# enough mana available?
sub test_mana{
  my ($self,$action,$factor,$god) = @_;
  $factor = 1 unless defined $factor;
  $god = $self->{-player} unless defined $god;

  my $mana = $self->{-context}->get_mana($god);
  my $mana_needed = $::conf->{-MANA}->{"-$action"} * $factor;

  Util::log("$god needs $mana_needed mana from his $mana mana to do $action",1);

  # dirty workaround: we fake our identity.
  my $player = $self->{-player};
  $self->{-player} = $god;
  unless($self->test(sub{ $mana >= $mana_needed },
		     'MSG_NOT_ENOUGH_MANA',
		     $action,
		     $self->{-location} ? $self->{-location} : 'GLOBAL')){
    $self->{-player} = $player;
    return 0;
  }
  $self->{-player} = $player;

  $self->{-mana} = $mana - $mana_needed;
  $self->{-mana_paid} = $mana_needed;
  return 1;
}

sub use_mana{
  my ($self,$god) = @_;
  $god = $self->{-player} unless defined $god;
  $self->{-db}->update_hash('GOD',"PLAYER=$god AND GAME=$self->{-game}",
			    {'MANA' => $self->{-mana}});
  Util::log("$god pays $self->{-mana_paid} mana ".
	    "and has still $self->{-mana} left.",1);
  #TODO?: Message
}

# this returns the used mana and did not test before
sub instant_use_mana{
  my ($self,$mana,$god) = @_;
  $god = $self->{-player} unless defined $god;

  my $mana_available = $self->{-context}->get_mana($god);

  if ($mana_available < $mana)
  {
	# not enough mana
  	$mana = $mana_available;
  }
  my $newmana = $mana_available - $mana;

  $self->{-db}->update_hash(
	'GOD',
	"PLAYER=$god AND GAME=$self->{-game}",
	{'MANA' => $newmana}
  );
  Util::log("$god pays $mana mana ".
	    "and has still $newmana left.",1);
  return $mana;
}

#
# End of AymCommand
#
####################################################

##########################################################
#
# Use this template to generate new commands
#

package AymCommandTemplate;
@AymCommandTemplate::ISA = qw(AymCommand);

# ... arguments in $self->{-args}
# ... player in $self->{-player}
# ... game in $self->{-game}
# ... context object in $self->{-context}
# ... database object in $self->{-db}
# ... basic duration from Config in $self->{-duration}
# ... command from database in $self->{-dbhash}

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
	my $self = shift;
	my @required_arguments = ();
	return 0 unless $self->Command::is_valid(@required_arguments);

	# ... here your code

	return 1;
}

# this is called from Scheduler, when he see the command the
# first time, some commands execute here immidiatly.
# AymCommand
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # ... here your code

  return 1;
}

# this is called from scheduler when the command will be executed.
# AymCommand
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # ... here your code

  return 1;
}

#
# End of template
#
####################################################

#
# CH_STATUS: Change the player alliance status
#

package CH_STATUS;
@CH_STATUS::ISA  = qw(AymCommand);

sub is_valid{
  my ($self) = @_;

  my @required_arguments = ('OTHER','STATUS');
  return 0 unless $self->Command::is_valid(@required_arguments);

  # exist OTHER still in game?
  if($self->{-args}->{'OTHER'} != -1){
    my $role = $self->{-context}->read_role($self->{-args}->{'OTHER'},'PLAYER');
    return 0 unless $self->test(sub{$role},
				'MSG_NO_SUCH_ROLE');
  }

  # is STATUS valid?
  my $status = $self->{-args}->{'STATUS'};
  return 0 unless $self->test(sub{Util::is_in($status,
					      'FRIEND',
					      'FOE',
					      'NEUTRAL',
					      'BETRAY',
					      'ALLIED')},
			      'MSG_STATUS_INVALID',
			      $status);
  return 1;
}

# CH_STATUS
sub first_phase{
  my $self = shift;
  return 0 unless $self->is_valid();

  my $tag = 'MSG_CH_STATUS';
  my $other = $self->{-args}->{'OTHER'};
  my $status = $self->{-args}->{'STATUS'};
  # ($status,$tag) = $self->{-db}->quote_all($status,$tag);
  $self->{-db}->insert_or_update_hash(
			    'ALLIANCE',
			    "PLAYER=$self->{-player} ".
			    "AND OTHER=$other ".
			    "AND GAME=$self->{-game}",
			    {'GAME' => $self->{-game},
			     'PLAYER' => $self->{-player},
			     'OTHER' => $other,
			     'STATUS' => $status}
			   );

  #$self->{-context}->send_message_to_me({'MFROM' => 0,
  #					 'MSG_TAG' => $tag,
  #					 'ARG1' => $self->{-context}->charname($other),
  #					 'ARG2' => $status,
  #					});

  $self->setDuration(0);
  return 0;
};

sub second_phase{
  my $self = shift;
  Util::log("Warning: We should not reach phase 2 with command CH_STATUS",0);
  return 0;
};

#
# END of CH_STATUS
#
################################################################

################################################################
#
# MOVE: Move mobiles
#

package MOVE;
use Data::Dumper;
# use FROGS::HexTorus;
@MOVE::ISA = qw(AymCommand);

sub is_valid {
  my $self = shift;

  my $db = $self->{-db};
  my $args = $self->{-args};
  my $aym = $self->{-context};
  my $phase = $self->{-phase};

  my @required_arguments = ('MOBILE','COUNT','DIR');
  return 0 unless $self->Command::is_valid(@required_arguments);

  my $mob_id = $args->{'MOBILE'};
  my $count = $args->{'COUNT'};

  return 0 unless $count =~ /^\s*\d+\s*$/;

  return 0 unless $self->validate_mobile($self->{-args}->{'MOBILE'});
  my $mob = $self->{-mob};

  my ($owner,$loc_string,$type) = ($mob->{'OWNER'},
				   $mob->{'LOCATION'},
				   $mob->{'TYPE'},
				  );
  # print "LOCATION: $loc_string\n";
  $self->{-loc_string} = $loc_string;
	
  # enough mobiles avaiable?
  if ($phase == 1) {
    return 0 unless $self->test(sub {$count <= $mob->{'COUNT'} and
				       $mob->{'AVAILABLE'} eq 'Y'},
				'MSG_NOT_ENOUGH_MOBILES',
				'MOVE',
				$count,
				$loc_string);
  }
  # get target field

  my ($size) = $db->read_game($self->{-game},'SIZE');
  $self->{-size} = $size;
  my $map = HexTorus->new($size);
  $self->{-map} = $map;

  my $loc = Location->from_string($loc_string);
  $self->{-loc} = $loc;

  # MULTIMOVE: extract first direction and rest of string
  my $direction = $args->{'DIR'};
  $direction =~ s/^\s*(\S*)\s*$/$1/; # removing leading/trailing whitespace
  $direction =~ /^(\S*)\s+(.*)$/; # split up first direction
  my ($first_direction,$other_directions) = ($1,$2);
  if($other_directions){
    $self->{-multimove} = $other_directions;
    $direction = $first_direction;
    Util::log("MULTIMOVE: now $first_direction, later $other_directions",1);
  }

  my $target = $map->get_neighbour($loc,$direction);

  # target correct?
  return 0 unless $self->test(sub{$target},
			      'MSG_MOVE_NO_TARGET',
			      $loc_string,
			      $args->{'DIR'});
  $self->{-target} = $target;
  my $target_string = $target->to_string();

  # get terrain of loc and target
  my ($terrain,$attacker,$god_attacker,$plague) = 
    $aym->read_field('TERRAIN,ATTACKER,GOD_ATTACKER,PLAGUE',$loc_string);
  $plague = '' unless defined $plague;
  my ($target_terrain,$target_occupant) =
    $aym->read_field('TERRAIN,OCCUPANT',$target_string);
  $self->{-target_occupant} = $target_occupant;

  # you can only MOVE_WITH on water, except you are an ARK
  return 0 unless $self->test(sub{Util::is_in($target_terrain,
					      'PLAIN',
					      'CITY',
					      'MOUNTAIN',
					      'AYMARGEDDON',
					      'POLE') or $type eq 'ARK'},
			      'MSG_CANT_SWIM',
			      'CMD_MOVE',
			      $loc_string,
			      "MOBILE_$type\_PL");
  # $self->{-context}->mobile_string($type,2));



  # role specific tests
  my $role = $self->{-role};

  # return 0 unless $self->validate_role('GOD','EARTHLING');
  #if ($mob->{'TYPE'} eq 'ARK') {
    # Util::log("Impossible Situation: ARK has got a MOVE-Command",1);
  if ($role eq 'GOD') {
    # gods can only move avatars
    return 0 unless $self->test(sub{$type eq 'AVATAR'},
				'MSG_GOD_CANT_MOVE_TYPE',
				$self->{-context}->mobile_string($type,2));

    # dont move if $loc is Aymargeddon
    return 0 unless $self->test(sub{$terrain ne 'AYMARGEDDON'},
				'MSG_CANT_LEAVE_AYMARGEDDON',
				$loc_string);


    # dont move, if ongoing FIGHT_GOD
    if($phase == 1){
      return 0 unless $self->test(sub{not $god_attacker},
				  'MSG_CANT_MOVE_ATTACKED',
				  $mob->{'LOCATION'},
				  $self->{-context}->mobile_string($type,2));
    }

    # if targetfield water/isle, than dont move directly (only MOVE_WITH)
    #if ($phase == 1 and (Util::is_in($target_terrain,'WATER','ISLE') # or
			 # Util::is_in($terrain,'WATER','ISLE'))
   # )) {

      # TODO: Errormessage

     # return 0;

    #}

    # avatars can go on land, if ark available
    #if ($phase==1 and Util::is_in($terrain,'ISLE','WATER') and
    #	not Util::is_in($target_terrain,'ISLE','WATER')) {
    #     my $arks = $self->{-context}->read_mobile('ID','ARK',$loc_string,1);
    #    my $ark_count = $#{@$arks}+1;
    #   return 0 unless $self->test(sub{$ark_count},
    #			  'MSG_CANT_SWIM',
    #		  'MOVE',
    #	  $loc_string,
    #  $self->{-context}->mobile_string($type,2));
    #}
  } elsif ($role eq 'EARTHLING' or $owner == -1) {
    # read companions
    $self->{-companions} = $self->{-context}->
      read_mobile_condition('TYPE,COUNT,OWNER,ID',
			    "MOVE_WITH=$self->{-args}->{'MOBILE'}");

    # do not move if field is attacked or tuberculosis
    if ($phase == 1) {
      return 0 unless $self->test(sub{not $attacker},
				  'MSG_CANT_MOVE_ATTACKED',
				  $mob->{'LOCATION'},
				  $self->{-context}->mobile_string($type,2));
      return 0 unless $self->test(sub{ $plague !~ /TUBERCULOSIS/ 
					 or exists $self->{-args}->{'AUTO'}},
				  'MSG_CANT_MOVE_PLAGUE',
				  $mob->{'LOCATION'},
				  $self->{-context}->mobile_string($type,2),
				  'Tuberculosis');
    }
    # eartlings can only move this types
    return 0 unless $self->test(sub{Util::is_in($type,
						'WARRIOR',
						'PRIEST',
						'HERO',
						'PROPHET',
						'ARK')},
				'MSG_EARTHLING_CANT_MOVE_TYPE',
				$self->{-context}->mobile_string($type,2));

    # dont move if target field is Pole
    return 0 unless $self->test(sub{$target_terrain ne 'AYMARGEDDON' and
				      $target_terrain ne 'POLE'},
				'MSG_CANT_MOVE_TO_POLE',
				'MOVE', $target_string);

    # dont move ark from land to land
    if($type eq 'ARK'){
      return 0 unless $self->test(sub{Util::is_in($terrain,'WATER','ISLE') or
					Util::is_in($target_terrain,'WATER','ISLE')},
				  'MSG_CANT_MOVE_ARK',
				  'MOVE', $target_string);
      $self->{-active_ark} = $self->{-args}->{'MOBILE'};
    }

    # automatic ark-moving
    #     if ($type ne 'ARK' and $phase == 1 and 
    #         (Util::is_in($target_terrain,'WATER','ISLE'))){
    #       # or Util::is_in($terrain,'WATER','ISLE'))) {
    #       my $arks = $aym->read_mobile('ID,COUNT','ARK',$loc_string,1);
    #       # print Dumper $arks;
    #       my ($ark,$active);
    #       if (defined $arks->[0]) {
    # 	($ark,$active) = (@{$arks->[0]});
    #       } else {
    # 	($ark,$active) = (0,0);
    #       }
    #       return 0 unless $self->test(sub {$active or $type eq 'PROPHET'},
    # 				  'MSG_CANT_SWIM',
    # 				  'MOVE',
    # 				  $loc_string,
    # 				  $self->{-context}->mobile_string($type,2));
    #       $self->{-active_ark} = $ark;
    #       Util::log("We take ark $ark with us.",1);
    #     }

  } else {
    Util::log("impossible situation. I could not be $role",0);
    return 0;
  }

  # dont move without mana
  if ($phase == 1) {
    if ($role eq 'GOD') {
      unless($self->test_mana('MOVE_AVATAR',$count)){
	$db->update_hash('MOBILE',
			 "ID=$mob_id",
			 {
			  'AVAILABLE' => 'Y'});
	return 0;
      }
    } else {
      # for all avatar-companions: pay or stay (if not on ark)!
      if ($type ne 'ARK'){
	my $deleted = 0;
	for my $comp (@{$self->{-companions}}) {
	  my ($ctype,$ccount,$cown,$cid) = @$comp;
	  next unless $ctype eq 'AVATAR';
	  unless($self->test_mana('MOVE_AVATAR',$ccount,$cown) and not $god_attacker){
	    $db->update_hash('MOBILE',
			     "ID=$cid",
			     {'AVAILABLE' => 'Y',
			      'MOVE_WITH' => 0});
	    $self->unify_mobiles($cid,0,$cown);
	    $deleted = 1;
	  }
	}
	# re-read companions
	$self->{-companions} = $self->{-context}->
	  read_mobile_condition('TYPE,COUNT,OWNER,ID',
				"MOVE_WITH=$self->{-args}->{'MOBILE'}")
	    if $deleted;

      }
    }
  }

  return 1;
}

# MOVE
sub first_phase{
  my ($self) = @_;

  return 0 unless $self->is_valid();

  my $db = $self->{-db};
  my $type = $self->{-mob}->{'TYPE'};
  my $mob = $self->{-mob};
  my $aym = $self->{-context};

  # split it, if neccessary
  # the moving unit get the old ID!

  my $count = $self->{-args}->{'COUNT'};
  #print "conditional split with $count count and mob=\n";
  #print Dumper $mob;
  #print Dumper $self;
  return 0 unless
    $self->conditional_split_mobile($mob,$count,
				    {'COMMAND_ID' => $self->{-dbhash}->{'ID'},
				     'MOVE_WITH' => 0},0);

  # if ark needed, move it together with us
  #if($type ne 'ARK' and $self->{-active_ark}){

  #  $self->move_with($self->{-active_ark},$self->{-args}->{'MOBILE'},1);

    # set owner of ark
    # $self->{-db}->update_hash('MOBILE',
    # "ID=$self->{-active_ark}",
    # {'OWNER' => $self->{-player}});
  #}

  # collect mobiles with MOVE_WITH in same location
  my $companions = $self->{-companions};

  # calculate duration
  my $d = $::conf->{-DURATION};
  my $dur = $d->{"-MOVE_$type"};

  # if moved with ark use -MOVE_ARK else use slowest
  if($self->{-active_ark}){
    $dur = $d->{'-MOVE_ARK'};
  }else{
    for my $m (@$companions){
      my ($mtype) = @$m;
      $dur = $d->{"-MOVE_$mtype"} if $d->{"-MOVE_$mtype"} > $dur;
    }
  }
  $self->setDuration($dur);

  # set all companions inactive
  $self->{-db}->update_hash('MOBILE',
			    "LOCATION=$mob->{'LOCATION'} ".
			    "AND MOVE_WITH=$self->{-args}->{'MOBILE'}",
			   {'AVAILABLE' => 'N'});

  # remove OCCUPANT in MAP, if we are an earthling
  # and there are no more own active (if it was our field)
  # mobiles left and if it is no homecity
  if($aym->is_earthling()){
    $self->empty_field($mob->{'LOCATION'});
    # avatar-companions: pay now
    if($type ne 'ARK'){
      for my $comp (@$companions){
	my ($ctype,$ccount,$cown,$cid) = @$comp;
	next unless $ctype eq 'AVATAR';
	$self->use_mana($cown);
      }
    }
  }elsif($aym->is_god()){
    $self->use_mana();
  }

  # events
  if($type eq 'ARK' or $self->{-active_ark}){
    $self->event($self->{-target}->to_string(),
		 'EVENT_ARK_APPROACHING',
		 $mob->{'LOCATION'},
		 $mob->{'COUNT'});
  }else{ #elsif($type ne 'ARK'){
    my $player = $self->{-player};
    my $count = $self->{-args}->{'COUNT'};
    my $typetag = $count > 1 ? "MOBILE_$type".'_PL' : "MOBILE_$type";
    $self->event($self->{-target}->to_string(),
		 'EVENT_MOBILE_APPROACHING',
		 $mob->{'LOCATION'},
		 $count,
		 # $self->{-context}->mobile_string($type,$count));
		 $typetag);

    # TODO Bug: if avatar moves with hero, the wrong player is in the event-message.

      for my $m2 (@$companions){
	my ($mtype,$c,$mo) = @$m2;
	$self->{-player} = $mo;
	$typetag = $c > 1 ? "MOBILE_$mtype".'_PL' : "MOBILE_$mtype";
	$self->event($self->{-target}->to_string(),
		     'EVENT_MOBILE_APPROACHING',
		     $mob->{'LOCATION'},
		     $c,
		     # $self->{-context}->mobile_string($mtype,$c))
		     $typetag);
      }
    $self->{-player} = $player;
  }

  return $dur;
}

# MOVE
sub second_phase{
  my ($self) = @_;

  return 0 unless $self->is_valid();

  my $db = $self->{-db};
  my $mob = $self->{-mob};
  my $count = $self->{-args}->{'COUNT'};
  my $target_location = $self->{-target}->to_string();
  my $old_location = $mob->{'LOCATION'};

  # move mobile and all moving with it.
  $db->update_hash('MOBILE',"ID=$mob->{'ID'} OR MOVE_WITH=$mob->{'ID'}",
		   {'LOCATION' => $target_location,
		    'AVAILABLE' => 'Y',
		   });

  # TODO: distribute plagues

  # Bug?
  # $self->{-db}->update_hash('MOBILE',
  # "TYPE=ARK AND MOVE_WITH=$mob->{'ID'}",
  # {'MOVE_WITH' => 0});

  # should we do a godfight?
  my $companions = $self->{-companions};
  if($mob->{'TYPE'} eq 'AVATAR'){
    $self->enter_field_avatar($target_location,$mob);
  }else{
    for my $m (@$companions){
      my ($mtype,$mc,$mo,$mid) = @$m;
      next unless $mtype eq 'AVATAR';
      $self->enter_field_avatar($target_location,$mid);
    }
  }

  $self->enter_field($target_location) if $self->{-role} eq 'EARTHLING';
  # $self->enter_field_avatar($target_location,$mob) if $self->{-role} eq 'GOD';
  $self->drowning($old_location);

  # MULTIMOVE
  if(defined $self->{-multimove}){
    $self->{-context}->insert_command('MOVE',
				      "ROLE=$self->{-player}, ".
				      "DIR=$self->{-multimove}, ".
				      "MOBILE=$mob->{'ID'}, ".
				      "COUNT=$mob->{'COUNT'}",
				      $mob->{'LOCATION'});
  }else{
    $self->unify_mobiles($mob,$target_location);
  }

# TODO: maybe we should give a message only to the player of the unit
# ... but its difficult, because of MOVE_WITH

#  $self->{-context}
#    ->send_message_to_field
#	($target_location,
#	 {'MFROM' => 0,
#	  'MSG_TAG' => 'MSG_MOBILE_ARRIVES',
#	  'ARG1' => $count,
#	  'ARG2' => $self->{-context}->mobile_string($self->{-mob}->{'TYPE'},
#						     $self->{-mob}->{'COUNT'}),
#	  'ARG3' => $self->{-context}->charname($self->{-player}),
#	  'ARG4' => $target_location});

#  for my $m (@$companions){
#    my ($mtype,$mc,$mo,$mid) = @$m;
#    $self->{-context}
#      ->send_message_to_field
#	($target_location,
#	 {'MFROM' => 0,
#	  'MSG_TAG' => 'MSG_MOBILE_ARRIVES',
#	  'ARG1' => $mc,
#	  'ARG2' => $self->{-context}->mobile_string($mtype,$mc),
#	  'ARG3' => $self->{-context}->charname($mo),
#	  'ARG4' => $target_location});
#  }


  return 1;
}

#
# End of MOVE
#
####################################################

##########################################################
#
# BLESS_PRIEST
#

package BLESS_PRIEST;
@BLESS_PRIEST::ISA = qw(AymCommand);

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('MOBILE');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_mobile($self->{-args}->{'MOBILE'});

  return 0 unless $self->validate_role('GOD');

  my $mobtype = $self->{-mob}->{'TYPE'};
  my $mobloc = $self->{-mob}->{'LOCATION'};

  # don't bless unassigned units
  return 0 unless $self->test(sub{$self->{-mob}->{'OWNER'} > 0},
			      'MSG_CANT_BLESS_UNASSIGNED',
			      $mobloc);

  # only bless warriors
  return 0 unless $self->test(sub{$self->{-mob}->{'TYPE'} eq 'WARRIOR'},
			      'MSG_WRONG_TYPE',
			      $self->{-context}->mobile_string($mobtype,1),
			      $mobloc);

  return 0 unless $self->test_mana('BLESS_PRIEST');

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# BLESS_PRIEST
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $id = $self->{-mob}->{'ID'};
  my $newid = $self->conditional_split_mobile($self->{-mob},
					      1,
					      {'ADORING' => $self->{-player},
					       'TYPE' => 'PRIEST',
					       'COMMAND_ID' => $self->{-dbhash}->{'ID'}},
					      'beforeafter');

  # companions move with the remaining warriors, not with the new priest
  $self->{-db}->update_hash('MOBILE',
			    "MOVE_WITH = $id",
			    {'MOVE_WITH' => $newid}) if $id != $newid;

  # reread mobile, because split destroys it
  $self->{-mob} = $self->{-db}->single_hash_select('MOBILE',"ID=$id");
  $self->unify_mobiles($self->{-mob},
		       $self->{-mob}->{'LOCATION'},
		       $self->{-mob}->{'OWNER'});

  $self->change_priest_on_temple($self->{-mob}->{'LOCATION'});

#  $self->{-context}
#    ->send_message_to_field
#      ($self->{-mob}->{'LOCATION'},
#       {'MFROM' => 0,
#	'MSG_TAG' => 'MSG_BLESS_PRIEST',
#	'ARG1' => $self->{-context}->charname($self->{-player}),
#	'ARG2' => $self->{-context}->charname($self->{-mob}->{'OWNER'}),
#	'ARG3' => $self->{-mob}->{'LOCATION'}});


  $self->use_mana();
  $self->setDuration(0);

  return 0;
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  Util::log("BLESS_PRIEST should not have a second phase!",0);
  return 0;
}

#
# End of BLESS_PRIEST
#
####################################################

##########################################################
#
# BUILD_TEMPLE
#

package BUILD_TEMPLE;
use Data::Dumper;
@BUILD_TEMPLE::ISA = qw(AymCommand);

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('MOBILE');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_mobile($self->{-args}->{'MOBILE'});

  my $mobtype = $self->{-mob}->{'TYPE'};
  my $mobloc = $self->{-mob}->{'LOCATION'};
  my $god = $self->{-mob}->{'ADORING'};

  # only priests can build temples
  return 0 unless $self->test(sub{$self->{-mob}->{'TYPE'} eq 'PRIEST'},
			      'MSG_WRONG_TYPE',
			      $self->{-context}->mobile_string($mobtype,1),
			      $mobloc);

  # is this a valid building place?
  # my($loc,$terrain,$temple) = $self->{-context}->read_map('TERRAIN,TEMPLE');
  my ($terrain,$temple) =
    $self->{-context}->read_field('TERRAIN,TEMPLE',$mobloc);
  return 0 unless $self->test(sub{$temple ne 'Y'
				    and Util::is_in($terrain,'MOUNTAIN','ISLE')},
			      'MSG_CANT_BUILD_HERE',
			      $mobloc);

  # is the priest adoring a fitting god?
  #return 0 unless $self->test(sub{($terrain eq 'MOUNTAIN' and
  #				   $self->{-mob}->{'ADORING'} eq $god) or
  #				     $terrain eq 'ISLE'},
  #			  'MSG_ADORING_WRONG_GOD',
  #			  $mobloc,
  #			  $self->{-mob}->{'ADORING'},
  #			  $self->{-context}->charname($god));

  # is there allready a BUILD_TEMPLE Command
  if($self->{-phase} == 1){
    return 0 unless $self->test(sub{! $self->{-context}->search_event('BUILD_TEMPLE',
								      $mobloc)},
				'MSG_CANT_BUILD_HERE',
				$mobloc);
  }

  # dont build more than MAX_MOUNTAIN temples on mountains
  if($terrain eq 'MOUNTAIN'){
    my $ret = $self->test(sub{$self->{-db}->count('MAP',
						  "GAME=$self->{-game} AND ".
						  "TEMPLE=Y AND ".
						  "HOME=$god AND ".
						  "OCCUPANT=$self->{-player} AND ".
						  "TERRAIN=MOUNTAIN")
				      < $::conf->{-MAX_MOUNTAINS}},
			  'MSG_CANT_BUILD_HERE',
			  $mobloc);
    if(not $ret and $self->{-phase} == 2){
      # we have to set priest active, if we tryed to build in first phase
      $self->{-db}->update_hash('MOBILE',
				"ID=$self->{-mob}->{'ID'}",
				{'AVAILABLE' => 'Y'});
    }
    return 0 unless $ret;
  }

  return 1;
}

# this is called from Scheduler, if he sees the command the
# first time, some commands execute here immidiatly.
# BUILD_TEMPLE
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  $self->conditional_split_mobile($self->{-mob},
				  1,
				  {'COMMAND_ID' => $self->{-dbhash}->{'ID'},
				   'MOVE_WITH' => 0},
				  0);

  # delete all MOVE_WITH the priest
  # BUG?: uninitialized value in this line??? maybe split is wrong in a way?
  $self->{-db}->update_hash('MOBILE',
			    "MOVE_WITH = $self->{-mob}->{'ID'}",
			    {'MOVE_WITH' => 0});

  $self->empty_field($self->{-mob}->{'LOCATION'});

  my ($size) = $self->{-db}->read_game($self->{-game},'TEMPLE_SIZE');

  # set new temple size
  $size++;
  $self->{-db}->update_hash('GAME',
			    "GAME=$self->{-game}",
			    {'TEMPLE_SIZE' => $size});
  Util::log("New temple size: $size",1);

  # calculate duration
  $self->setDuration($size * $::conf->{-DURATION}->{-BUILD_TEMPLE});

  $self->event($self->{-mob}->{'LOCATION'},
	       'EVENT_BUILD_TEMPLE',
	       $self->{-context}->charname($self->{-mob}->{'ADORING'}),
	       $size);

  return $self->{-duration};
}

# this is called from scheduler when the command will be executed.
# BUILD_TEMPLE
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $loc = $self->{-mob}->{'LOCATION'};
  $self->{-db}->update_hash('MAP',
			    "GAME=$self->{-game} AND LOCATION=$loc",
			    {'TEMPLE' => 'Y',
			     'HOME' => $self->{-mob}->{'ADORING'}});

  $self->{-db}->update_hash('MOBILE',
			    "ID=$self->{-mob}->{'ID'}",
			    {'AVAILABLE' => 'Y'});

  # insert new PRODUCE-command
  $self->{-context}->insert_command('PRODUCE', "ROLE=$self->{-player}",
				    $self->{-mob}->{'LOCATION'});

  # insert new PRAY-command
  $self->{-context}->insert_command('PRAY','',$loc);

  # this deletes and reinsert commands, if we conquer with building
  $self->enter_field($loc,1);

  #change aymargeddon to nearest pole
  my $poles = $self->{-db}->select_array('MAP',
					 'LOCATION,TERRAIN',
					 "GAME=$self->{-game} AND ".
					 "(TERRAIN=POLE OR TERRAIN=AYMARGEDDON)");
  my $min_distance = $::conf->{-MANY};
  my $Loc = Location->from_string($loc);
  my ($new_aym,$old_aym) = ('','');
  for my $pol (@$poles){
    my ($loc2,$ter) = @$pol;
    $old_aym = $loc2 if $ter eq 'AYMARGEDDON';
    my $map = HexTorus->new($self->{-context}->get_size());
    my $Loc2 = Location->from_string($loc2);
    my $dist = $map->distance($Loc,$Loc2);
    Util::log("distance from $loc to $loc2: $dist",1);
    $new_aym = $loc2 if $dist < $min_distance and $ter eq 'POLE';
  }
  if($new_aym){
    Util::log("change aymargeddon from $old_aym to $new_aym",1);
    $self->{-db}->update_hash('MAP',
			      "GAME=$self->{-game} AND LOCATION=$new_aym",
			      {'TERRAIN' => 'AYMARGEDDON'});
    $self->{-db}->update_hash('MAP',
			      "GAME=$self->{-game} AND LOCATION=$old_aym",
			      {'TERRAIN' => 'POLE'});
  $self->{-context}
    ->send_message_to_all
      ({'MFROM' => 0,
	'MSG_TAG' => 'MSG_CHANGE_AYMARGEDDON',
	'ARG1' => $self->{-context}->charname($self->{-player})});
	#'ARG2' => $old_aym,
	#'ARG3' => $new_aym});
  }

  # is this the end of the game?
  my $unbuild = $self->{-context}->unbuild();

  $self->end_of_the_game() unless $unbuild;

  return 0;
}

#
# End of BUILD_TEMPLE
#
####################################################

##########################################################
#
# PRODUCE
#

package PRODUCE;
use Data::Dumper;
@PRODUCE::ISA = qw(AymCommand);

sub is_valid {
	my $self = shift;

	my @required_arguments = ('ROLE');
	# TODO: Open question: is this redundant information? allready
	# in PLAYER of COMMAND?
	return 0 unless $self->Command::is_valid(@required_arguments);

	return 1;
}

# PRODUCE
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my ($ter,$home,$occ,$temple) =
    $self->{-context}->read_field('TERRAIN,HOME,OCCUPANT,TEMPLE',
				  $self->{-dbhash}->{'LOCATION'});

  my ($type, $duration);
  $type = $temple eq 'Y' ? 'PRIEST' : 'WARRIOR';

  my $d = $::conf->{-DURATION};
  my $peace = $self->{-args}->{'PEACE'};
  $peace = 0 unless defined $peace;
  if($type eq 'PRIEST'){
    Util::log("Produce a priest at ",-1);
    if ($ter eq 'MOUNTAIN'){
      Util::log("mountain.",1);
      $duration = $d->{-PRODUCE_PRIEST_HOME};
    }else{
      Util::log("isle.",1);
      $duration = $d->{-PRODUCE_PRIEST};
    }
    $self->setDuration($duration);
    $self->event($self->{-location},
		 'EVENT_PRODUCE_PRIEST');
  }else{
    Util::log("Produce a warrior at ",-1);
    if ($occ == $home){
      Util::log("homecity.",1);
      $duration = $d->{-PRODUCE_WARRIOR_HOME};
    }else{
      Util::log("normal city.",1);
      $duration = $d->{-PRODUCE_WARRIOR} + $d->{-PRODUCE_WARRIOR_CHANGE} * $peace;
    }
    $self->setDuration($duration);
    $self->event($self->{-location},
		 'EVENT_PRODUCE_WARRIOR');
  }

  return $duration;
}

# this is called from scheduler when the command will be executed.
# PRODUCE
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $loc = $self->{-dbhash}->{'LOCATION'};
  my ($temple,$home,$occ,$plague) = 
    $self->{-context}->read_field('TEMPLE,HOME,OCCUPANT,PLAGUE',$loc);
  my $type = $temple eq 'Y' ? 'PRIEST' : 'WARRIOR';

  # fields with influenza do not produce
  if(not defined $plague or not $plague =~ 'INFLUENZA'){

    # dont produce priests at temples, if no other priests are there
    if ($type eq 'PRIEST'){
      my $mobiles = $self->{-context}
	->read_mobile_condition('ID',
				"TYPE=PRIEST AND AVAILABLE=Y AND ADORING=$home",$loc);
      if(!@$mobiles){
	Util::log("No priests, no new priests!",1);
	$self->do_it_again();
	return 0;
      }
    }

    my $mob = {'ID' => $self->{-db}->find_first_free('MOBILE','ID'),
	       'TYPE' => $type,
	       'LOCATION' => $loc,
	       'COUNT' => 1,
	       'AVAILABLE' => 'Y',
	       'OWNER' => $self->{-args}->{'ROLE'},
	       'GAME' => $self->{-game},
	       'MOVE_WITH' => 0,
	      };

    # print Dumper $mob;

    $mob->{'ADORING'} = $home if $type eq 'PRIEST';

    my %mobcopy = (%$mob);
    $self->{-mob} = \%mobcopy;
    $self->{-db}->insert_hash('MOBILE',
			      $mob);

    $self->enter_field($loc,1);
  } # endif no influenza
  else{
    Util::log("No production in $loc due to INFLUENZA!",1);
  }

  # re-insert command
  my $new_peace = $self->{-args}->{'PEACE'};
  $new_peace = 0 unless defined $new_peace;
  $new_peace++;
  $self->do_it_again({'PEACE' => $new_peace});

  return 1;
}

#
# End of PRODUCE
#
####################################################

##########################################################
#
# PRAY
#

package PRAY;
use Data::Dumper;
@PRAY::ISA = qw(AymCommand);

sub is_valid {
  my $self = shift;

  my @required_arguments = ();
  return 0 unless $self->Command::is_valid(@required_arguments);

  $self->{-loc} = $self->{-dbhash}->{'LOCATION'};
  my ($temple,$home) = $self->{-context}->read_field('TEMPLE,HOME',
						     $self->{-loc});
  # TODO: use test() instead
  return 0 unless $temple eq 'Y';

  $self->{-god} = $home;

  return 1;
}

# PRAY
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  return $self->{-duration};
}

# PRAY
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # count number of active orthodox priests
  my $priests = 0;
  my $oim = $self->{-context}->own_in_mobile($self->{-loc},
					     $self->{-god},
					     'available');

  for my $om (@$oim){
    my ($id) = @$om;
    my $mob = $self->{-db}->read_single_mobile($id);
    $priests += $mob->{'COUNT'} if($mob->{'TYPE'} eq 'PRIEST');
  }

  # reduce effective priests if necessary
  my $fortune = $self->{-context}->read_fortune();
  my $oldpriests = $priests;

  my ($terrain) = $self->{-context}->read_field('TERRAIN',$self->{-loc});
  if($terrain eq 'MOUNTAIN'){
    if($priests > $::conf->{-FORTUNE_FAKTOR_MOUNTAIN} * $fortune){
      $priests = $::conf->{-FORTUNE_FAKTOR_MOUNTAIN} * $fortune;
    }
  }elsif($terrain eq 'ISLE'){
    if($priests > $::conf->{-FORTUNE_FAKTOR_ISLAND} * $fortune){
      $priests = $::conf->{-FORTUNE_FAKTOR_ISLAND} * $fortune;
    }
  }else{
    Util::log("ERROR: PRAY in terrain $terrain",0);
  }

  Util::log("reduce praying priests from $oldpriests to".
	    " $priests in $self->{-loc} ($terrain, fortune: $fortune)",1)
      if $oldpriests > $priests;

  # add priests + 1 mana to $self->{-god}
  my $mana = $self->{-context}->get_mana($self->{-god});
  my $newmana = $mana + $priests + $::conf->{-MANA_FOR_TEMPLE};

  $self->{-db}->update_hash('GOD',
			    "PLAYER=$self->{-god} AND GAME=$self->{-game}",
			    {'MANA' => $newmana});
  Util::log("$priests priests pray for $self->{-god} ".
	    "in $self->{-loc} and he got ". ($newmana - $mana) ." mana",1);

  # TODO: Message?

  # re-insert command
  $self->do_it_again();

  return 1;
}

#
# End of PRAY
#
####################################################

##########################################################
#
# BUILD_ARK
#

package BUILD_ARK;
use Data::Dumper;
@BUILD_ARK::ISA = qw(AymCommand);

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  #  my @required_arguments = ('');
  return 0 unless $self->Command::is_valid();

  return 0 unless $self->validate_role('GOD');

  return 1;
}

# this is called from Scheduler, if he sees the command the
# first time, some commands execute here immidiatly.
# BUILD_ARK
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();
  return 0 unless $self->test_mana('BUILD_ARK');

  # calculate duration
  $self->setDuration($::conf->{-DURATION}->{-BUILD_ARK});

  my $loc = $self->{-location};
  
  $self->event($loc,'EVENT_BUILD_ARK');

  $self->use_mana();
  
  $self->{-affected} = {
      -fields => [$loc],
      -mana => $self->{-player},
  };

  return $self->{-duration};
}

# this is called from scheduler when the command will be executed.
# BUILD_ARK
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # owner should be occupant
  my ($occ) = $self->{-context}->read_field('OCCUPANT',$self->{-location});
  $occ = -1 unless $occ;

  my $mob = {'ID' => $self->{-db}->find_first_free('MOBILE','ID'),
	     'TYPE' => 'ARK',
	     'LOCATION' => $self->{-location},
	     'COUNT' => 1,
	     'AVAILABLE' => 'Y',
	     'OWNER' => $occ,
	     'GAME' => $self->{-game},
	    };
  my %mobcopy = (%$mob);
  $self->{-db}->insert_hash('MOBILE',$mob);

  # merge multiple ARKs in one mobile, if same owner
  $self->unify_mobiles(\%mobcopy,$self->{-location},$occ);

  # $self->{-db}->commit();

#  $self->{-context}
#    ->send_message_to_field
#      ($self->{-location},
#       {'MFROM' => 0,
#	'MSG_TAG' => 'MSG_BUILD_ARK',
#	'ARG1' => $self->{-context}->charname($self->{-player}),
#	'ARG2' => $self->{-location}});

  return 0;
}

#
# End of BUILD_ARK
#
####################################################

####################################################
#
# INCARNATE: Create an Avatar
#

package INCARNATE;
@INCARNATE::ISA  = qw(AymCommand);

sub is_valid{
  my ($self) = @_;

  my @required_arguments = ('COUNT');
  return 0 unless $self->Command::is_valid(@required_arguments);

  # you need a temple to create an avatar
  $self->{-arrival} = $self->{-context}->incarnation_place();
  return 0 unless $self->test(sub{$self->{-arrival};},
			      'MSG_ERROR_NO_ARRIVAL');

  # TODO: maybe with variing cost (distance to Aymargeddon)
  return 0 unless $self->test_mana('INCARNATE', $self->{-args}->{'COUNT'});

  return 1;
}

# INCARNATE
sub first_phase{
  my $self = shift;
  return 0 unless $self->is_valid();

  # create mobile (or join)
  my $mob = {'ID' => $self->{-db}->find_first_free('MOBILE','ID'),
	     'GAME' => $self->{-game},
	     'LOCATION' => $self->{-location},
	     'TYPE' => 'AVATAR',
	     'OWNER' => $self->{-player},
	     'COUNT' => $self->{-args}->{'COUNT'},
	     'AVAILABLE' => 'Y',
	     'STATUS' => 'IGNORE',
	     'COMMAND_ID' => $self->{-id},
	    };
  $self->{-mob} = $mob;
  my %mobcopy = (%$mob);
  $self->{-db}->insert_hash('MOBILE',\%mobcopy);

  $self->enter_field_avatar($self->{-location},$mob);
  $self->unify_mobiles($mob,$self->{-location});

  $self->use_mana();

  # TODO: count count
#  $self->{-context}
#    ->send_message_to_field
#      ($self->{-location},
#       {'MFROM' => 0,
#	'MSG_TAG' => 'MSG_INCARNATE',
#	'ARG1' => $self->{-context}->charname($self->{-player}),
#	'ARG2' => $self->{-location}});

  $self->setDuration(0);
  return 1;
};

sub second_phase{
  my $self = shift;
  Util::log("Warning: We should not reach phase 2 with command INCARNATE",0);
  return 0;
};

#
# END of INCARNATE
#
################################################################

##########################################################
#
# FIGHT_EARTHLING
#

package FIGHT_EARTHLING;
use Data::Dumper;
use Date::Parse qw(str2time);
use Date::Calc qw(Time_to_Date);
@FIGHT_EARTHLING::ISA = qw(AymCommand);

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('ATTACKER','DEFENDER');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_role('EARTHLING');
  return 0 unless $self->validate_this_role($self->{-args}->{'ATTACKER'},'EARTHLING');
  my $def = $self->{-args}->{'DEFENDER'};
  if($def > 0){
    return 0 unless $self->validate_this_role($self->{-args}->{'DEFENDER'},'EARTHLING');
  }

  return 1;
}

# this is called from Scheduler, if he sees the command the
# first time, some commands execute here immidiatly.
# FIGHT_EARTHLING
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # calculate duration
  $self->setDuration($::conf->{-DURATION}->{-FIGHT_EARTHLING});

  $self->event($self->{-location},
	       'FIGHT_EARTHLING');

  return $self->{-duration};
}

# this is called from scheduler when the command will be executed.
# FIGHT_EARTHLING
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # read map info
  my ($terrain,$home,$occupant) = $self->{-context}->
    read_field('TERRAIN,HOME,OCCUPANT',$self->{-location});

  my $attacker = $self->{-args}->{'ATTACKER'};
  my $defender = $self->{-args}->{'DEFENDER'};

  # get all mobiles
  my $mobiles = $self->{-context}->read_mobile('ID,TYPE,OWNER,COUNT,STATUS',
					       0, $self->{-location}, 1);
  $self->{-mobiles} = $mobiles;
  # print Dumper $mobiles;

  #my $efoa = {"$attacker" => 0}; # earthling friends of attacker
  #my $efod = {"$defender" => 0}; # earthling friends of defender
  #$self->{-efoa} = $efoa;
  #$self->{-efod} = $efod;

  my ($gfoa, $gfod); # god friends ...

  # calculate strength of both sides
  my ($attack_strength, $defend_strength,$attack_avatar,$defend_avatar) = (0,0,0,0);
  my ($people_attacker, $people_defender) = (0,0);
  for my $mob (@$mobiles){
    my ($id,$type,$own,$count,$stat) = @$mob;

    # next if $own <= 0;
    if(exists($gfod->{$own})){
      # could be reached with differen MOVE_WITH
      $defend_avatar += $count * $self->strength('AVATAR');
      $gfod->{$own} += $count;
      Util::log("(1)mobile $id: $count $type from $own fights for $defender in $self->{-location}",1);
    }elsif(exists($gfoa->{$own})){
      # could be reached with differen MOVE_WITH
      $attack_avatar += $count * $self->strength('AVATAR');
      $gfoa->{$own} += $count;
      Util::log("(2)mobile $id: $count $type from $own fights for $attacker in $self->{-location}",1);
    }else{
      # TODO Performance (in the case of earthling this is not necessary)
      my ($att_rel,$def_rel,$foa,$fod) = (0,0,0,0);

      # Avatars dont fight sometimes (no mana or no help or no friend)
      if($type eq 'AVATAR'){
	# if(not $godfight){
	  $att_rel = $self->{-context}->read_single_relation($own,$attacker);
	  $def_rel = $self->{-context}->read_single_relation($own,$defender);
	
	  $foa = 1 if Util::is_in($att_rel,'FRIEND','ALLIED');
	  $fod = 1 if Util::is_in($def_rel,'FRIEND','ALLIED');
	
	  # defender has support if in doubt
	  $foa = 0 if $foa and $fod;
	  $fod = 1 if not $foa and not $fod;

	  $gfoa->{$own} += $count if $foa;
	  $gfod->{$own} += $count if $fod;

	  # if you dont have enough mana for all your avatars no one fights!
	  if($stat eq 'HELP' and $self->test_mana('FIGHT_AVATAR',1,$own)){
	    $self->use_mana($own);
	  }else{
	    ($foa, $fod) = (0,0);
	    $gfod->{$own} = 0;
	    $gfoa->{$own} = 0;
	  }
	# }
      }else{
	# earthlings are simpel: no friends in field
	$foa = 1 if $own == $attacker;
	$fod = 1 if $own == $defender;
      }

      if($foa){
	Util::log("(3)mobile $id: $count $type from $own fights for ".
		  "$attacker in $self->{-location}",1);
	if($type eq 'AVATAR'){
	  # count maximum avatarpower
	  $attack_avatar += $count * $self->strength('AVATAR');
	}else{
	  # count earthling_strength
	  $attack_strength += $count * $self->strength($type);
	  $people_attacker += $count;
	}
      }elsif($fod){ 	# same for defender
	Util::log("(4)mobile $id: $count $type from $own fights for ".
		  "$defender in $self->{-location}",1);
	if($type eq 'AVATAR'){
	  $defend_avatar += $count * $self->strength('AVATAR');
	}else{
	  $defend_strength += $count * $self->strength($type);
	  $people_defender += $count;
	}
      }else{
	Util::log("(5)mobile $id: $own dont fight with $count $type ".
		  "in $self->{-location}",1);
      }
    }
  }

  # terrain-bonus
  if($terrain eq 'CITY'){
      # bonus for home city
    if($home == $attacker){
      Util::log("homecity fights for $attacker",1);
      $attack_strength += $::conf->{-FIGHT}->{-HOME};
    }elsif($home == $defender and $home){
      Util::log("homecity fights for $defender",1);
      $defend_strength += $::conf->{-FIGHT}->{-HOME};
    }
  }elsif($terrain eq 'ISLE'){
    # bonus for isle
    if($occupant == $attacker){
      Util::log("isle fights for $attacker",1);
      $attack_strength += $::conf->{-FIGHT}->{-ISLE};
    }elsif($occupant == $defender){
      Util::log("isle fights for $defender",1);
      $defend_strength += $::conf->{-FIGHT}->{-ISLE};
    }else{
      Util::log("impossible situation: isle fights for no one!",0);
    }
  }

  Util::log("earthling strength attacker($attacker): ".
	    "$attack_strength, defender($defender): $defend_strength"
	    ,1);

  my $pure_attack_strength = $attack_strength;
  my $pure_defend_strength = $defend_strength;

  #my $attacker_death_count = $attack_strength;
  #my $defender_death_count = $defend_strength;

  my $attacker_death_count = $people_attacker;
  my $defender_death_count = $people_defender;

  Util::log("$people_attacker people fight for attacker $attacker",1);
  Util::log("$people_defender people fight for defender $defender",1);

  my $attacker_godpower = Util::min($people_attacker,$attack_avatar);
  my $defender_godpower = Util::min($people_defender,$defend_avatar);

  Util::log("Gods supports attacker($attacker) with $attacker_godpower",1);
  Util::log("Gods supports defender($defender) with $defender_godpower",1);

  $attack_strength += $attacker_godpower;
  $defend_strength += $defender_godpower;

  # FLANKING
  # if landbattle: look, for all neighbour fields,
  # add flanking power of allies
  my ($flanking_attack,$flanking_defend) = (0,0);
  # if(not $self->{-see_battle} and not $self->{-island_battle}){
  my @neighbours = $self->get_neighbours($self->{-location});
  # COMMENT IN FOR NEW RULE my ($att_neighbours,$def_neighbours) = (0,0);
  # print "neighbours: @neighbours\n";
  for my $n (@neighbours){
    # my $n_string = $n->to_string();
    my ($ter,$occ,$att) = $self->{-context}->
      read_field('TERRAIN,OCCUPANT,ATTACKER',$n);
    next if $ter eq 'WATER'; # dont flank from see
    next if $att > 0; # dont flank from war
    my $attacker_relation = $self->{-context}->read_single_relation($occ,$attacker);
    my $defender_relation = $self->{-context}->read_single_relation($occ,$defender);
    Util::log("flanking ($n): $attacker_relation, $defender_relation, ".
	      "$ter, $occ, $att",1);
    if($occ != $defender and
       ($occ == $attacker or (Util::is_in($attacker_relation,'FRIEND','ALLIED') and not
			      Util::is_in($defender_relation,'FRIEND','ALLIED')))){
      # COMMENT IN FOR NEW RULE $att_neighbours++;
      # COMMENT IN FOR NEW RULE $flanking_attack += $::conf->{-FIGHT}->{-FLANKING} * $att_neighbours;
      $flanking_attack += $::conf->{-FIGHT}->{-FLANKING};
      Util::log("$n flanks for attacker($attacker)",1);
    }elsif($occ and ($occ != $attacker and
	   ($occ == $defender or
	    (not Util::is_in($attacker_relation,'FRIEND','ALLIED')
	     and Util::is_in($defender_relation,'FRIEND','ALLIED'))))){
      # COMMENT IN FOR NEW RULE $def_neighbours++;
      # COMMENT IN FOR NEW RULE  $flanking_defend += $::conf->{-FIGHT}->{-FLANKING} * $def_neighbours;
      $flanking_defend += $::conf->{-FIGHT}->{-FLANKING};
      Util::log("$n flanks for defender($defender)",1);
    }
  }
  Util::log("sum of flanking: $flanking_attack for attacker($attacker) and ".
	    "$flanking_defend for defender($defender) and ",1);
  $attack_strength += $flanking_attack;
  $defend_strength += $flanking_defend;
  #}

  Util::log("sum strength without fortune: $attack_strength for attacker($attacker) ".
	    "and $defend_strength for defender($defender)",1);

  # add random value (1 to GAME.FORTUNE)
  my $fortune = $self->{-context}->read_fortune();
  my $asf = int(rand($fortune))+1;
  my $dsf = int(rand($fortune))+1;
  $attack_strength += $asf;
  $defend_strength += $dsf;
  Util::log("strength with fortune attacker($attacker): ".
	    "$attack_strength, defender($defender): $defend_strength",1);

  #  my @loosers;

  if($attack_strength > $defend_strength){
    $self->{-winner} = $attacker;
    $self->{-looser} = $defender;
    $self->{-winner_death_count} = Util::min($people_attacker - 1,
					     int(0.5 + $defender_death_count /
					     $::conf->{-WINNER_DEATH_COUNT_FRACTION}));
    $self->{-looser_death_count} = Util::max(1,int(0.5 + $attacker_death_count /
					     $::conf->{-LOOSER_DEATH_COUNT_FRACTION}));
    Util::log("Attackers($attacker) won!",1);
    $self->conquer($self->{-location},$attacker);
  }else{
    $self->{-winner} = $defender;
    $self->{-looser} = $attacker;
    $self->{-winner_death_count} = Util::min($people_defender - 1,
					     int(0.5 + $attacker_death_count /
					     $::conf->{-WINNER_DEATH_COUNT_FRACTION}));
    $self->{-looser_death_count} = Util::max(1,int(0.5 + $defender_death_count /
					     $::conf->{-LOOSER_DEATH_COUNT_FRACTION}));
    # $self->{-looser} = $efoa;
    # $self->{-master_looser} = $attacker;
    Util::log("Defenders($defender) won!",1);
  }

  # loosers and helpers run away or die
  $self->run_or_die();

  # erase MAP.ATTACKER
  $self->{-db}->update_hash('MAP',
			    "LOCATION=$self->{-location} AND GAME=$self->{-game}",
			    {'ATTACKER' => 0});

  # reread mobiles
  # $self->{-mobiles} = $self->{-context}->read_mobile('ID',
  # 0, $self->{-location}, 1);

  # unify the mobiles, which are still here
  for my $mob_arr (@$mobiles){
    my ($id,$type,$owner,$count,$status) = @$mob_arr;
    next if exists $self->{-run_or_die}->{$id};
    my $mob = $self->{-db}->read_single_mobile($id);
    $self->unify_mobiles($mob,$self->{-location},$owner) if $mob;
  }

  # sometimes the last ark is gone in battle
  if($terrain eq 'WATER'){
    $self->drowning($self->{-location});
  }

  # send battle-report
  my $name_of_attacker = $self->{-context}->charname($attacker);
  my $name_of_defender = $self->{-context}->charname($defender);
  my $name_of_winner = $self->{-context}->charname($self->{-winner});

  my $text = <<END_OF_TEXT;
  <strong>BATTLE_REPORT $self->{-location}</strong><br>
  <table><tr><th></th><th>$name_of_attacker</th><th>$name_of_defender</th></tr>
  <tr><td>PEOPLE</td><td>$people_attacker</td>
    <td>$people_defender</td></tr>
  <tr><td>FIGHTING_STRENGTH</td><td>$pure_attack_strength</td>
    <td>$pure_defend_strength</td></tr>
  <tr><td>FLANKING</td><td>$flanking_attack</td><td>$flanking_defend</td></tr>
  <tr><td>GODS_HELP</td><td>$attacker_godpower</td><td>$defender_godpower</td></tr>
  <tr><td>LUCK</td><td>$asf</td><td>$dsf</td></tr>
  <tr><td>SUM_OF_STRENGTH</td><td>$attack_strength</td><td>$defend_strength</td></tr>
  <tr><td>DEAD_WARRIORS</td><td>$self->{-dead}->{$attacker}->{'K'}</td>
    <td>$self->{-dead}->{$defender}->{'K'}</td></tr>
  <tr><td>DEAD_HEROS</td><td>$self->{-dead}->{$attacker}->{'H'}</td>
    <td>$self->{-dead}->{$defender}->{'H'}</td></tr>
  <tr><td>DEAD_PRIESTS</td><td>$self->{-dead}->{$attacker}->{'P'}</td>
    <td>$self->{-dead}->{$defender}->{'P'}</td></tr>
  <tr><td>SUNKEN_ARKS</td><td>$self->{-dead}->{$attacker}->{'A'}</td>
    <td>$self->{-dead}->{$defender}->{'A'}</td></tr>
  <tr><td>CONQUERED_ARKS</td><td>$self->{-dead}->{$defender}->{'C'}</td>
    <td>$self->{-dead}->{$attacker}->{'C'}</td></tr>
  </table>
  <strong>WINNER_IS $name_of_winner</strong>.
END_OF_TEXT

  # TODO: we should make shure, that attacker and defender are receivers.
  # could happen, if all dying and no other unit in the neighbourhood
  my @gods = (keys %$gfoa, keys %$gfod);
  $self->{-context}
    ->send_message_to_field
      ($self->{-location},{'MFROM' => 0,
			   'MSG_TEXT' => $text}
	# 'ARG1' => $self->{-context}->charname($attacker),
	# 'ARG2' => $self->{-context}->charname($defender),
	# 'ARG3' => $self->{-context}->charname($self->{-winner}),
	# 'ARG4' => $self->{-location}}
       );
       #,$attacker,$defender,@gods);

  return 0;
}

# FIGHT_EARTHLING
sub run_or_die{
  my($self) = @_;

  # some people have to die
  $self->casualties($self->{-winner},$self->{-winner_death_count});
  $self->casualties($self->{-looser},$self->{-looser_death_count});

  # print Dumper $self->{-dead};

  # reread mobiles
  $self->{-mobiles} = $self->{-context}->read_mobile('ID,TYPE,OWNER,COUNT,STATUS',
						     0, $self->{-location}, 1);

  # the survivors run
  # TODO: no retreat if no survivors
  $self->retreat();

}

sub find_retreat_field{
  my ($self,$retreat_fields) = @_;

  my @retreat_fields = @$retreat_fields;

  # chose one retreat-field
  return $retreat_fields[rand($#retreat_fields +1)];
}

sub retreat_unit{
  my ($self,$unit,$count,$retreat,$type) = @_;

  my $looser = $self->{-looser};

  # calculate direction
  my $dir = $self->{-context}->is_in_direction_from($retreat,
							$self->{-location});

  # retreat via MOVE_WITH if retreat with ark
  if($type ne 'ARK' and exists $self->{-retreat_arks}->{$retreat}){
    my $ark = $self->{-retreat_arks}->{$retreat};
    $self->{-db}->update_hash('MOBILE',
			      "ID=$unit",
			      {'MOVE_WITH' => $ark,
			       'AVAILABLE' => 'N'});
    Util::log("retreat via $ark (MOVE_WITH)",1);
  }else{
    # TODO?: insert event
    $self->{-context}->insert_command('MOVE',
				      "DIR=$dir, MOBILE=$unit, ".
				      "COUNT=$count, AUTO=1",
				      $self->{-location},
				      $looser);	
    Util::log("retreat via MOVE_COMMAND",1);
  }
  Util::log("$looser retreats from $self->{-location} to $retreat ".
	    "in direction $dir with $count people(or ark). Mobile-ID: $unit",1);
  $self->{-run_or_die}->{$unit} = 1;

  $self->{-context}
    ->send_message_to_list
      ({'MFROM' => 0,
	'MSG_TAG' => 'MSG_FIGHT_RETREAT',
	'ARG1' => $self->{-context}->charname($looser),
	'ARG2' => 'PEOPLE_OR_ARK',
	'ARG3' => $self->{-location},
	'ARG4' => $count},$looser,$self->{-winner});

  return $retreat;
}

sub retreat{
  my ($self) = @_;

  my $looser = $self->{-looser};
  Util::log("checking retreats for looser $looser ...",1);

  # remove MOVE_WITH if any
  $self->{-db}->update_hash('MOBILE',
			    "OWNER=$looser AND LOCATION=$self->{-location} AND ".
			    "AVAILABLE=Y",
			    {'MOVE_WITH' => 0});

  # search for retreat-possibilities
  my ($local_terrain) = $self->{-context}->read_field('TERRAIN',$self->{-location});
  my @possible_retreat = $self->{-context}->own_neighbours($self->{-location},$looser);
  my @retreat_fields = ();
  my @retreat_water_fields = ();
  if ($local_terrain eq 'WATER' or $local_terrain eq 'ISLE'){
    @retreat_water_fields = @possible_retreat;
    Util::log("retreat from water: @possible_retreat",1);
  }else{
    Util::log("check retreat for ...",-1);
    for my $field (@possible_retreat){
      Util::log("\n$field ",-1);
      my ($terrain) = $self->{-context}->read_field('TERRAIN',$field);
      if ($terrain eq 'WATER' or $terrain eq 'ISLE'){
	Util::log("... accepted water retreat to $terrain!",1);
	push @retreat_water_fields, $field;
      }else{
	Util::log("... accepted land retreat to $terrain!",1);
	push @retreat_fields, $field;
      }
    }
  }
  # $self->{-retreat_fields} = \@retreat_fields;
  # $self->{-retreat_water_fields} = \@retreat_fields;

  # retreat own arks

  my $have_ark = 0;
  my %arks = ();
  if($#retreat_water_fields >= 0){
    $self->{-retreat_arks} = {}; # TODO Performance: use only hashes, no arrays
    for my $m (@{$self->{-mobiles}}){
      my ($id,$type,$own,$count,$stat) = @$m;
      next unless $type eq 'ARK' and ($own == $self->{-looser});

      my $retreat_field = $self->find_retreat_field(\@retreat_water_fields);
      Util::log("found ark $id from $own for retreat to $retreat_field",1);

      $self->{-retreat_arks}->{$retreat_field} = $id;
      $arks{$id} = $retreat_field;

      if (not Util::is_in($retreat_field,@retreat_fields)){
	push @retreat_fields, $retreat_field;
	Util::log("... accepted retreat through ark $id to $retreat_field!",1);
      }
    }
  }else{
    # all arks change owner to winner
    $self->{-db}->update_hash('MOBILE',
			      "GAME=$self->{-game} AND ".
			      "LOCATION=$self->{-location} AND ".
			      "TYPE=ARK",
			      {'OWNER' => $self->{-winner}});
    Util::log("All arks in $self->{-location} change owner to $self->{-winner}",1);
  }


  # for every unit of this looser
  for my $mob (@{$self->{-mobiles}}){
    my ($id,$type,$own,$count,$stat) = @$mob;
    next unless $own == $looser;
    next if $type eq 'ARK';

    # if there is a way out
    if($#retreat_fields >= 0){
      my $field = $self->find_retreat_field(\@retreat_fields);
      Util::log("checking retreat for mobile $id ".
		"(own: $own, type: $type, count: $count, field: $field)",1);
      $self->retreat_unit($id,$count,$field,$type);
    }else{
      # die!
      $self->{-db}->delete_from('MOBILE',"ID=$id");
      $self->{-run_or_die}->{$id} = 1;

      $self->{-context}
	->send_message_to_field
	  ($self->{-location},
	   {'MFROM' => 0,
	    'MSG_TAG' => 'MSG_FIGHT_RETREAT_DIE',
	    'ARG1' => $self->{-context}->charname($looser),
	    'ARG2' => $type,
	    'ARG3' => $self->{-location},
	    'ARG4' => $count});#,$looser,$self->{-winner});
      Util::log("$looser looses $count $type in $self->{-location}".
		" because there is no place to retreat.",1);
    }
  }
  # MOVE COMMANDS for arks came last because others move with them
  for my $mob (@{$self->{-mobiles}}){
    my ($id,$type,$own,$count,$stat) = @$mob;
    next unless $own == $looser;
    next unless $type eq 'ARK';
    Util::log("checking retreat for mobile $id ".
	      "(own: $own, type: $type, count: $count, ".
	      "via ark $id to field: $arks{$id})",1);

    $self->retreat_unit($id,$count,$arks{$id},$type);
  }
}

sub strength{
  my($self,$type) = @_;

  #  return $::conf->{-SEE_FIGHT}->{"-$type"} if $self->{-naval_battle};
  # return $::conf->{-ISLAND_FIGHT}->{"-$type"} if $self->{-island_battle};
  return $::conf->{-FIGHT}->{"-$type"};
}

#
# End of FIGHT_EARTHLING
#
####################################################

##########################################################
#
# BLESS_HERO
#

package BLESS_HERO;
@BLESS_HERO::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('MOBILE','COUNT');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_mobile($self->{-args}->{'MOBILE'});

  return 0 unless $self->validate_role('GOD');

  my $mobtype = $self->{-mob}->{'TYPE'};
  my $mobloc = $self->{-mob}->{'LOCATION'};
  my $mobcount = $self->{-mob}->{'COUNT'};

  return 0 unless $self->test(sub{$self->{-mob}->{'TYPE'} eq 'WARRIOR'},
			      'MSG_WRONG_TYPE',
			      $self->{-context}->mobile_string($mobtype,1),
			      $mobloc);

  $self->{-count} = $self->{-args}->{'COUNT'} > $mobcount ?
    $mobcount : $self->{-args}->{'COUNT'};

  return 0 unless $self->test_mana('BLESS_HERO',$self->{-count});

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# BLESS_HERO
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();


  my $id = $self->{-mob}->{'ID'};
  $self->conditional_split_mobile($self->{-mob},
				  $self->{-count},
				  {'ADORING' => $self->{-player},
				   'TYPE' => 'HERO',
				   'COMMAND_ID' => $self->{-dbhash}->{'ID'}},
				  'beforeafter');

  # reread mobile, because split destroys it
  $self->{-mob} = $self->{-db}->single_hash_select('MOBILE',"ID=$id");
  $self->unify_mobiles($self->{-mob},
		       $self->{-mob}->{'LOCATION'},
		       $self->{-mob}->{'OWNER'});

#  $self->{-context}
#    ->send_message_to_field
#      ($self->{-mob}->{'LOCATION'},
#       {'MFROM' => 0,
#	'MSG_TAG' => 'MSG_BLESS_HERO',
#	'ARG1' => $self->{-context}->charname($self->{-player}),
#	'ARG2' => $self->{-context}->charname($self->{-mob}->{'OWNER'}),
#	'ARG3' => $self->{-mob}->{'LOCATION'}});

  $self->use_mana();
  $self->setDuration(0);

  return 0;
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  Util::log("BLESS_HERO should not have a second phase!",0);
  return 0;
}

#
# End of BLESS_HERO
#
####################################################

##########################################################
#
# CH_ACTION
#

package CH_ACTION;
@CH_ACTION::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('ACTION','MOBILE');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_mobile($self->{-args}->{'MOBILE'});

  return 0 unless $self->validate_role('GOD');

  my $mobtype = $self->{-mob}->{'TYPE'};
  my $mobloc = $self->{-mob}->{'LOCATION'};

  return 0 unless $self->test(sub{$mobtype eq 'AVATAR'},
			      'MSG_WRONG_TYPE',
			      $self->{-context}->mobile_string($mobtype,1),
			      $mobloc);

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# CH_ACTION
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $mob = $self->{-mob};
  my $loc = $mob->{'LOCATION'};
  my $own = $self->{-player};
  my $action = $self->{-args}->{'ACTION'};

  # all avatars in the field get the new status
  $self->{-db}->update_hash('MOBILE',
			    "LOCATION=$loc AND TYPE=AVATAR AND OWNER=$own ".
			    "AND GAME=$self->{-game} AND AVAILABLE=Y",
			    {'STATUS' => $action});

  $mob->{'STATUS'} = $action;
  $self->enter_field_avatar($loc,$mob) if $action eq 'BLOCK';

#  $self->{-context}
#    ->send_message_to_field
#      ($self->{-mob}->{'LOCATION'},
#       {'MFROM' => 0,
#	'MSG_TAG' => 'MSG_CH_ACTION',
#	'ARG1' => $self->{-args}->{'ACTION'},
#	'ARG2' => $self->{-mob}->{'LOCATION'}});

  $self->setDuration(0);
  return 0;
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  Util::log("CH_ACTION should not have a second phase!",0);
  return 0;
}

#
# End of CH_ACTION
#
####################################################

####################################################
#
# DIE_ORDER: Change the order of mobiletypes which dies in battle
#

package DIE_ORDER;
@DIE_ORDER::ISA  = qw(AymCommand);

sub is_valid{
  my ($self) = @_;

  my @required_arguments = ('DYING');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_role('EARTHLING');

  # TODO: use test with message
  return 0 unless Util::is_in($self->{-args}->{'DYING'},
			      'PKH','PHK','KPH','KHP','HKP','HPK');

  return 1;
}

# DIE_ORDER
sub first_phase{
  my $self = shift;
  return 0 unless $self->is_valid();

  my $dying = $self->{-args}->{'DYING'};

  $self->{-db}->update_hash('EARTHLING',
			    "GAME=$self->{-game} AND ".
			    "PLAYER=$self->{-player}",
			    {'DYING' => $dying});

  $self->{-context}->send_message_to_me({'MFROM' => 0,
					 'MSG_TAG' => 'MSG_DIE_ORDER',
					 'ARG1' => $dying
					});
  Util::log("New die order for player $self->{-player}: $dying",1);

  $self->setDuration(0);
  return 1;
};

sub second_phase{
  my $self = shift;
  Util::log("Warning: We should not reach phase 2 with command DIE_ORDER",0);
  return 0;
};

#
# END of DIE_ORDER
#
################################################################


##########################################################
#
# CH_LUCK
#

package CH_LUCK;
@CH_LUCK::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('BONUS');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_role('GOD');

  return 1 if $self->{-phase} == 2;

  return 0 unless $self->test_mana('CH_LUCK',
		   abs($self->{-args}->{'BONUS'} * $::conf->{-MANA}->{-CH_LUCK}));

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# CH_LUCK
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  $self->use_mana();

  return $self->setDuration($::conf->{-DURATION}->{-CH_LUCK});
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  return 0 unless $self->is_valid();
  my $oldfortune = $self->{-context}->read_fortune();

  my $change = $self->{-args}->{'BONUS'};

  my $newfortune = $oldfortune + $change;
  if($newfortune > $::conf->{-MAX_LUCK}){
    $newfortune =  $::conf->{-MAX_LUCK};
  }elsif($newfortune < $::conf->{-MIN_LUCK}){
    $newfortune =  $::conf->{-MIN_LUCK};
  }

  $self->{-db}->update_hash('GAME',
			    "GAME=$self->{-game}",
			    {'FORTUNE' => $newfortune});

  $self->{-context}
    ->send_message_to_all
      ({'MFROM' => 0,
	'MSG_TAG' => 'MSG_CHANGE_FORTUNE',
	'ARG1' => $self->{-context}->charname($self->{-player}),
	'ARG2' => $oldfortune,
	'ARG3' => $newfortune});


  return 0;
}

#
# End of CH_LUCK
#
####################################################

##########################################################
#
# FLOOD
#

package FLOOD;
@FLOOD::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;
  my $db = $self->{-db};
  my $context = $self->{-context};
  my $loc = $self->{-location};

  my @required_arguments = ();
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_role('GOD');

  # only PLAIN and MOUNTAIN can be flooded
  my ($terrain) = $context->read_field('TERRAIN', $loc);
  return 0 unless $self->test(sub{Util::is_in($terrain,'PLAIN','MOUNTAIN');},
			      'MSG_CANT_FLOOD_TERRAIN',
			      $loc,
			      $terrain);
  $self->{-terrain} = $terrain;

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# FLOOD
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $loc = $self->{-location};

  # need own avatar to flood
  return 0 unless $self->avatar_available($loc);
  return 0 unless $self->test_mana('FLOOD');
  $self->use_mana();

  $self->setDuration($::conf->{-DURATION}->{-FLOOD});

  $self->event($self->{-location},
	       'EVENT_FLOOD',
	       $self->{-player});

  return $self->{-duration};
}

# this is called from scheduler when the command will be executed.
# FLOOD
sub second_phase{
  my $self = shift;
  my $loc = $self->{-location};
  my $db = $self->{-db};

  return 0 unless $self->is_valid();

  # mountain -> isle, plain -> water
  my $new = $self->{-terrain} eq 'MOUNTAIN' ? 'ISLE' : 'WATER';
  $db->update_hash('MAP',"LOCATION=$loc AND GAME=$self->{-game}",
		   {'TERRAIN' => $new});

  # drowning of mobiles if necessary
  $self->drowning($loc);

  # Message
  $self->{-context}
    ->send_message_to_field
      ($loc,{'MFROM' => 0,
	     'MSG_TAG' => 'MSG_FLOOD',
	     'ARG1' => $self->{-context}->charname($self->{-player}),
	     'ARG2' => $loc,
	     'ARG3' => $self->{-terrain},
	     'ARG4' => $new,});

  return 0;
}

#
# End of FLOOD
#
####################################################

##########################################################
#
# DESTROY
#

package DESTROY;
@DESTROY::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;
  my $db = $self->{-db};
  my $context = $self->{-context};
  my $loc = $self->{-location};

  my @required_arguments = ();
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 0 unless $self->validate_role('GOD');

  return 0 unless $self->test_mana('DESTROY');

  # we cant destroy if there is only one temple unbuild
  # TODO: wrong. should be cant destroy, if last temple is under construction
  my $unbuild = $db->count('MAP',
			   "(TERRAIN=ISLE OR TERRAIN=MOUNTAIN) ".
			   "AND TEMPLE=N AND GAME=$self->{-game}");
  return 0 unless $self->test(sub{$unbuild > $::conf->{-MAX_UNBUILD_DESTROY}},
			      'MSG_CANT_RESCUE_WORLD',
			      $unbuild,
			      $loc);

  # need own avatar to destroy
  return 0 unless $self->avatar_available($loc);

  # there sould be no foreign priests
  my $foreign_priests = $db->count('MOBILE',
				   "GAME=$self->{-game} AND ".
				   "LOCATION=$loc AND TYPE=PRIEST AND ".
				   "ADORING!=$self->{-player} AND ".
				   "AVAILABLE=Y");
  return 0 unless $self->test(sub{$foreign_priests == 0},
			      'MSG_CANT_DESTROY_DEFENDED',
			      $loc);

  my ($terrain,$temple,$home) = $context->read_field('TERRAIN,TEMPLE,HOME',
						     $loc);

  # only if temple exists
  return 0 unless $self->test(sub{$temple eq 'Y'},
			      'MSG_NO_TEMPLE_TO_DESTROY',
			      $loc);

  # only destroy foreign temples
  return 0 unless $self->test(sub{$home != $self->{-player}},
			      'MSG_CANT_DESTROY_OWN',
			      $loc);
  $self->{-oldgod} = $home;

  # only on islands
  return 0 unless $self->test(sub{$terrain eq 'ISLE'},
			      'MSG_CANT_DESTROY_MOUNTAINS',
			      $loc);

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# DESTROY
sub first_phase{
  my $self = shift;
  my $loc = $self->{-location};

  return 0 unless $self->is_valid();

  $self->use_mana();

  $self->{-db}->update_hash('MAP',
			    "LOCATION=$loc AND GAME=$self->{-game}",
			    {'TEMPLE' => 'N',
			     'HOME' => 0});

  # delete PRAY- and PRODUCE-commands and PRODUCE-PRIEST event
  $self->{-db}->delete_from('COMMAND',
			    "(COMMAND=PRODUCE OR COMMAND=PRAY) ".
			    "AND LOCATION=$loc AND GAME=$self->{-game}");
  $self->{-db}->delete_from('EVENT',
			    "TAG=EVENT_PRODUCE_PRIEST ".
			    "AND LOCATION=$loc AND GAME=$self->{-game}");

  $self->{-context}
    ->send_message_to_field
      ($loc,
       {'MFROM' => 0,
	'MSG_TAG' => 'MSG_TEMPLE_DESTROYD',
	'ARG1' => $loc,
	'ARG2' => $self->{-context}->charname($self->{-oldgod}),
	'ARG3' => $self->{-context}->charname($self->{-player})
       });

  Util::log("Temple of $self->{-oldgod} destroyed in $self->{-location}",1);

  $self->setDuration(0);

  return 0;
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  Util::log("DESTROY should not have a second phase!",0);
  return 0;
}

#
# End of DESTROY
#
####################################################

##########################################################
#
# MOVE_WITH
#

package MOVE_WITH;
@MOVE_WITH::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('MOBILE','COUNT','TARGET');
  return 0 unless $self->Command::is_valid(@required_arguments);

  my $args = $self->{-args};
  my $count = $args->{'COUNT'};

  # TODO: more messages
  # read mobile
  return 0 unless $self->validate_mobile($args->{'MOBILE'});
  my $mob = $self->{-mob};

  # arks cant move with other units
  return 0 if $self->{-mob}->{'TYPE'} eq 'ARK';

  return 0 unless $self->test(sub {$count <= $mob->{'COUNT'} and
				       $mob->{'AVAILABLE'} eq 'Y'},
				'MSG_NOT_ENOUGH_MOBILES',
				'MOVE',
				$count,
				$mob->{'LOCATION'});

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# MOVE_WITH
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $args = $self->{-args};

  $self->move_with($args->{'MOBILE'},$args->{'TARGET'},$args->{'COUNT'});

  return 0;
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  Util::log("MOVE_WITH should not have a second phase!",0);
  return 0;
}

#
# End of MOVE_WITH
#
####################################################

##########################################################
#
# SEND_MSG
#

# TODO: should be in FROGS/Command.pm

package SEND_MSG;
@SEND_MSG::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('OTHER','MESSAGE');
  return 0 unless $self->Command::is_valid(@required_arguments);

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# MOVE_WITH
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $args = $self->{-args};

  Util::log("send message from $self->{-player} to $args->{'OTHER'}.",1);

  my $msg = $args->{'MESSAGE'};

  # uggly workaround necessary for Command::parse_args()
  $msg =~ s/__COMMA__/,/g;
  $msg =~ s/__EQUAL__/=/g;
  # newline should be in html
  $msg =~ s/\\r\\n/<br>/g;

  $self->{-context}->send_message_to($args->{'OTHER'},
				     {'MFROM' => $self->{-player},
				      'MSG_TEXT' => $msg});

  return 0;
}

# this is called from scheduler when the command will be executed
sub second_phase{
  my $self = shift;
  Util::log("SEND_MSG should not have a second phase!",0);
  return 0;
}

#
# End of SEND_MSG
#
####################################################

##########################################################
#
# FIGHT_GOD
#

package FIGHT_GOD;
use Data::Dumper;
@FIGHT_GOD::ISA = qw(AymCommand);

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('A','B');
  return 0 unless $self->Command::is_valid(@required_arguments);

  my $A = $self->{-args}->{'A'};
  my $B = $self->{-args}->{'B'};
  my $loc = $self->{-dbhash}->{'LOCATION'};

  # dont accept a new FIGHT_GOD if there is allready a fight between the same gods
  my $fights = $self->{-db}->select_array('COMMAND','ARGUMENTS',
					  "GAME=$self->{-game} AND ".
					  "COMMAND=FIGHT_GOD AND ".
					  "ID != $self->{-dbhash}->{'ID'} AND ".
					  "LOCATION=$loc");
  for my $f (@$fights){
    my $args = $self->parse_args($f->[0]);

    if( $args->{'A'} == $A and $args->{'B'} == $B){
      Util::log("there is allready such a fight between $A and $B in $loc.",1);
      return 0;
    }
  }

  # could not work, command can be inserted from earthling.
  # return 0 unless $self->validate_role('GOD');

  # return 0 unless $self->validate_this_role($self->{-args}->{'A'},'GOD');
  # return 0 unless $self->validate_this_role($self->{-args}->{'B'},'GOD');

  return 1;
}

# this is called from Scheduler, if he sees the command the
# first time, some commands execute here immidiatly.
# FIGHT_GOD
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # calculate duration
  $self->setDuration($::conf->{-DURATION}->{-FIGHT_GOD});

  # set GOD_ATTACKER in MAP to COMMAND.ID
  $self->{-db}->update_hash('MAP',
			    "LOCATION=$self->{-location} AND ".
			    "GAME=$self->{-game}",
			    {'GOD_ATTACKER' => $self->{-dbhash}->{'ID'}});

  $self->event($self->{-location},
	       'EVENT_FIGHT_GOD',
	       $self->{-context}->charname($self->{-args}->{'A'}),
	       $self->{-context}->charname($self->{-args}->{'B'}),
	      );

  return $self->{-duration};
}

# this is called from scheduler when the command will be executed.
# FIGHT_GOD
sub second_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  # read info from map
  my ($earthlingfight,$earthling);
  ($earthlingfight, $self->{-god_attacker}, $earthling) = 
	$self->{-context}->read_field(
		'ATTACKER,GOD_ATTACKER,OCCUPANT', $self->{-location}
	);

  # suspend FIGHT until end of FIGHT_GOD if any
  # REWRITE: suspend of avatar fight have to be encapsulated
  if($earthlingfight){
	## REWRITE: SQL: sort events up to time, limit output to ONE
    # read all earthling-events for this field.
    my @events = @{$self->{-db}->select_array('EVENT','ID,TIME',
					      "GAME=$self->{-game} AND ".
					      "LOCATION=$self->{-location} AND ".
					      "TAG=FIGHT_EARTHLING")};
    # which one is the latest?
    my ($late_time, $late_id) = (0,0);
    for my $ev (@events){
      my ($id, $time) = @$ev;
      my $ev_time = &::str2time($time,'GMT');
      Util::log("found FIGHT_EARTHLING with time $time",1);
      ($late_time, $late_id) = ($ev_time, $id) if $ev_time > $late_time;
    }

    # insert new godfight with one second more.
    # TODO: use here the new AFTER-System instead
    my ($year,$month,$day, $hour,$min,$sec) = &::Time_to_Date($late_time + 1);
    $late_time = sprintf ("%04u-%02u-%02u %02u:%02u:%02u",
			  $year,$month,$day, $hour,$min,$sec);
    Util::log("found earthling fight! suspend godfight until $late_time",1);
    $self->{-context}->insert_command('FIGHT_GOD',
				      "A=$self->{-args}->{'A'}, ".
				      "B=$self->{-args}->{'B'}",
				      $self->{-location},
				      $self->{-player},
				      $late_time);
    $self->{-db}->update_hash('EVENT',
			      "COMMAND_ID=$self->{-dbhash}->{'ID'}",
			      {'TIME' => $late_time});
    $self->stop_fight();
    return 0;
  }

  # get all mobiles here
  my $mobiles = $self->{-context}->read_mobile_condition(
	'ID,OWNER,COUNT,TYPE',
	"LOCATION=$self->{-location} "."AND AVAILABLE=Y"
  );
  $self->{-mobiles} = $mobiles;

  my $A = $self->{-args}->{'A'};
  my $B = $self->{-args}->{'B'};
  my ($avatars_A, $avatars_B) = (0,0);

  # for every avatar-unit in the field
  # REWRITE: this block tries to count the opposing avatars: simplify!
  for my $a (@$mobiles){
    my ($id,$own,$count,$type) = @$a;
    next unless $type eq 'AVATAR';

    Util::log("found $count avatar(s) from $own with id $id",1);

    # determine side of owner
    my $side = $self->which_side($own);

    # calculate strength_of_side
    if($side eq 'A'){
      $avatars_A += $count;
    }elsif($side eq 'B'){
      $avatars_B += $count;
    }
  }

  my $mana = $::conf->{-MANA}->{-FIGHT_AVATAR};
  my $mana_A = $self->instant_use_mana($mana,$A);
  my $mana_B = $self->instant_use_mana($mana,$B);
  my $strength_A = $avatars_A * $::conf->{-FIGHT}->{-AVATAR};
  my $strength_B = $avatars_B * $::conf->{-FIGHT}->{-AVATAR};

  # TODO?: message in this case
  unless($mana_A >= $mana){
    Util::log("$A has not enough mana left to fight",1);
    $strength_A = 0;
  };
  unless($mana_B >= $mana){
    Util::log("$B has not enough mana left to fight",1);
    $strength_B = 0;
  };

  # swl: Strength_Without_Luck  strenght_X: Strenght_with_luck
  my ($swlA,$swlB) = ($strength_A,$strength_B);

  # add random value (1 to GAME.FORTUNE)
  my $fortune = $self->{-context}->read_fortune();
  Util::log("avatarfight in $self->{-location}: strength without fortune player $A: ".
	    "$strength_A, player $B: $strength_B",1);
  $strength_A += int(rand($fortune))+1;
  $strength_B += int(rand($fortune))+1;
  Util::log("strength with fortune player $A: ".
	    "$strength_A, player $B: $strength_B",1);

  # how much avatars should die?
  my ($dead_A,$dead_B) = (0,0);
  my ($winner,$looser) = (0,0);

  if( ($strength_A > $strength_B  &&  $mana_A) or
		$mana_A  &&  !$mana_B )
  {
    Util::log("$A wins!",1);
    $winner = $A; $looser = $B;
	($dead_A, $dead_B) = _calc_dead_avatars($avatars_A, $avatars_B);
  }
  elsif( ($strength_B > $strength_A  &&  $mana_B) or
		$mana_B  &&  !$mana_A )
  {
    Util::log("$B wins!",1);
    $winner = $B; $looser = $A;
	($dead_B, $dead_A) = _calc_dead_avatars($avatars_B, $avatars_A);
  }
  else
  {
    Util::log("Both sides looses!",1);
	($dead_A, $dead_B) = _calc_dead_avatars($avatars_A, $avatars_B, 'drawn');
  }

  my ($new_heros_A, $new_heros_B) = (0,0);
  $new_heros_A = $self->die($A, $dead_A, $earthling) if $dead_A;

  # re-read mobiles
  $self->{-mobiles} = $self->{-context}->
    read_mobile_condition('ID,OWNER,COUNT,TYPE',
			  "LOCATION=$self->{-location} ".
			  "AND AVAILABLE=Y");

  $new_heros_B = $self->die($B,$dead_B,$earthling) if $dead_B;

  # surviving loosers go home
  if($looser){
    $self->teleport($looser);
  }else{
    # both sides are looser!
    $self->teleport($A);
    $self->teleport($B);
  }

  $self->stop_fight();

  my $earthling_name = $self->{-context}->charname($earthling);
  my $name_of_A = $self->{-context}->charname($A);
  my $name_of_B = $self->{-context}->charname($B);
  my $asf = $strength_A - $swlA;
  my $dsf = $strength_B - $swlB;
  $winner = $winner ? $self->{-context}->charname($winner) : 'NOBODY';

  my $text = <<END_OF_TEXT;
  <strong>BATTLE_REPORT $self->{-location}</strong><br>
  <table><tr><th></th><th>$name_of_A</th><th>$name_of_B</th></tr>
  <tr><td>MOBILE_AVATAR_PL</td><td>$avatars_A</td><td>$avatars_B</td></tr>
  <tr><td>FIGHTING_STRENGTH</td><td>$swlA</td>
    <td>$swlB</td></tr>
  <tr><td>LUCK</td><td>$asf</td><td>$dsf</td></tr>
  <tr><td>SUM_OF_STRENGTH</td><td>$strength_A</td><td>$strength_B</td></tr>
  <tr><td>DEAD_AVATARS</td><td>$dead_A</td>
    <td>$dead_B</td></tr>
  <tr><td>NEW_HEROS $earthling_name</td><td>$new_heros_A</td>
    <td>$new_heros_B</td></tr>
  </table>
  <strong>WINNER_IS $winner</strong>.
END_OF_TEXT

  $self->{-context}->send_message_to_field(
		$self->{-location},
		{'MFROM' => 0, 'MSG_TEXT' => $text}
  );
}

# _calc_dead_avatars
# Calculates number of dead avatars on winner's and looser's side.
#
# Parameters:
# 	- # winner avatars
# 	- # looser avatars
# 	- drawn				[OPTIONAL, boolean]
#
# Returns:
# 	- # dead winner avatars
# 	- # dead looser avatars
#
sub _calc_dead_avatars
{
	my ($winner, $looser, $drawn) = @_;
	my ($dead_winner, $dead_looser) = (0,0);

	# the winner counts as looser if the fight is drawn!
	if (defined $drawn  &&  $drawn)
	{
		$dead_winner = Util::max(
			1,
			int(0.5 + $looser / $::conf->{-LOOSER_AVATARS_DYING_FRACTION})
		);
	}
	else
	{
		$dead_winner = Util::min(
			$winner - 1,
			int(0.5 + $looser / $::conf->{-WINNER_AVATARS_DYING_FRACTION})
		);
	}

	$dead_looser = Util::max(
		1,
		int(0.5 + $winner / $::conf->{-LOOSER_AVATARS_DYING_FRACTION})
	);

	# ensure that there not dying more avatars than existing
	$dead_looser = $dead_looser > $looser ? $looser : $dead_looser;
	$dead_winner = $dead_winner > $winner ? $winner : $dead_winner;

	return ($dead_winner, $dead_looser);
}



# set MAP.GOD_ATTACKER to 0, if there is our own command-ID
sub stop_fight{
  my($self) = @_;

  my $own_command = $self->{-dbhash}->{'ID'};
  if($own_command == $self->{-god_attacker}){
    $self->{-db}->update_hash('MAP',
			      "LOCATION=$self->{-location} AND ".
			      "GAME=$self->{-game}",
			      {'GOD_ATTACKER' => 0});
  }
}


# teleports all of $god from $loc to location of avatar-creation
sub teleport{
  my($self,$god) = @_;
  my $loc = $self->{-location};

  # teleport surviving avatars of looser to home
  my $home = $self->{-context}->incarnation_place($god);
  Util::log("We teleport all Avatars of $god from $loc to $home.",1);

  $self->{-db}->update_hash('MOBILE',
			    "TYPE=AVATAR AND OWNER=$god AND AVAILABLE=Y AND ".
			    "LOCATION=$self->{-location}",
			    {'LOCATION' => $home});

  # get all avatar there
  my $avatars = $self->{-context}->read_mobile_condition('ID',
							 "LOCATION=$home ".
							 "AND OWNER=$god ".
							 "AND TYPE=AVATAR ".
							 "AND AVAILABLE=Y");
  # dont call this more than one time!
  #for my $avat (@$avatars){
    my ($id) = $avatars->[0]->[0];
    $self->enter_field_avatar($home,$id);
  #}
}


# kills $to_kill avatars of owner in location and create heros for earthling,
# if possible
sub die{
  my ($self,$owner,$to_kill,$earthling) = @_;
  Util::log("$to_kill avatars from $owner dying.",1);

  my $loc = $self->{-location};
  my $mobiles = $self->{-mobiles};

  my $to_hero = $to_kill;
  my $real_to_hero = 0;
  for my $a (@$mobiles){
    my ($id,$own,$count,$type) = @$a;
    if($own eq $owner and $to_kill){
      if($count <= $to_kill){
	$self->{-db}->delete_from('MOBILE', "ID=$id");
	$to_kill -= $count;
	# last unless $to_kill > 0;
      }else{
	$self->{-db}->update_hash('MOBILE', "ID=$id", {'COUNT' => ($count - $to_kill)});
	$to_kill = 0;
	# last;
      }
      # add the strength of the death avatar to gods last battle
      #my ($actual) = $self->{-db}->single_select("SELECT DEATH_AVATAR FROM GOD WHERE ".
      #"GAME=$self->{-game} AND ".
      #     #						 "PLAYER=$owner");
      #     Util::log("AVATAR dying: adds strength to last-battle-strength of $owner",1);
      #       $self->{-db}->update_hash('GOD',
      # 				"GAME=$self->{-game} AND PLAYER=$owner",
      # 				{'DEATH_AVATAR' => $actual + 1});

      #       $self->{-context}
      # 	->send_message_to
      # 	  ($loc,$owner,
      # 	   {'MFROM' => 0,
      # 	    'MSG_TAG' => 'MSG_AVATAR_DEAD',
      # 	    'ARG1' => $loc,
      # 	    'ARG2' => $self->{-context}->charname($owner)});
      #     Util::log("One avatar of $owner died in $loc.",1);
      #     last;
    }elsif($own eq $earthling and $type eq 'WARRIOR' and $to_hero){
      if($count <= $to_hero){
	$self->{-db}->delete_from('MOBILE', "ID=$id");
	$to_hero -= $count;
	$real_to_hero += $count;
	# last unless $to_hero > 0;
      }else{
	$self->{-db}->update_hash('MOBILE', "ID=$id", {'COUNT' => $count-$to_hero});
	$real_to_hero += $to_hero;
	$to_hero = 0;
	# last;
      }
    }
    last if $to_kill <= 0 and $to_hero <= 0;
  }

  if($real_to_hero){
    my $id = $self->{-db}->find_first_free('MOBILE','ID');
    my $mob = {'ID' => $id,
	       'GAME' => $self->{-game},
	       'LOCATION' => $self->{-location},
	       'TYPE' => 'HERO',
	       'OWNER' => $earthling,
	       'COUNT' => $real_to_hero,
	       'ADORING' => $owner,
	       'AVAILABLE' => 'Y',
	       'COMMAND_ID' => $self->{-dbhash}->{'ID'},
	      };
    # $self->{-mob} = $mob;
    my %mobcopy = (%$mob);
    $self->{-db}->insert_hash('MOBILE',\%mobcopy);
    $self->unify_mobiles($id,$self->{-location},$earthling);
    Util::log("$real_to_hero warriors from $earthling blessed to hero",1);
  }
  return $real_to_hero;
}

# this function decides on which side other gods fight
# TODO: do we really need this complicated stuff
sub which_side{
  my($self,$own) = @_;

  my $A = $self->{-args}->{'A'};
  my $B = $self->{-args}->{'B'};

  my $side = '0';
  $side = 'A' if $own == $A;
  $side = 'B' if $own == $B;

  if ($side eq '0') {
    my $allA = $self->{-context}->simplyfied_single_relation($own,$A);
    my $allB = $self->{-context}->simplyfied_single_relation($own,$B);
    if ($allA eq $allB) {
      $side = '0';
    } elsif ($allA eq 'FRIEND') {
      $side = 'A';
    } elsif ($allB eq 'FRIEND') {
      $side = 'B';
    } elsif ($allA eq 'FOE') {
      $side = 'B';
    } elsif ($allB eq 'FOE') {
      $side = 'A';
    }
  }
  return $side;
}

#
# End of FIGHT_GOD
#
####################################################

##########################################################
#
# PLAGUE
#

package PLAGUE;
@PLAGUE::ISA = qw(AymCommand);
use Data::Dumper;

# this is called to see if the command is executable.
# it should be called from first_phase() and from second_phase().
# it is not called from the scheduler
sub is_valid {
  my $self = shift;

  my @required_arguments = ('TYPE');
  return 0 unless $self->Command::is_valid(@required_arguments);

  # test role god
  return 0 unless $self->validate_role('GOD');

  # test known plagues
  unless(Util::is_in($self->{-args}->{'TYPE'},@{$::conf->{-PLAGUES}})){
    Util::log("wrong type of plague: $self->{-args}->{'TYPE'}",0);
    return 0;
  }

  return 1;
}

# this is called from Scheduler, if he see the command the
# first time, some commands execute here immidiatly.
# PLAGUE
sub first_phase{
  my $self = shift;

  return 0 unless $self->is_valid();

  my $args = $self->{-args};
  my $loc = $self->{-dbhash}->{'LOCATION'};
  my $type = $args->{'TYPE'};
  my $spread = $args->{'SPREAD'};
  my $context = $self->{-context};

  my ($plague,$terrain) = $context->read_field('PLAGUE,TERRAIN', $loc);
  $plague = '' unless defined $plague;

  Util::log("old plague: $plague",1);

  # if plagu not allready here
  unless($plague =~ /$type/){

    if(not $spread){
      # need own avatar to plague
      return 0 unless $self->avatar_available($loc);

      if($self->test_mana($type,1)){
	$self->use_mana();
      }else{
	return 0;
      }
    }
    Util::log("new plague in $loc: $type",1);

    # set plague in MAP
    my $new_plague = $plague ? "$plague,$type" : $type;
    $self->{-db}->update_hash('MAP',
			      "GAME=$self->{-game} AND ".
			      "LOCATION=$loc",
			      {'PLAGUE' => $new_plague});
  }else{
    Util::log("plague $type is allready in $loc.",1);
    # stop if there is another plague command in location of same type.
    # TODO: simplify this with a LIKE-clause,
    # but: we have to rewrite quote_condition() first :-(
    my $commands = $self->{-db}->select_array('COMMAND',
					      'ARGUMENTS,ID',
					      "COMMAND=PLAGUE AND ".
					      "GAME=$self->{-game} AND ".
					      "LOCATION=$loc AND ".
					      "ID != $self->{-dbhash}->{'ID'}");
    for my $c (@$commands){
      my ($args,$id) = @$c;
      # next if $id == $self->{-dbhash}->{'ID'};
      if($args =~ /$type/){
	Util::log("There is allready another PLAGUE-command of $type in $loc",1);
	return 0;
      }
    }
  }

  $self->setDuration($::conf->{-DURATION}->{-PLAGUE});
  return $self->{-duration};
}

# this is called from scheduler when the command will be executed
# PLAGUE
sub second_phase{
  my $self = shift;
  my $loc = $self->{-dbhash}->{'LOCATION'};
  my $type = $self->{-args}->{'TYPE'};
  my $context = $self->{-context};

  # heal plague with priests
  my $priests = $context->count_mobile('PRIEST',$loc);
  my $heal_prob = $priests ? 1 - 1/$priests * $::conf->{-HEAL_PLAGUE} : 0;
  Util::log("Heal probability: $heal_prob",1);
  if($heal_prob > rand(1)){
    Util::log("heal plague of type $type in $loc",1);
    my ($plague) = $context->read_field('PLAGUE,TERRAIN', $loc);
    if(defined $plague){
      $plague =~ s/$type//;
      $self->{-db}->update_hash('MAP',
				"GAME=$self->{-game} AND LOCATION=$loc",
				{'PLAGUE' => $plague});
    }
  }else{
    # spread plague to neighbour-fields
    my @neighbours = $self->get_neighbours();
    for my $field (@neighbours){
      my ($terrain,$owner) = $context->read_field('TERRAIN,OCCUPANT',$field);
      # $self->{-occ} = $owner;
      if(rand(1) < $::conf->{-SPREAD_PLAGUE}->{$terrain}){
	Util::log("spread $type from $loc to $field",1);
	$context->insert_command('PLAGUE',"TYPE=$type, SPREAD=1",$field);
      }
    }

    $self->effect();
    $self->do_it_again({'SPREAD' => 1});
  }

  return 0;
}

# PLAGUE
sub effect{
  my $self = shift;
  my $context = $self->{-context};

  my $type = $self->{-args}->{'TYPE'};
  Util::log("Do effect of type $type.",1);

  my $loc = $self->{-dbhash}->{'LOCATION'};

  # effect of INFLUENZA is done in PRODUCE
  if($type eq 'PESTILENTIA'){
    my ($vic) = $context->read_field('OCCUPANT',$loc);;

    # count people of owner in field
    my $people = $context->count_people($loc,$vic);
    $people = 0 unless defined $people;
    Util::log("$people people from $vic counted in $loc.",1);
    my $victims = int($people * $::conf->{-PESTILENTIA_DEATH_SHARE});
    Util::log("$victims from them have to die.",1);
    return unless $victims;

    $self->{-mobiles} = $context->read_mobile('ID,TYPE,OWNER,COUNT,STATUS',
						 0, $self->{-location}, 1);

    $self->casualties($vic,$victims,1);

    # send message
    my $name_of_victim = $context->charname($vic);
    my $text = <<END_OF_TEXT;
  <strong>CASUALTIES_OF_PESTILENTIA $self->{-location} $name_of_victim</strong><br>
  <table><tr><th></th><th></th></tr>
  <tr><td>DEAD_WARRIORS</td><td>$self->{-dead}->{$vic}->{'K'}</td></tr>
  <tr><td>DEAD_HEROS</td><td>$self->{-dead}->{$vic}->{'H'}</td></tr>
  <tr><td>DEAD_PRIESTS</td><td>$self->{-dead}->{$vic}->{'P'}</td></tr>
  <tr><td>SUNKEN_ARKS</td><td>$self->{-dead}->{$vic}->{'A'}</td></tr>
  </table>
END_OF_TEXT

  $context->send_message_to_field
    ($self->{-location},{'MFROM' => 0,
			 'MSG_TEXT' => $text}
     # 'ARG1' => $self->{-context}->charname($attacker),
     # 'ARG2' => $self->{-context}->charname($defender),
     # 'ARG3' => $self->{-context}->charname($self->{-winner}),
     # 'ARG4' => $self->{-location}}
    );
    #,$attacker,$defender,@gods);
  }else{
    Util::log("no effect",1);
  }
}

#
# End of PLAGUE
#
####################################################
# vim: set ts=4
