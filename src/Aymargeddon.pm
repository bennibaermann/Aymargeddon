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

# generell Aymargeddon-specific functions
#


# TODO: move color calculation from map.epl in this module


use strict;
use FROGS::Game;
use FROGS::HexTorus;

package Aymargeddon;
use Data::Dumper;
@Aymargeddon::ISA = qw(Game);

sub new{
  my ($class,$game,$user,$db,$lang) = @_; #TODO: $lang not used here?

  my $self = Game->new($game,$user,$db);

  bless($self,$class);
}

sub get_map{
  my $self = shift;
  
  unless (exists $self->{-map}){
      #TODO: HOME dupplication correct?
      $self->{-map} = $self->read_map("TERRAIN,HOME,OCCUPANT,TEMPLE,PLAGUE,HOME");
  }
  return $self->{-map};
}

sub get_size{
  my $self = shift;

  unless ($self->{-size}){
    my @size = $self->{-db}->read_game($self->{-game},'SIZE');
    $self->{-size} = $size[0] ? $size[0] : die "could not find size";
  }
  return $self->{-size};
}

sub get_relation{
  my ($self, $other) = @_;

  unless ($self->{-rel}){
    # print "bindrin\n";
    #    $self->{-rel} = $self->read_player_relations($self->{-game}, $self->{-user});
    $self->{-rel} = $self->read_player_relations($self->{-user});
  }
  #  print Dumper $self->{-rel};
  my $stat = $self->{-rel}->{$other}->{'STATUS'};
  return $stat ? $stat : 'NEUTRAL';
}

# FRIEND, ALLIED => FRIEND ; FOE, BETRAY => FOE
sub simplyfied_single_relation{
  my ($self,$me,$you) = @_;
  my $rel = $self->read_single_relation($me,$you);

  return 'FRIEND' if Util::is_in($rel,'FRIEND','ALLIED');
  return 'FOE' if Util::is_in($rel,'FOE','BETRAY');
  return 'NEUTRAL';
}


sub god_fight{
  my ($self,$loc_str) = @_;
  my @ret = $self->read_field('GOD_ATTACKER',$loc_str);
  return $ret[0] ? 1 : 0;
}

sub earthling_fight{
  my ($self,$loc_str) = @_;
  my @ret = $self->read_field('ATTACKER',$loc_str);
  return $ret[0] ? 1 : 0;
}

sub arc_present{
  my ($self,$loc_str) = @_;
  my $arks_ref = $self->read_mobile('ID','ARK',$loc_str,1);
  my @arks = @$arks_ref;
  return $#arks+1;
}

sub avatar_present{
  my ($self,$loc_str) = @_;
  return $self->read_mobile('OWNER','AVATAR',$loc_str,1);
}

sub mobiles_available{
  my ($self,$loc_str,$avail) = @_;
  $avail = 1 unless defined $avail;
  my $fields = 'ID, TYPE, OWNER, ADORING, COUNT, STATUS, MOVE_WITH';
  return $self->read_mobile($fields,'',$loc_str, $avail);
}


#
# sight stuff
#
# TODO: maybe the generell sight-stuff could go to Game.pm

# ATTENTION: this function generates the whole sight-matrix, if necessary.
# it could be very time-consuming
sub player_see_field{
  my ($self,$loc) = @_;

  my @players = $self->get_all_roles();

  my @ret = ();
  for my $player (@players){
    # ($player) = @$player;
    my $players_aym = new Aymargeddon($self->{-game},$player,
				      $self->{-db},$self->{-lang});
    if ($players_aym->sight_of_field($loc)){
      push @ret, $player;
      # print "$player sees $loc.\n";
    }
  }
  return @ret;
}

# this two functions reads sight directly from database
sub sight_of_field{
  my ($self,$loc) = @_;

  return 1 if $self->role($self->{-user}) eq 'OBSERVER'; # admin sees all

  my $player = $self->{-user};
  my $map = HexTorus->new($self->get_size());
  return 1 if $self->sight_of_field_of_player($loc,$player,$map);

  # read all players, which give us informations
  my $rel = $self->reverse_player_relations();
  for my $friend (keys %$rel){
    my $status = $rel->{$friend}->{'STATUS'};
    if($status eq 'ALLIED' or $status eq 'BETRAY'){
      if($self->is_earthling($friend) or $::conf->{-GODS_SHOW_EARTHLINGS}){
	return 1 if $self->sight_of_field_of_player($loc,$friend,$map);
      }
    }
  }
  return 0;
}

