#!/usr/bin/perl -w
#########################################################################
#
#   Copyright (c) 2003 Aymargeddon Development Team
#
#   This file is part of
#   "FROGS" = Framework for Realtime Online Games of Strategy
#
#   FROGS is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2 of the License, or (at your option)
#   any later version.
#
#   FROGS is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#   more details.
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, write to the Free Software Foundation, Inc., 675
#   Mass Ave, Cambridge, MA 02139, USA.
#
###########################################################################
#
#  scheduler daemon
#
# usage:
# ./scheduler.pl [conf-parameter]=[value] ...
# example:
# ./scheduler.pl -DURATION-PRAY=1000 -DURATION-PRODUCE=1000

use strict;
use lib qw(..);
use FROGS::DataBase;
use FROGS::Command;
use FROGS::Config qw ($conf);
use Data::Dumper;

$|=1;

Util::open_log();

# read command line
Util::overwrite_config(@ARGV);

my $KEYCOL="SUBMIT";

my $db= new DataBase;
# $db->nowrite();
require $::conf->{-COMMANDS};
my $now = $db->now();
Util::log("\n$now Scheduler started...",0);
loop();
exit;

sub loop {
  #	read next using our db connection (complicated due to poor SQL
  #	implemention of MYSQL :-/
  my $nulldate = $db->quote('0000-00-00 00:00:00'); # TODO: ugly and unportable :-(
  my $nullcond = "(DONE IS NULL OR DONE=$nulldate)";
  my $count = 0;
  while (1) {
    $count++;
    $db->commit(); # ??? WHY IS THIS NECESSARY TO SEE COMMANDS FROM CLIENTS ???
    my ($minexec) = $db ->single_select("SELECT min( exec ) FROM COMMAND ".
					"WHERE $nullcond and EXEC <= NOW()");
    $minexec = $db ->quote($minexec);
    my ($id) = $db ->single_select("SELECT min(id) FROM COMMAND ".
				   "WHERE $nullcond and EXEC = $minexec");
    $id= $db ->quote($id);
    my $command_entry =  $db ->single_hash_select("COMMAND",
						  "EXEC = $minexec and ID = $id ");

    # delete outdated events
    $db->delete_from('EVENT','TIME < NOW()') if $::conf->{-DELETE_OLD_EVENTS};

    if (! defined  $command_entry ) {
      # sleep if no command in db
      sleep ($::conf->{-SCHEDULER_SLEEP});
      Util::log('.',-1);

      if($count % $::conf->{-LOG_TIME_IN_LOOP} == 0){
	my $now = $db->now();
	Util::log("\n###\n### $now: counted $count loops\n###\n",1);
      }
      next;
    }

    # 	create command object
    my $command = $command_entry->{"COMMAND"}->new($command_entry,$db);
    # execute command
    if($command){
      $command->execute();
      $db->commit;
    }
  }
};

