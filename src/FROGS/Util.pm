##########################################################################
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

#
#  Here we gather some utility-functions
#

use strict;
use FROGS::DataBase;
use FROGS::Config qw ($conf);

package Util;
use Data::Dumper;

# parse the command-line (or any other string-array) 
# and overwrites $::conf with the new values
# example: ./scheduler.pl -DURATION-PRAY=1000 -MANA-BLESS_PRIEST=10
sub overwrite_config{
  my @arr = @_;
  for my $arg (@arr){
    my ($left,$right) = split /=/,$arg;
    my @parts = split /-/, $left;

    # TODO: generalization
    if($parts[2]){
      $::conf->{"-$parts[1]"}->{"-$parts[2]"} = $right;
    }else{
      $::conf->{"-$parts[1]"} = $right;
    }
  }
}

# returns 1 if $scalar is in @list
sub is_in{
  my ($scalar, @list) = @_;

  for my $le (@list) {
    return 1 if $le eq $scalar;
  }
  return 0;
}

# returns all elements of @$A which are _not_ in @$B
# in an array reference
sub without{
  my ($A, $B) = @_;

  my %h = ();
  for my $b (@$B){
    $h{$b} = 1;
  }

  my @A_without_B = ();
  for my $a (@$A){
    push @A_without_B, $a unless exists $h{$a};
  }
  return \@A_without_B;
}

sub log{
  my ($string,$level) = @_;

  my $abslevel = $level;
  my $do = 0;

  # TODO: dirty hack, use caller() instead
  if($0 eq '-e'){
    $string .= "<p>";
    $do = 1 if $::conf->{-EPL_DEBUG} >= $abslevel;
  }else{
    $do = 1 if $::conf->{-DEBUG} >= $abslevel;

    if($::conf->{-FULL_DEBUG_FILE}){
      # FULL_LOG in file
      if($level >= 0){
	print FULL_LOG "$string\n";
      }else{
	print FULL_LOG "$string";
      }
    }
  }
  # negativ values for level prints no newline
  if($do){
    if($level >= 0){
      print "$string\n";
    }else{
      print "$string";
    }
  }
}

sub open_log{
  my $file = $::conf->{-FULL_DEBUG_FILE};
  open(FULL_LOG,">$file") or die "can't open $file: $!";
}

sub close_log{
  close FULL_LOG;
}

sub min{
  my @list = @_;

  my $min = 99999999;
  for my $elem (@list){
    $min = $elem if $elem < $min;
  }
  return $min;
}

sub max{
  my @list = @_;

  my $max = -99999999;
  for my $elem (@list){
    $max = $elem if $elem > $max;
  }
  return $max;
}

# returns a shuffled list
sub shuffle {
  my $array_ref = shift;

  my @shuffled = sort { int(rand(3)) - 1 } @$array_ref;

  return \@shuffled;
}

1;