sub sight_of_field_of_player{
  my ($self,$loc,$player,$map) = @_;

  my ($ter,$own,$occ,$temple) = $self->read_field('TERRAIN,HOME,OCCUPANT,TEMPLE',$loc);

  return 1 if($own == $player or $occ == $player);
  return 1 if @{$self->own_in_mobile($loc,$player)};

  my $location = Location->from_string($loc);
  my $dist = 2;
  my @neighbours = $map->distant_neighbours($location,$dist);
  # Util::log("neighbours: ",-2);
  for my $l (@neighbours){
    my $d = $map->distance($location,$l);
    my $locstring = $l->to_string();
    # Util::log(" $locstring ($d),",-2);

    my ($neighbour_ter,$neighbour_home) = $self->read_field('TERRAIN,HOME',$locstring);
    next if ($d > 1 && $neighbour_ter ne 'MOUNTAIN');
    return 1 if $neighbour_home == $player;
    return 1 if $neighbour_ter eq 'MOUNTAIN' and
      $neighbour_home <= 0 and $self->is_god($player);
    return 1 if @{$self->own_in_mobile($locstring,$player)};
  }
  # Util::log("",2);
  return 0;
}

# this function generates the whole sight if called
sub sight{
  my ($self,$loc_str) = @_;

  return 1 if $self->role($self->{-user}) eq 'OBSERVER'; # admin sees all

  $self->generate_sight() unless $self->{-sight_map};

  return 1 if $self->{-sight_map}->{$loc_str};
}

# overloads the function from Game-Class
sub seen_locations{
  my $self = shift;

  # TODO-PERFORMANCE: make map a self-constructing member of class (like size)
  my $map = HexTorus->new($self->get_size());

  my @ret = ();
  for my $loc ($map->get_all()){
    my $ls = $loc->to_string();
    push @ret, $ls if $self->sight($ls);
  }
  return @ret;
}

sub generate_sight{
  my ($self) = @_;

  delete $self->{-sight_map};

  my $rel = $self->reverse_player_relations();

  $self->sight_of_player($self->{-user});
  for my $player (keys %$rel){
    my $status = $rel->{$player}->{'STATUS'};
    if($status eq 'ALLIED' or $status eq 'BETRAY'){
      if($self->is_earthling($player) or $::conf->{-GODS_SHOW_EARTHLINGS}){
	$self->sight_of_player($player);
      }
    }
  }

  # print Dumper $self->{-sight_map};
}

sub sight_of_player{
  my ($self,$player) = @_;

  my $map = HexTorus->new($self->get_size());

  my $selfmap = $self->get_map();

  for my $row (@$selfmap){
    my ($loc,$ter,$own,$occ,$temple,$plague,$home) = @$row;

    if($own == $player or $occ == $player
       or @{$self->own_in_mobile($loc,$player)}
       or ($self->is_god($player) and $ter eq 'MOUNTAIN' and $home <= 0)){
      $self->{-sight_map}->{$loc} = 1;
      my $location = Location->from_string($loc);
      my $dist = 1;
      $dist = 2 if $ter eq 'MOUNTAIN';
      my @neighbours = $map->distant_neighbours($location,$dist);
      for my $l (@neighbours){
	$self->{-sight_map}->{$l->to_string()} = 1;
      }
    }
  }
}

sub is_coast{
  my ($self,$loc_str) = @_;
  my ($ter) = $self->read_field('TERRAIN',$loc_str);
  return 0 if($ter ne 'PLAIN' and $ter ne 'CITY' and $ter ne 'MOUNTAIN');

  my $map = HexTorus->new($self->get_size());
  my @neighbours = $map->neighbours(Location->from_string($loc_str));
  for my $loc (@neighbours){
    ($ter) = $self->read_field('TERRAIN',$loc->to_string());
    return 1 if($ter eq 'ISLE' or $ter eq 'WATER');
  }
  return 0;
}

sub is_arrival{
  my ($self, $loc_str) = @_;

  return 1 if $loc_str eq $self->incarnation_place();

  return 0;
}

