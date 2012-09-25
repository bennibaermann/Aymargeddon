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

#
#
# checks the integrity of the database.
#
# usage: ./check.pl [-l] [list of checks]
# no args: do all checks
# -l: lists all avaiable checks
# -h: help
# list of checks: do only this checks

use strict;
$|=1;
use DBI;
use Data::Dumper;
use POSIX qw(floor ceil);
use Term::ReadLine;

use FROGS::HexTorus;
use FROGS::Check;
use FROGS::Config;

$::conf->{-FULL_DEBUG_FILE} = 0;
# Util::open_log();

#
# Aymargeddon-specific behaviour
#

# TODO: should also check, if the location is valid in this map
my $location_wellformed_check = sub {
  my $loc = shift;
  my $wf = Location::is_wellformed($loc);
  print "$loc is in bad form! " unless $wf;
  return $wf;
};

my $fight_and_occupant = sub {
  my $db = shift;
  my $dbh = $db->{-dbh};

  my $stmt = 'SELECT GAME,LOCATION,OCCUPANT,ATTACKER,TERRAIN,HOME FROM MAP WHERE 1';
  my $map = $dbh->selectall_arrayref($stmt);

  # for every field in MAP
  for my $field (@$map){
    my ($game,$loc,$occ,$att,$terrain,$home) = @$field;
    Util::log("testing field $loc, game $game: occupant $occ, attacker: $att",1);

    # read all earthling mobiles in field
    my $cond = "LOCATION='$loc' AND GAME=$game AND AVAILABLE='Y'".
      " AND (TYPE='WARRIOR' OR TYPE='PRIEST' OR TYPE='HERO' OR TYPE='PROPHET')";
    # my $qcond = $db->quote_condition($cond);
    $stmt = "SELECT OWNER FROM MOBILE WHERE $cond";
    my $mobiles = $dbh->selectall_arrayref($stmt);

    #   search for earthlings
    my @earthlings = ();
    my $earthlings = {};
    for my $mob (@$mobiles){
      my ($own) = @$mob;
      next if exists $earthlings->{$own};
      $earthlings->{$own} = 1;
      push @earthlings, $own;
    }
    # print Dumper \@earthlings;

    if($occ){
      return "game $game: no earthlings in field $loc with occupant $occ.\n"
	if ($#earthlings == -1 and not ($terrain eq 'CITY' and $home));
    }else{
      return "game $game: earthlings in field $loc without occupant.\n"
	if $#earthlings > -1;
    }

    if($att){
      return "game $game: only one earthling in field $loc from $occ, ".
	"attacked from $att\n" if $#earthlings == 0;
    }else{
      return "game $game: more than one earthling in peaceful field $loc."
	if $#earthlings > 0;
      next if $#earthlings < 0;
      return "game $game: occupant $occ is not the only earthling $earthlings[0]".
	" in field $loc"
	if $occ != $earthlings[0];
    }
  }
  return 0;
};


# list of checks
# every check consists of ID,behaviour
# behaviour is one of A_IN_B, LOGIK or UNIVERSAL

my $check = {
	     -GAME_EXISTS_FOR_MAP =>
	     ['A_IN_B', ['MAP','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_ALLIANCE =>
	     ['A_IN_B', ['ALLIANCE','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_COMMAND =>
	     ['A_IN_B', ['COMMAND','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_GOD =>
	     ['A_IN_B', ['GOD','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_GOD =>
	     ['A_IN_B', ['GOD','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_MESSAGE =>
	     ['A_IN_B', ['MESSAGE','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_ROLE =>
	     ['A_IN_B', ['ROLE','GAME','GAME','GAME']],
	     -GAME_EXISTS_FOR_MOBILE =>
	     ['A_IN_B', ['MOBILE','GAME','GAME','GAME']],

	     -LOCATION_WELLFORMED_IN_MAP =>
	     ['LOGIC',['MAP',['LOCATION'],$location_wellformed_check]],
	     -LOCATION_WELLFORMED_IN_MOBILE =>
	     ['LOGIC',['MOBILE',['LOCATION'],$location_wellformed_check]],
	     # TODO?: implement write last_temple
	     # -LAST_TEMPLE_WELLFORMED_IN_GAME =>
	     # ['LOGIC',['GAME',['LAST_TEMPLE'],$location_wellformed_check]],

	     -FIGHT_AND_OCCUPANT =>
	     ['UNIVERSAL', $fight_and_occupant],

	    };

my $checker = Check->new();
$checker->check_all($check);
	

