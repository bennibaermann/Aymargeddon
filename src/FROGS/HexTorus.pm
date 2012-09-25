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
use POSIX qw(ceil floor);

use FROGS::Config;
use FROGS::Map;

# We define two classes, which gives an implementation of Maps as a
# HexTorus.

# TODO: selects to DataBase.pm

#
# Location. This is a class with two coordinates.
#
package Location;

sub new{
    my ($class,$x,$y) = @_;

    my $self = { -x => $x, -y => $y };
    bless($self, $class);
}

sub get{
    my $self = shift;

    return ($self->{-x},$self->{-y});
}

sub equal{
    my ($self, $loc) = @_;
    my ($x,$y) = $loc->get();
    return ($x == $self->{-x} and $y == $self->{-y});
}

sub to_string{
    my $self = shift;
    return $self->{-x} . '_' . $self->{-y};
}

sub from_string{
    my ($class, $string) = @_;

    # print "CLASS: $class, STRING: $string\n";

    $string =~ /^(\d+)_(\d+)$/;
    my ($x, $y) = ($1,$2);
    # print "x: $x, y: $y\n";
    my $self = { -x => $1,
		 -y => $2,};

    bless($self, $class);
}

sub pretty{
  my $loc = shift;
  $loc =~ s/^(\d+)_(\d+)$/\($1, $2\)/;
  return $loc;
}

sub is_wellformed{
  my $string = shift;
  return 1 if $string =~ /^(\d+)\_(\d+)$/;
  return 0;
}

#
# Map. Hextorus.
#
package HexTorus;
@HexTorus::ISA = qw(Map);

sub new{
    my $class = shift;
    my ($n) = @_;

    my $self = {
	-size => $n
	};

    bless($self, $class);
}


# returns a list of neighbours of field x,y in 
# an hex-torus with size 2n * n
# this function is more effective than the generalised
# distant_neighbours from Map.pm
# TODO BUG: dont return doubbles in turn-around
sub neighbours{
    my $self = shift;
    my ($loc) = @_;	

    my $n = $self->{-size};
    my ($x,$y) = $loc->get();

    return (new Location($x,($y-1)%$n),
	    new Location($x,($y+1)%$n),
	    new Location(($x-1)%($n*2),$y),
	    new Location(($x+1)%($n*2),$y),
	    new Location(($x+1)%($n*2),($y-1)%$n),
	    new Location(($x-1)%($n*2),($y+1)%$n));
}

# returns the neighbour in the given direction.
# direction can be one of qw(NW N NE S SW SE)
sub get_neighbour{
  my ($self, $loc, $dir) = @_;
  my ($x,$y) = $loc->get();

  $dir = uc($dir);
  my ($xx,$yy) = ($x,$y);
  my $n = $self->{-size};
  if($dir eq 'N'){
    $yy = ($yy - 1) % $n;
  }elsif($dir eq 'S'){
    $yy = ($yy + 1) % $n;
  }elsif($dir eq 'SW'){
    $xx = ($xx - 1) % ($n * 2);
    $yy = ($yy + 1) % $n;
  }elsif($dir eq 'SE'){
    $xx = ($xx + 1) % ($n * 2);
  }elsif($dir eq 'NW'){
    $xx = ($xx - 1) % ($n * 2);
  }elsif($dir eq 'NE'){
    $xx = ($xx + 1) % ($n * 2);
    $yy = ($yy - 1) % $n;
  }else{
    Util::log("HexTorus::get_neighbour(): unknown direction: $dir\n",0);
    return 0;
  }
  return Location->new($xx,$yy);
}

# returns the direction from $from to $to (assumes they are neighbours)
sub get_direction{
  my($self,$from,$to) = @_;

  # print "get_direction(".$from->to_string().", ".$to->to_string().")\n";

  for my $dir (qw(NW N NE S SW SE)){
    my $neighbour = $self->get_neighbour($from,$dir);
    # print "test $dir from ".$from->to_string().": ".$neighbour->to_string()."\n";
    return $dir if $to->equal($neighbour);
  }
  return 0;
}