sub is_god{
  my ($self,$player) = @_;
  $player = $self->{-user} unless defined $player;
  return ($self->role($player) eq 'GOD');
}

sub is_earthling{
  my ($self,$player) = @_;
  $player = $self->{-user} unless defined $player;
  return ($self->role($player) eq 'EARTHLING');
}

sub gods{
  my ($self) = @_;
  return $self->get_all_roles('GOD');
}

sub earthlings{
  my ($self) = @_;
  return $self->get_all_roles('EARTHLING');
}

sub get_mana{
  my ($self,$player) = @_;
  $player = $self->{-user} unless defined $player;
  return 0 if $player < 1;

  my $stmt = "SELECT MANA from GOD where GAME=$self->{-game} AND PLAYER=$player";
  my ($mana) = $self->{-db}->single_select($stmt);
  return $mana ? $mana : 0;
}

sub gender{
  my ($self,$player) = @_;
  return 0 if $player < 1;
  my @gen = $self->read_role($player, 'GENDER');
  return $gen[0];
}


sub field_string{
  my ($self, $type) = @_;
  return $self->{-db}->loc('FIELD_'.$type);
}

sub relation_string{
  my ($self, $other) = @_;
  my $rel = $self->get_relation($other);
  # print Dumper $rel;
  $rel = 'NEUTRAL' if not $rel;
  return $self->{-db}->loc('STAT_'.$rel);
}

sub mobile_string{
  my ($self, $type, $num) = @_;
  my $tag = 'MOBILE_'.$type;
  $tag .= '_PL' if $num != 1;
  return $self->{-db}->loc($tag);
}

sub mobile_extended_string{
  # count + localised type + adored god if any
  my ($self, $type, $num, $adoring) = @_;
  my $out = $num.' '.$self->mobile_string($type, $num);
  if($type eq 'PRIEST' or $type eq 'PROPHET' or $type eq 'HERO'){
    $out .= ' '.$self->{-db}->loc('ADJ_ADORING').' '.$self->charname($adoring);
  }
  return $out;
}

sub role_string{
  my ($self, $player) = @_;
  my $role = $self->role($player);
  $role = 'UNDEFINED' unless defined $role;
  my $tag = "ROLE_$role";
  return $self->{-db}->loc($tag);
}


