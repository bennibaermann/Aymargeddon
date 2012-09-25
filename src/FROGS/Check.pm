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

use strict;
use FROGS::DataBase;

#
# Here some generell functionality to check the integrity of
# the underlying database is checked.

package Check;
use Data::Dumper;

sub new{
  my $class = shift;
  my $self = {};
  $self->{-db} = DataBase->new(@_);
  bless ($self,$class);
}

# do a check, there can be different TYPE of checks:
# A_IN_B, LOGIC, UNIVERSAL
#
# - A in B checks if corresponding fields in different tables exists
#
# - LOGIC checks with a function for some fields in a table
#
# - UNIVERSAL checks with an arbitrary function
#
# - TODO: LOCATION should check with a function for every location

sub check_all{
  my $self = shift;
  my $checks = shift;

  my $db = $self->{-db};

  while(my ($k,$v) = each %$checks){
    print "check $k... ";
    my $type = $v->[0];
    if($type eq 'A_IN_B'){
      my $table_A = $v->[1]->[0];
      my $field_A = $v->[1]->[1];
      my $table_B = $v->[1]->[2];
      my $field_B = $v->[1]->[3];

      # TODO BUG: dont use single_select!
      my @data = $db->single_select("select distinct $field_A from $table_A");
      my @datb = $db->single_select("select distinct $field_B from $table_B");

      print Dumper \@datb;
      my %schnitt;
      for my $d (@datb){
	print "hab $d\n";
	$schnitt{$d} = 1;
      }
      my $failed = 0;
      for my $d (@data){
	if(not exists($schnitt{$d})){
	  print "FAILED with $field_A = $d!\n";
	  $failed = 1;
	  last;
	}
      }
      next if $failed;
      print "OK.\n";
    }elsif($type eq 'LOGIC'){
      my $table = $v->[1]->[0];
      my $fields = $v->[1]->[1];
      my $function = $v->[1]->[2];
      local $" = ', ';
      my $command = "select @$fields from $table";
      # TODO: single_select correct? we need the whole table and
      # TODO: there is no condition???
      my @dat = $db->single_select($command);
      # print Dumper $dat;

      my $failed = 0;
      for my $d (@dat){
	my $ret = &$function($d);
	$failed = 1 unless $ret;
      }
      $failed ? print "FAILED!\n" : print "OK.\n";
    }elsif($type eq 'UNIVERSAL'){
      my $function = $v->[1];
      my $ret = &$function($db);
      $ret ? print "FAILED: $ret\n" : print "OK.\n";
    }else{
      print "FAILED (Type of check - $type - not avaiable)\n";
    }
  }
}

1;


