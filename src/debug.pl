#!/usr/local/bin/perl -w
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
# creates the world to destroy
#
# usage: ./create.pl [number of eartlings]
#
#

# TODO: use FROGS/DataBase.pm instead of DBI.pm

use strict;

use DBI;
use Data::Dumper;
use POSIX qw(floor ceil);
use Term::ReadLine;

use FROGS::HexTorus;

my $n = 16;
my $map = new HexTorus($n);
my $out = "\n";
for my $y (0..($n - 1)){
  for my $x ( 0 .. ($n*2-1)){

    my $d =
      $map->distance(Location->new(5,0),
			   Location->new($x,$y));
    $d = "0$d" if $d < 10;
    $out .= "$d ";
  }
  $out .= "\n" . (' ' x ($y +1));
}
$out .= "\n";

print $out;