sub new_role{
  my($self,$role,$name,$gender,$desc) = @_;
  $desc = 'none' unless defined $desc;
  my $db = $self->{-db};

#  my ($qname, $qgender, $qdesc, $qrole)
#    = $db->quote_all($name, $gender, $desc, $role);

  my $cond = 'GAME='.$self->{-game}." AND NICKNAME=$name";
  return 0 if @{$db->select_array('ROLE','GAME',$cond)}; # error: dublicate name

  my @homes; # all possible homes for this role
  if($role ne 'OBSERVER'){
    @homes = $self->open_homes($role);
    return 0 if $#homes<0; # error: no home free
  }

  # dont allow names only in uppercase
  return 0 if $name =~ /^\s*[A-Z_]{3,}\s*$/;

  # write in ROLE
  $db->insert_hash('ROLE',{'GAME' => $self->{-game},
			   'PLAYER' => $self->{-user},
			   'NICKNAME' => $name,
			   'ROLE' => $role,
			   'GENDER' => $gender,
			   'DESCRIPTION' => $desc}
		            );
  if($role eq 'OBSERVER'){
    $db->commit();
    return 1;
  }

  # choose home:
  my $home = $homes[rand($#homes + 1)]->[0];

  if($role eq 'GOD'){
    # read actual default manapool from GAME
    my ($mana,$ts) = $db->read_game($self->{-game},'START_MANA,TEMPLE_SIZE');
    $mana += $ts * 2;

    # write GAME, PLAYER, MANA in GOD
    $db->insert_hash('GOD',{'GAME' => $self->{-game},
			    'PLAYER' => $self->{-user},
			    'MANA' => $mana});

    # choose second and third home
    #     my $home2 = $home;
    #     my $home3 = $home;
    #     if($#homes > 0){
    #       while($home2 eq $home or $home3 eq $home or $home2 eq $home3){
    # 	$home2 = $homes[rand($#homes + 1)]->[0];
    # 	$home3 = $homes[rand($#homes + 1)]->[0];
    #       }
    #     }

    #     # change OWNER in MAP where LOCATION=$home or LOCATION=$home2
    #     #   ($home,$home2) = $db->quote_all($home,$home2);
    #     $db->update_hash('MAP',
    # 		     "GAME=$self->{-game} AND".
    # 		     " (LOCATION=$home OR LOCATION=$home2 OR LOCATION=$home3)",
    # 		     {'HOME' => $self->{-user}});

  }else{ # eartling
    # write GAME, PLAYER in EARTHLING
    $db->insert_hash('EARTHLING',{'GAME' => $self->{-game},
				  'PLAYER' => $self->{-user}});

    # change OCCUPANT, OWNER in MAP where LOCATION=$home
    #    ($home) = $db->quote_all($home);
    $db->update_hash('MAP',
		     "GAME=$self->{-game} AND LOCATION=$home",
		     {'HOME' => $self->{-user},
		      'OCCUPANT' => $self->{-user}});

    # change PLAYER of WARRIORS OR PRIESTs in MOBILE where LOCATION=$home
    $db->update_hash('MOBILE',
		     "GAME=$self->{-game} AND LOCATION=$home AND OWNER=-1",
		     {'OWNER' => $self->{-user}});

    # give additional start-warriors
    my $warriors = $db->select_array('MOBILE',
				     'ID,COUNT',
				     "GAME=$self->{-game} AND LOCATION=$home ".
				     "AND OWNER=$self->{-user} AND TYPE=WARRIOR");
    my @w = @$warriors;
    if($#w > -1){
      $db->update_hash('MOBILE',
		       "ID=$w[0]->[0]",
		       {'COUNT' => "COUNT + $::conf->{-START_WARRIORS}"},
		       'noquote');
    }else{
      $db->insert_hash('MOBILE',
		       {'ID' => $db->find_first_free('MOBILE','ID'),
			'GAME' => $self->{-game},
			'LOCATION' => $home,
			'TYPE' => 'WARRIOR',
			'COUNT' => $::conf->{-START_WARRIORS},
			'OWNER' => $self->{-user},
			'AVAILABLE' => 'Y'});
    }

    # modify PRODUCE Command
    $db->update_hash('COMMAND',
		     "GAME=$self->{-game} AND COMMAND=PRODUCE ".
		     "AND LOCATION=$home",
		     # TODO: open question: is this redundant information?
		     {'PLAYER' => $self->{-user},
		      'ARGUMENTS' => "ROLE=$self->{-user}"});

  }

  # TODO: write MESSAGE to all members of this game: new player with role!


  $db->commit();
  return 1;
}

sub startfield{
  my ($self) = @_;

  my $cond = "GAME=$self->{-game} AND ";
  if($self->role($self->{-user}) eq 'OBSERVER'){
    $cond .= 'TERRAIN='.$self->{-db}->quote('AYMARGEDDON');
  }else{
    $cond .= "HOME=$self->{-user}";
  }
  # TODO: what happens if both mountains are flooded?
  return $self->{-db}->select_array('MAP','LOCATION',$cond)->[0]->[0];
}


sub open_homes{
  my ($self,$role) = @_;
  my $terrain = ($role eq 'GOD') ? 'MOUNTAIN' : 'CITY';
  # ($terrain) = $self->{-db}->quote_all($terrain);
  my $cond = 'GAME='.$self->{-game}." AND HOME=-1 AND TERRAIN=$terrain";
  return @{$self->{-db}->select_array('MAP','LOCATION',$cond)};
}

sub is_open{
  my ($self,$terrain) = @_;

  my $cond = "GAME=$self->{-game} AND HOME=-1";
  if($terrain){
    $terrain = $self->{-db}->quote($terrain);
    $cond .= "AND TERRAIN=$terrain";
  }
  my $unused = $self->{-db}->select_array('MAP','LOCATION','',$cond);
  my @arr = @$unused;

  return $#arr+1;
}

# TODO performance: we can do this whole function in one sophisticated SQL-statement.
sub incarnation_place{
  my ($self,$player) = @_;
  $player = $self->{-user} unless defined $player;

  my $temples = $self->{-db}->select_array('MAP','LOCATION',
					   "TEMPLE='Y' AND HOME=$player");

  my $place;
  my $max_priests = 0;
  for my $temple (@$temples){
    my $loc = $temple->[0];
    Util::log("check for $loc...",1);
    # my ($qloc,$type,$yes) = $self->{-db}->quote_all($loc,'PRIEST','Y');
    my $priests = $self->{-db}->single_hash_select('MOBILE',
						   "ADORING=$player AND ".
						   "LOCATION=$loc AND ".
						   "TYPE=PRIEST AND ".
						   "AVAILABLE=Y AND ".
						   "GAME=$self->{-game}");

    if(defined $priests and $priests->{'COUNT'} > $max_priests){
      $place = $loc;
      $max_priests = $priests->{'COUNT'};
    }
  }
  return $place;
}

sub read_fortune{
  my $self = shift;

  my ($fortune) = $self->{-db}->read_game($self->{-game},
					  'FORTUNE');
  return $fortune;
}

# returns also empty neighbours, but no attacked neighbours
sub own_neighbours{
  my ($self,$loc,$player) = @_;
  $player = $self->{player} unless defined $player;

  # print "own_neighbours($loc,$player)\n";
  my $map = HexTorus->new($self->get_size());
  my $location = Location->from_string($loc);
  my @neighbours = $map->neighbours($location);
  my @own_neighbours;
  for my $n (@neighbours){
    my $n_string = $n->to_string();
    my ($occ,$att,$terrain) = $self->read_field('OCCUPANT,ATTACKER,TERRAIN',$n_string);
    Util::log("$n_string occupied by $occ, attacked by $att",2);
    next if $att;
    next if $::conf->{-FIGHTS_WITHOUT_OWNER}->{$terrain} and not $occ;
    push @own_neighbours, $n_string if $occ == $player or $occ <= 0;
  }
  # print Dumper \@own_neighbours;
  Util::log("own_neighbours($loc,$player): @own_neighbours",2);
  return @own_neighbours;
}

sub is_in_direction_from{
  my($self,$to,$from) = @_;

  my $map = HexTorus->new($self->get_size());
  my $to_location = Location->from_string($to);
  my $from_location = Location->from_string($from);

  return $map->get_direction($from_location,$to_location);
}

sub show_statistic{
  my($self) = @_;
  my $db = $self->{-db};

  my @earthlings = $self->get_all_roles('EARTHLING');
  my @gods = $self->get_all_roles('GOD');

  # show for god: own mana,
  my $out = '';
  if($self->is_god()){
    # own mana
    $out .= $db->loc('OWN_MANA',$self->get_mana());
  }

  # show for all: #priests of god (?), #citys of earthling, #temples to build,
  #               speed of game, fortune, last battle, fighting strength of earthlings
  #               #temples of god

  # strength of every god in last battle
  $out .= $db->loc('LAST_BATTLE_HEADING') . '<p>';
  for my $god (@gods){
    # my $god = $god->[0];

    my $strength=$self->strength_in_last_battle($god);
    $out .= $db->loc('LAST_BATTLE_LINE',$self->charname($god),$strength) . '<br>';

    # TODO?: count priests
  }

  # count citys
  $out .= '<p>' . $db->loc('CITY_HEADING'). '<p>';
  for my $player (@earthlings){
    # $player = $player->[0];
    my $citys = $db->count('MAP',
			   "GAME=$self->{-game} AND OCCUPANT=$player AND TERRAIN=CITY");
    $out .= $db->loc('STATISTIC_EARTHLING_CITY',
		     $self->charname($player),
		     $citys).'<br>';
  }
  $out .= '<p>';

  # count temples to build for the end of the world
  $out .= $db->loc('STATISTIC_UNBUILD', $self->unbuild()). " " .
    $db->loc('STATISTIC_NEW_TEMPLES', $self->under_construction())."<p>\n";

  my $game = $db->single_hash_select('GAME',
				     "GAME=$self->{-game}");
  my $fortune = $game->{'FORTUNE'};
  $out .= $db->loc('STATISTIC_FORTUNE',$fortune);

  my $speed = $game->{'SPEED'};
  $out .= $db->loc('STATISTIC_SPEED',"$speed sec");

  return $out;
}

# returns number of places for temples
sub building_places{
  my $self = shift;
  return $self->{-db}->count('MAP',
			     "(TERRAIN=ISLE OR TERRAIN=MOUNTAIN) ".
			     "AND GAME=$self->{-game}");
}

# returns number of unbuild temples
sub unbuild{
  my $self = shift;
  return $self->{-db}->count('MAP',
			     "(TERRAIN=ISLE OR TERRAIN=MOUNTAIN) ".
			     "AND TEMPLE=N AND GAME=$self->{-game}");
}

# returns number of temples or arks which are currently under construction
sub under_construction{
  my ($self,$type) = @_;
  $type = 'TEMPLE' unless defined $type;
  return $self->{-db}->count('EVENT',
			     "TAG=EVENT_BUILD_$type");

}

sub strength_in_last_battle{
  my($self,$god) = @_;
  $god = $self->{-player} unless defined $god;
  my $db = $self->{-db};

  my $god_hash =
    $db->single_hash_select('GOD',
			    "GAME=$self->{-game} AND PLAYER=$god");

  my $aymargeddon =
    $db->single_hash_select('MAP',
			    "GAME=$self->{-game} AND".
			    " TERRAIN=AYMARGEDDON")->{'LOCATION'};
  my $avatars = $self->count_mobile('AVATAR',$aymargeddon,$god);

  my $strength = $::conf->{-LAST_BATTLE}->{-AVATAR} * $avatars +
    $::conf->{-LAST_BATTLE}->{-DEATH_AVATAR} * $god_hash->{'DEATH_AVATAR'} +
      $::conf->{-LAST_BATTLE}->{-DEATH_HERO} * $god_hash->{'DEATH_HERO'};

  return $strength;

}

sub mobile_to_html{
  my ($self, $loc,$own,$occ,$temple,$ter,
      $oid,$otype,$oown,$oado,$ocnt,$ostat,$omove) = @_;
# field infos:
#  loc:    location of the field
#  own:    the owner of the field (for cities and temples) (HOME)
#  occ:    the occupant of the field
#  temple: wether there is a temple or not
#  ter:    terrain of field
# mobile infos:
#  oid:    id of the mobile
#  otype:  type of the mobile
#  oown:   owner of the mobile
#  oado:   which god the mobile adores
#  ocnt:   mobile count
#  ostat:  status of the mobile (BLOCK, IGNORE or HELP)
#  omove:  the id of the mobile to move with (unused here)

  my $user = $self->{-user};
  my $db = $self->{-db};
  my $aym = $self;

  my $out = $ocnt.' ';
  if($oown == $user){
    $out .= $db->loc('PREP_OWN_PL').' '.$aym->mobile_string($otype,2);
    if($otype eq 'PRIEST' or $otype eq 'PROPHET'){
      $out .= $db->loc('ADJ_ADORING').' '.$aym->charname($oado);
      if($own != $oado){
	$out .= ' (<a href="command.epl?cmd=CH_STATUS&other='.$oado.'">'.
	  $aym->relation_string($oado).
	    '</a>, <a href="command.epl?cmd=SEND_MSG&other='.$oado.'">'.
	      $db->loc('SEND_MESSAGE').'</a>)';
      }
      if(($ter eq 'ISLE' or $ter eq 'MOUNTAIN') and $temple eq 'N'){
	$out .=' (<a href="command.epl?cmd=BUILD_TEMPLE&mob='.$oid.'&loc='.$loc.'">';
	$out .= $db->loc('CMD_BUILD_TEMPLE').'</a>)';
      }
    }elsif($otype eq 'HERO'){
      $out .= $db->loc('ADJ_ADORING');#.' <a href="command.epl?cmd=CH_ADORING&mob='.
	# $oid.'">';
      $out .= ' ' . $aym->charname($oado); #.'</a>';
      if($own != $oado){
	$out .= ' (<a href="command.epl?cmd=CH_STATUS&other='.$oado.'">'.
	  $aym->relation_string($oado).
	    '</a>, <a href="command.epl?cmd=SEND_MSG&other='.$oado.'">'.
	      $db->loc('SEND_MESSAGE').'</a>)';
      }
    }elsif($otype eq 'AVATAR'){
      $out .= ' (<a href="command.epl?cmd=CH_ACTION&mob='.$oid.'">'.
	$aym->mobile_string($ostat,1).'</a>)';
      if($temple eq 'Y'){
	$out .= " (<a href=\"command.epl?cmd=DESTROY&loc=$loc\">".
	  $db->loc('CMD_DESTROY').'</a>)';
      }
    }
    $out .= ' (<a href="command.epl?cmd=MOVE&mob='.$oid.'&loc='.$loc.'">'.
      $db->loc('CMD_MOVE').'</a>)';

  }else{
    $out .= $aym->mobile_string($otype, $ocnt);

    $out .= ' '.$db->loc('PREP_OWN_SG').' ';
    $out .= $db->loc('ART_DAT_PL').' ' if $aym->gender($oown) eq 'PLURAL';
    $out .= $aym->charname($oown);
    if($own != $oown and $occ != $oown){
      $out .= ' (<a href="command.epl?cmd=CH_STATUS&other='.$oown.'">'.
	$aym->relation_string($oown).'</a>,'.
	    '<a href="command.epl?cmd=SEND_MSG&other='.$oown.'">'.
	      $db->loc('SEND_MESSAGE').'</a>)';
    }

    if($otype eq 'PRIEST' or $otype eq 'PROPHET'or $otype eq 'HERO'){
      $out .= $db->loc('ADJ_ADORING').' ';
      if($oado == $user){
	$out .= $db->loc( ($aym->gender($user) eq 'PLURAL') ?
			  'PPRO_DAT3_PL' : 'PPRO_DAT3_SG');
      }else{
	$out .= $aym->charname($oado);
	if($own != $oown and $occ != $oown){
	  $out .= ' (<a href="command.epl?cmd=CH_STATUS&other='.$oado.'">'.
	  $aym->relation_string($oado).
	    '</a>, <a href="command.epl?cmd=SEND_MSG&other='.$oado.'">'.
	      $db->loc('SEND_MESSAGE').'</a>)';
	}
      }
    }elsif($otype eq 'WARRIOR' and $aym->is_god($user)){
      $out .= ' (<a href="command.epl?cmd=BLESS_PRIEST&mob='.$oid.'">'.
	$db->loc('CMD_BLESS_PRIEST').'</a>)';
      if($own==$user and $temple eq 'Y'){
	$out .= ' (<a href="command.epl?cmd=BLESS_HERO&mob='.$oid.'">'.
	  $db->loc('CMD_BLESS_HERO').'</a>)';
      }
    }
  }
  return $out;
}

# this overloads the same function in Game.pm
# we dont look on arks, that is special for Aymargeddon
#sub own_in_mobile{
#  my($self,$loc,$player,$active) = @_;
#  my $cond = "GAME=$self->{-game} AND LOCATION=$loc".
#    " AND TYPE!=ARK AND (OWNER=$player OR ADORING=$player)";
#  if(defined $active){
#    # my $y = $self->{-db}->quote('Y');
#    $cond .= " AND AVAILABLE='Y'";
#  }
#  return $self->{-db}->select_array('MOBILE','ID',$cond);
#}


# returns true if foreign eartlings approach to field
sub foreign_earthling_approaching{
  my ($self,$loc,$earthling) = @_;

  # TODO BUG: if $earthling < 1 => different names in different languages...
  my $name = $self->charname($earthling);
  my $ret = $self->{-db}->count('EVENT',
				"LOCATION=$loc AND ".
				"(TAG=EVENT_MOBILE_APPROACHING OR ".
				"TAG=EVENT_ARK_APPROACHING) AND ".
				"ARG1 != $name AND ".
				"ARG4 != MOBILE_AVATAR AND ".
				"ARG4 != MOBILE_AVATAR_PL");

  return $ret;
}

# returns true if own avatar is there and if no god-fight is running
sub avatar_available{
  my ($self,$loc,$god,$command) = @_;

  my $avatars = $self->own_in_mobile($loc,$god,1);
  my @avatars = @$avatars;

  my ($godfight) = $self->read_field('GOD_ATTACKER',$loc);

  unless($#avatars >= 0 and not $godfight){
    $self->send_message_to($god,
			   {'MSG_TAG' => "MSG_$command\_NEED_AVATAR",
			    'ARG1' => $loc}) if defined $command;
    return 0;
  }

  return 1;
}

1;