# returns the distance between two fields in
# an hex-torus with size 2n * n
sub distance{
    my $self = shift;
    my ($loc1,$loc2) = @_;

    my $n = $self->{-size};
    my ($xx,$yy) = $loc1->get();
    my ($x,$y) = $loc2->get();

    if($xx > $n * 2 or $x > $n * 2 or $yy > $n or $y > $n){
	print "range error in distance ($n,$xx,$x,$yy,$y) !\n";
	return 0;
    }

    return 0 if($xx == $x and $yy == $y);

    my $xd = abs($x-$xx);
    $xd = 2 * $n - $xd if $xd > $n;
    my $sd = abs($x-$xx+$y -$yy) % $n;
    $sd = $n - $sd if 2* $sd > $n;
    my $yd = abs($y-$yy);
    $yd = $n - $yd if 2 * $yd > $n;

    if($xd+$yd+$sd == $n){

        if(2*$xd == $n) # this occures only for even n
	{
	    # there must be some easier way to distinguish
	    # fields in se/nw direction from those in sw/ne
	    # but this works.
	    my $xp = abs($x-$xx+1);
	    $xp = 2 * $n - $xp if $xp > $n;
	    my $sp = abs($x -$xx +$y -$yy +1) % $n;
	    $sp = $n - $sp if 2* $sp > $n;
	    return $xd if $xp+$sp != $xd+$sd;
	}
	$yd = $sd if $sd > $yd;
        return $n-$yd;
    }
    return $xd if 2 * $xd > $n;
    return ($xd+$yd+$sd)/2;
}

# returns a random location
sub random{
    my $self = shift;
    my $n = $self->{-size};

    my $x = POSIX::floor(rand($n*2));
    my $y = POSIX::floor(rand($n));

    my $loc = new Location($x,$y);
    return $loc;
}

# iterator for all locations
sub next{
    my $self = shift;
    my $loc = shift;
    my $n = $self->{-size};

    my ($x, $y) = $loc->get();
    if(++$x > $n * 2)
    {
	$x = 0;
	$y = 0 if(++$y > $n);
    }
    return new Location($x, $y);
}

# returns all locations for which $code evals to true
sub grep{
    my $self = shift;
    my $code = shift;

    my $n = $self->{-size};

    my @result;
    for my $x (0..($n*2-1)){
	for my $y (0..($n-1)){
	    my $loc = new Location($x,$y);
	    # print $loc->to_string() . "\n";
	    if(&$code($loc)){
		push @result, $loc;
	    }
	}
    }
    return @result;
}


sub fill_array{
    my $self = shift;
    my @mapping = @_;

    my @array;
    for my $terrain (@mapping){
	for my $xy (@{$terrain->[0]}){
	    my ($x,$y) = $xy->get();
	    $array[$x][$y] = $terrain->[1],
	}
    }
    return \@array;
}

# TODO: use FROGS::DataBase.pm
sub write_db{
    my ($self, $dbh, $game_id, $game_name, $game_speed, $default, @mapping) = @_;
    $default = $dbh->quote($default);
    $game_name = $dbh->quote($game_name);

    my $n = $self->{-size};

    # create game
    my $insert_game = "INSERT INTO GAME (GAME,NAME,SIZE,SPEED,FORTUNE,START_MANA) VALUES".
      " ($game_id,$game_name,$n,$game_speed,".
	"$::conf->{-START_FORTUNE},$::conf->{-START_MANA})";
    print $insert_game ."\n";
    my $h = $dbh->prepare($insert_game);
    $h->execute();
    $h->finish();

    my @db_map = @{$self->fill_array(@mapping)};

    # fill map
    for my $y (0..($n - 1)){
	for my $x ( 0 .. ($n*2-1)){
	    my $insert_map;
	    my $loc = new Location($x,$y);
	    my $loc_string = $dbh->quote($loc->to_string());
	    if(defined $db_map[$x][$y]){

		$insert_map = "INSERT INTO MAP (GAME,LOCATION,TERRAIN)".
		    "VALUES ($game_id,$loc_string,".
			$dbh->quote($db_map[$x][$y]).")";
	    }else{

		$insert_map = "INSERT INTO MAP (GAME,LOCATION,TERRAIN)".
		    "VALUES ($game_id,$loc_string,$default)";
	    }
	    # print "$insert_map\n";

	    $dbh->do($insert_map);
	}
    }
}

sub write_string{
    my $self = shift;
    my $default = shift;
    my $default_string = shift;
    my @mapping = @_;

    my @ascii_map = @{$self->fill_array(@mapping)};

    my $n = $self->{-size};
    my $out = "\n";
    for my $y (0..($n - 1)){
	for my $x ( 0 .. ($n*2-1)){
	    if(defined $ascii_map[$x][$y]){
		$out .= $ascii_map[$x][$y] ;
	    }else{
		$out .= $default;
	    }
	    $out .= " ";
	}
	$out .= "\n" . (' ' x ($y +1));
    }
    $out .= "\n";

    $out .=  "Legend:\n";
    $out .= "$default_string:  \t$default\n";
    for my $terrain (@mapping){
	$out .= $terrain->[2] . ":   \t" .
	    $terrain->[1] . "\n";
    }
    return $out;
}

return 1;
