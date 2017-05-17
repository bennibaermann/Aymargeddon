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

# TODO: seperate FROGS-config from Aymargeddon-config in different files

# TODO: add some kind of local configuration file (db-passwd etc...)

# change this file to configure your game

use strict;
package Config;
require Exporter;
@::ISA = qw(Exporter);
@::EXPORT_OK = qw($conf);

$::conf = {
	   # FROGS stuff
	   -DB_SOURCE => 'mysql:RAGNAROEK',
	   -DB_USER => 'aymargeddon',
	   -DB_SECRETS => '/home/benni/aymargeddon/current/+secrets',
	   -COMMANDS => 'AymCommand.pm',
	   -GAME_NAME => 'Aymargeddon',
	   -DEFAULT_LANGUAGE => 'EN',
	   -LOG_TIME_IN_LOOP => 1000, # loops until next time output in log
	   -DEBUG => 1,
	   -EPL_DEBUG => 1,
	   -MESSAGE_IN_LOG => 0,
	   -FULL_DEBUG_FILE => '/home/benni/aymargeddon/current/src/FROGS/+out',
	   -SCHEDULER_SLEEP => 2,
	   -DELETE_OLD_EVENTS => 1, # dont touch this, it will not work!
	   -DELETE_OLD_COMMANDS => 1, # dont touch this, it will not work!
	   -SEND_MESSAGE_TO_FIELD => 1, # set to 0 to stop slow messages
	   -MAX_ARGS => 4, # maximum arguments for localisation tags
                           # (hardcoded in database-structure)
	   -MANY => 99999,

	   # Aymargeddon stuff... you maybe dont need this for other games

	   -START_MANA => 33,
	   -START_FORTUNE => 3,
	   -START_WARRIORS => 2,
	   -MAX_MOUNTAINS => 1, # mountains per god/earthling-combination
	   -MIN_DISTANCE_HOME => 3, # minimal distance between homecitys
	   -NEIGHBOUR_CITIES => 2, # number of citys in the neighbourhood of a home
	   -MIN_DISTANCE_MOUNTAIN => 2,
	   -WANTED_DISTANCE_MOUNTAIN => 3,
	   -MIN_DISTANCE_MOUNTAIN_FROM_WATER => 2,
	   -MIN_LUCK => 3,
	   -MAX_LUCK => 12,
	   -MANA_FOR_TEMPLE => 1,
	   -FORTUNE_FAKTOR_ISLAND => 1,
	   -FORTUNE_FAKTOR_MOUNTAIN => 2,
	   -MAX_UNBUILD_DESTROY => 1,
	   # -ARK_RETREAT_POSSIBILITY => 0.5, (in the moment hardcoded)
	   -WINNER_DEATH_COUNT_FRACTION => 5,
	   -LOOSER_DEATH_COUNT_FRACTION => 3,
	   -WINNER_AVATARS_DYING_FRACTION => 4,
	   -LOOSER_AVATARS_DYING_FRACTION => 2,
	   -DEATH_SHARE_ROW => [0.4, 0.3, 0.2, 0.1], # should sum to 1
	   -DEFAULT_DYING => 'KHP',

	   -PLAGUES => ['INFLUENZA','PESTILENTIA','TUBERCULOSIS'],
	   -PESTILENTIA_DEATH_SHARE => 0.5,
	   -SPREAD_PLAGUE => {'CITY' => 0.1,
			      'PLAIN' => 0.05,
			      'MOUNTAIN' => 0.03,
			      'ISLE' => 0.02,
			      'WATER' => 0},
	   -HEAL_PLAGUE => 0.4,

	   # can gods give earthlings right to see?
	   -GODS_SHOW_EARTHLINGS => 0,

	   # which fields keep there owner without units?
	   -HOMECITY_KEEP_OWNER => 1,
	   -TEMPLE_KEEP_OWNER => 1,
	   -KEEP_OWNER => {'CITY' => 1},

	   # which fields fight without owner?
	   -FIGHTS_WITHOUT_OWNER => {'CITY' => 1},

	   # which fields fights without units?
	   #-HOMECITY_FIGHTS => 1,
	   #-FIGHTS_WITHOUT_UNIT => {'CITY' => 1},

	   -DURATION => {

			 -MOVE_AVATAR => 1,
			 -MOVE_HERO => 8,
			 -MOVE_WARRIOR => 10,
			 -MOVE_PRIEST => 6,
			 # -MOVE_PROPHET => 6, # 12
			 -MOVE_ARK => 5,
			 -FIGHT_EARTHLING => 6,
			 -FIGHT_GOD => 10, #10
			 -BUILD_TEMPLE => 3, # 50
			 -FLOOD => 40, # 40
			 -CH_ADORING => 20,
			 -CH_LUCK => 5,
			 -PRODUCE_WARRIOR => 40, # 40
			 -PRODUCE_WARRIOR_HOME => 20, # 20
			 -PRODUCE_WARRIOR_CHANGE => 0,
			 -PRODUCE_PRIEST => 40, # 40
			 -PRODUCE_PRIEST_HOME => 40, # 40
			 -BUILD_ARK => 30, #30
			 -PLAGUE => 20,
			 -PRAY => 10, # 10
			},

	   -FIGHT => {
		      -PRIEST => 0,
		      -WARRIOR => 1,
		      -HERO => 2,
		      -PROPHET => 0,
		      -AVATAR => 4, # maximum
		      -HOME => 2,
		      -ISLE => 2,
		      -ARK => 1,
		      -FLANKING => 1,
		     },
	   #-SEE_FIGHT => {
	   #		  -PRIEST => 0,
	   #	  -WARRIOR => 0,
	   #  -HERO => 1,
	   # -PROPHET => 0,
	   #-AVATAR => 0,
	   #-HOME => 0,
	   #-ARK => 3,
	   #-FLANKING => 0,
	   #},
	   # -ISLAND_FIGHT => {
	   #		  -PRIEST => 0,
	   #	  -WARRIOR => 1,
	   #  -HERO => 2,
	   # -PROPHET => 0,
	   #-AVATAR => 4, # maximum
	   #-HOME => 2,
	   #-ARK => 3,
	   #-FLANKING => 0,
	   #},

	   -LAST_BATTLE => {
			    -DEATH_HERO => 1,
			    -DEATH_AVATAR => 0,
			    -AVATAR => 7,
			   },
	   -MANA => {
		     -MOVE_AVATAR => 1,
		     -FIGHT_AVATAR => 2,
		     -DESTROY => 7,
		     -FLOOD => 4,
		     -CH_LUCK => 1,
		     -BUILD_ARK => 7,
		     -BLESS_PRIEST => 7,
		     -BLESS_HERO => 2,
		     -INCARNATE => 5,
		     # plagues:
		     -INFLUENZA => 10,
		     -PESTILENTIA => 20,
		     -TUBERCULOSIS => 40,
		    },

	   -COLOR => {
		      -EMPTY => '#fcffd9',
		      -NEUTRAL => '#b8a266',
		     },
	  };

# read password from secrets-file. password should not be included in source!

my $conf = $::conf->{-DB_SECRETS};

# substitute "~" (UNIX only!) from Perl Cookbook 7.3 not really useful
# here, because HOME is different in webserver and in user context
$conf  =~ s{ ^ ~ ( [^/]* ) }{ $1 ? (getpwnam($1))[7] : ($ENV{HOME}||$ENV{LOGDIR}||
							(getpwuid($<))[7])}ex;

open(CONFIG,$conf) or die "could not open config file $conf: $!\n";

while(<CONFIG>){
  chop $_;
  next if /^\s*$/;
  next if /^\s*\#.*$/;
  $::conf->{-DB_PASSWD} = $_;
}

close CONFIG or die "could not close config file $conf: $!\n";

1;

