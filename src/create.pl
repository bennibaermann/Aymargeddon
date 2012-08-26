#!/usr/bin/perl -w
##########################################################################
#
#   Copyright (c) 2003 Aymargeddon Development Team
#
#   This file is part of "Last days of Aymargeddon" 
#
#   Aymargeddon is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2 of the License, or (at your option)
#   any later version.
#
#   Aymargeddon is distributed in the hope that it will be useful, but WITHOUT
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
#
# creates the world to destroy
#
# usage: ./create.pl [number of eartlings]
#
#

# TODO: use FROGS/DataBase.pm instead of DBI.pm

use strict;

$| = 1;

use DBI;
use Data::Dumper;
use POSIX qw(floor ceil);
use Term::ReadLine;
  my $t = Term::ReadLine->new('test');

use FROGS::HexTorus;
use FROGS::Config qw($conf);
use FROGS::DataBase;
use FROGS::Game;

Util::open_log();

my $earthlings = $ARGV[0] || 10; # number of earthlings

my $dont_ask = defined $ARGV[1] ? 1 : 0;

my $db_source = $::conf->{-DB_SOURCE};
my $db_user = $::conf->{-DB_USER};
my $db_passwd = $::conf->{-DB_PASSWD};

my $ascii = {-pole => '@',
	     -city => '+',
	     -home => '#',
	     -water => '~',
	     -island => '°',
	     -mountain => '^',
	     -plain => '\''};

# set to 0 to not change size of world during generation
# set to positive value to set the number of itterations need to pumpup
my $pump_up_world = 10;

# TODO: maybe to small?
my $n = ceil(sqrt($earthlings * 7)); # size of world

my $pole_count = floor(sqrt($n));
my $min_pole_distance = ceil($n/2);
my $water_count = floor($n*$n/2);
#TODO: number of islands should depend on players, not on size
my $island_count = floor($water_count/3);
my $min_home_distance = $::conf->{-MIN_DISTANCE_HOME};
my $min_mountain_distance = $::conf->{-MIN_DISTANCE_MOUNTAIN};
my $wanted_mountain_distance = $::conf->{-WANTED_DISTANCE_MOUNTAIN};
my $min_water_distance = $::conf->{-MIN_DISTANCE_MOUNTAIN_FROM_WATER};
my $city_count = $earthlings * 4;
my $mountain_count = floor($earthlings);

my $nn = 0;
my $map;
while (1) {
  if ($pump_up_world and $nn > $pump_up_world) {
    $n++;
    print "*** World to small! Make it bigger! New size $n.***\n";
    $nn = 0;
  }
  my $not_enough_room = 0;
  $map = new HexTorus($n);
  $pole_count = floor(sqrt($n));
  $min_pole_distance = ceil($n/2);
  $water_count = floor($n*$n/2);
  $island_count = floor($water_count/3);

  # TODO: uggly structure
  my $print = 0;
  print "generate poles ...\n";
  my @pole = distribute($pole_count,$min_pole_distance,
			$min_pole_distance,$min_pole_distance);
  $not_enough_room = 1 unless $pole[0];
  my (@water,@islands,@home,@mountains,@not_cities,@cities);
  unless ($not_enough_room){
    print "generate water ...\n";
    @water = flood($water_count,@pole);
  }
  unless ($not_enough_room){
    print "generate islands ...\n";
    @islands = vulcano($island_count, \@water, \@pole);
  }
  unless ($not_enough_room){
    print "generate mountains ...\n";
    @mountains = distribute($mountain_count,$min_water_distance,
			    $min_mountain_distance,$wanted_mountain_distance,[],@water);
    $not_enough_room = 1 unless $mountains[0];
  }
  # print print_list(@mountains);
  unless ($not_enough_room){
    print "generate homecitys ...\n";

    for my $i (1..50){
      @home = homeland(@mountains,@pole,@water,@islands);
      # $print = 1 unless $#home<$#mountains;
      last unless $#home<$#mountains;
      print " RETRY...\n";
      my $mref = Util::shuffle(\@mountains);
      @mountains = @$mref;
    }
    print "\n";
    $not_enough_room = 1 if $#home<$#mountains;
  }

  unless ($not_enough_room){
    print "generate citys ...\n";
    @not_cities = (@water,@pole,@mountains,@islands,@home);
    @cities = build($city_count,\@home,\@not_cities);
    $not_enough_room = 1  unless $cities[0];
  }


  if (not $not_enough_room or $print) {
    #print "Pole: " . print_list(@pole);
    #print "Water: " . print_list(@water);
    #print "Islands: " . print_list(@islands);
    #print "Mountains: " . print_list(@mountains);
    #print "Cities: " . print_list(@cities);
    #print "Homes: " . print_list(@home);

    print "Earthlings: $earthlings\n". 
      "Gods: " . ($earthlings/2) . "\n".
	"Size of world: $n\n".
	  "Number of poles: $pole_count\n".
	    "Minimum pole distance: $min_pole_distance\n".
	      "Water: $water_count\n".
		"Islands: $island_count\n".
		  "Citys: $city_count\n".
		    "Plain: " . ( ($n * $n * 2) - ($water_count + $pole_count +
						   $earthlings  + $city_count)) . "\n";

    print $map->write_string($ascii->{-plain},"Plain",
			     [\@pole,$ascii->{-pole},"Pole"],
			     [\@water,$ascii->{-water},"Water"],
			     [\@islands,$ascii->{-island},"Islands"],
			     [\@home,$ascii->{-home},"Home"],
			     [\@mountains,$ascii->{-mountain},"Mountains"],
			     [\@cities,$ascii->{-city},"Cities"]);
    die if $print;
  } else {
    $nn++;
    print "\nNot enough room! Try again ...\n";
    next;
  }

  my $r = $dont_ask ? 'y' : 
    $t->readline('Wrote this world to database? (n/q/[name_of_game])');

  if ($r =~ /^q$/i) {
    exit;
  } elsif ($r =~ /^n$/i) {
    next;
  } else {
    my $speed = $dont_ask ? 3600 :
      $t->readline('Speed of game in seconds per game step: ');

    my $dbh = DBI->connect("dbi:$db_source",$db_user,$db_passwd,
			   {
			    'RaiseError' => 1,'AutoCommit' => 0});

    # TODO: use DataBase::find_first_free("GAME","GAME")

    my $table = $dbh->selectall_arrayref("select GAME from GAME");
    my @game_ids = sort {$a <=> $b} (map {$_->[0]} @$table);

    my $game = 1;
    for my $try (@game_ids) {
      last if $game < $try;
      $game = $try + 1;
    }

    print "Erste Freie Game ID: $game\n";
    my $db = DataBase->new($dbh);
    my $aymgame = Game->new($game,-1,$db);

    $map->write_db($dbh,$game,$r,$speed,'PLAIN',
		   [\@pole,"POLE"],
		   [\@water,"WATER"],
		   [\@islands,"ISLE"],
		   [\@home,"CITY"],
		   [\@mountains,"MOUNTAIN"],
		   [\@cities,"CITY"]);

    # mark home cities and holy mountains
    for my $home (@home, @mountains) {
      my $lo = $dbh->quote($home->to_string());
      my $cmd = "UPDATE MAP SET HOME=-1 where GAME=$game AND LOCATION=$lo";
      $dbh->do($cmd);
    }

    # set home cities occupied
    # insert PRODUCE Commands for Homecitys
    for my $home (@home) {
      my $l = $dbh->quote($home->to_string());
      my $c = "UPDATE MAP SET OCCUPANT=-1 where GAME=$game AND LOCATION=$l";
      $dbh->do($c);

      $aymgame->insert_command('PRODUCE','ROLE=-1',$home->to_string());
    }

    # make one of the poles startup aymargeddon
    my $aym = $pole[rand($#pole + 1)];
    my $ter = $dbh->quote('AYMARGEDDON');
    my $loc = $dbh->quote($aym->to_string());
    my $comd = "UPDATE MAP SET TERRAIN=$ter where GAME = $game AND LOCATION=$loc";
    $dbh->do($comd);

    # check some values
    $::conf->{-DEBUG} = 0;
    print "Check in the database:\n";
    my $m_count = $db->count('MAP', "GAME=$game AND TERRAIN=MOUNTAIN");
    my $h_count = $db->count('MAP', "GAME=$game AND TERRAIN=CITY AND HOME=-1");
    my $o_count = $db->count('MAP', "GAME=$game AND OCCUPANT=-1");
    print "Mountains: " . $m_count;
    print "\nCitys: " . $db->count('MAP',
				 "GAME=$game AND TERRAIN=CITY");
    print "\nHomes: " . $h_count;
    print "\nIslands: " . $db->count('MAP',
				   "GAME=$game AND TERRAIN=ISLE");
    print "\nPoles: " . $db->count('MAP',
				 "GAME=$game AND TERRAIN=POLE");
    print "\nAymargeddon: " . $db->count('MAP',
				       "GAME=$game AND TERRAIN=AYMARGEDDON");
    print "\nWater: " . $db->count('MAP',
				 "GAME=$game AND TERRAIN=WATER");
    print "\nPlain: " . $db->count('MAP',
				 "GAME=$game AND TERRAIN=PLAIN");
    print "\nOccupied: " . $o_count;
    print "\n";

    if($o_count != $h_count or $h_count != $m_count or $m_count != $o_count){
      print "homes: ". print_list(@home) . "\nmountains: ".
	print_list(@mountains) . "\ncities: " . print_list(@cities) . "\n";
      my $boesewichter = $db->select_array('MAP',
					   'LOCATION',
					   "GAME=$game AND HOME=-1 AND ".
					   "OCCUPANT=0 AND TERRAIN=CITY");
      print "boesewichter: "; print map $_->[0] . ", ", @$boesewichter;print "\n";
    }

    $dbh->commit();
    $dbh->disconnect();


    exit;
  }
}

# distributes homecitys near mountains
sub homeland{
  my @mountains = @_;

  my %mountains = ();
  for my $m (@mountains){
    $mountains{$m->to_string()} = 1;
  }

  my %homes = ();
  for my $m (@mountains){
    my @neighbours = $map->neighbours($m);

    my $home;
    while($#neighbours >= 0){
      my $rand = rand($#neighbours + 1);
      $home = $neighbours[$rand];
      my @home_neighbours = $map->neighbours($home);
      my ($m_count,$h_count) = (0,0);
      for my $hn (@home_neighbours){
	$h_count++ if exists $homes{$hn->to_string()};
	$m_count++ if exists $mountains{$hn->to_string()};
      }
      if($h_count == 0 and $m_count == 1){
	my $valid = 1;
	for my $h (keys %homes){
	  my $d = $map->distance(Location->from_string($h),$home);
	  if($d < $::conf->{-MIN_DISTANCE_HOME}){
	    $valid = 0;
	  }
	}
	if($valid){
	  $homes{$home->to_string()} = 1;
	  print "#";
	  last;
	}
      }
      splice @neighbours,$rand,1;
    }
    last unless $#neighbours >= 0;
  }
  my @ret = ();
  for my $h (keys %homes){
    push @ret, Location->from_string($h);
  }
  return @ret;
}

sub build{
  my ($count,$homes,$exclude) = @_;

  my %ex;
  if ($exclude) {
    for my $f (@$exclude) {
      $ex{$f->to_string()} = 1;
    }
  }

  # build two cities in neihgbourhood of each home
  my %cities = ();
  for my $home (@$homes){
    # print "build citys for " . $home->to_string() . ": ";
    my @neighbours = $map->neighbours($home);

    # exclude non buildable terrain
    my $i = 0;
    for my $n (@neighbours){
      my $nstr = $n->to_string();
      if($ex{$nstr}){
	splice @neighbours,$i,1;
      }
      $i++;
    }

    # build citys
    my $cities = $::conf->{-NEIGHBOUR_CITIES};
    while($cities){
      my $r = rand($#neighbours+1);
      my $rstr = $neighbours[$r]->to_string();
      # print "  build city in $rstr\n";
      $cities{$rstr} = 1;
      $ex{$rstr} = 1;
      splice @neighbours,$r,1;
      $cities--;
    }

    # exclude all remaining neighbours
    for my $n (@neighbours){
      $ex{$n->to_string()} = 1;
    }
  }

  # distribute the remaining cities to fields, which are not neighbours of a home
  while($count){
    my $random = $map->random()->to_string();
    unless(exists $ex{$random}){
      $ex{$random} = 1;
      $cities{$random} = 1;
      $count--;
    }
  }

  # TODO: clustering check, no more than n in 2distance

  return map Location->from_string($_), keys %cities;
}

# DEPRECATED, this function is no longer in use!
# returns all fields, which are plain and have
# - 4 or more neighbours ISLAND or WATER
# - no city as neighbour
# - more than 2 citys as neighbour
# - more than 7 citys with distance 2
sub bad_home{
  my($water,$islands,$pole,$cities,$mountains) = @_;

  print "look for bad home locations ...\n";

  # my @m = @$mountains; print "mountains: $#m\n";

  # reorganize data into hashes
  my %ex;
  for my $f (@$water,@$islands,@$pole){
    $ex{$f->to_string()} = 1;
  }
  my %cit;
  for my $c (@$cities){
    $cit{$c->to_string()} = 1;
  }
  my %mount;
  for my $m (@$mountains){
    $mount{$m->to_string()} = 1;
  }

  # for all fields
  my %ret;
  for my $x (0..($n*2-1)){
    for my $y (0..($n-1)){
      my $lstring = "$x\_$y";
      next if exists $ex{$lstring};
      next if exists $cit{$lstring};
      print ".";
      my $loc = new Location($x,$y);

      # look in the neighboorhood
      my @neighbours = $map->neighbours($loc);
      my ($city,$water,$mount) = (0,0,0);
      for my $n (@neighbours){
	$city++ if exists $cit{$n->to_string()};
	$water++ if exists $ex{$n->to_string()};
	#	$mount++ if exists $mount{$n->to_string()};
      }
      #      $ret{$lstring} = 'no mountain in neighbourhood' if $mount == 0;
      $ret{$lstring} = 'no city in neighbourhood' if $city == 0;
      $ret{$lstring} = 'more than 3 cities in neighbourhood' if $city > 3;
      $ret{$lstring} = 'to much water in neighbourhood' if $water > 3;
      next if $ret{$lstring};

      # look in distance 2
      my @dist_neigh = $map->distant_neighbours($loc,2);
      $city = 0; $mount = 0;
      for my $n (@dist_neigh){
	$city++ if exists $cit{$n->to_string()};
	$mount++ if exists $mount{$n->to_string()};
      }
      # print "m: $mount, c: $city\n";
      $ret{$lstring} = 'more than 7 cities in distance 2' if $city > 7;
      $ret{$lstring} = 'less than 2 cities in distance 2' if $city < 2;
      $ret{$lstring} = 'no mountain in distance 2' unless $mount;
    }
  }
  print "\n";
  my @ret;
  my %stat;
  for my $r (keys %ret){
    $stat{$ret{$r}}++;
    push @ret, Location->from_string($r);
  }
  print Dumper \%stat;
  return @ret;
}

sub vulcano{
  my ($count, $w,$p) = @_;
  my @w = @$w;
  my @p = @$p;

  my @islands;

  while ($count) {
    my $water_field = floor(rand($#w) + 1);
    my $wf = $w[$water_field];

    my $to_close = 0;
    for my $p (@p) {
      $to_close = 1 if($map->distance($p,$wf) < 2);
    }
    next if $to_close;

    splice @w,$water_field,1;
    push @islands, $wf;
    $count--;
  }
  return @islands;
}

sub flood{
  my ($count, @w) = @_;
  # print "flood($count,@w)\n";

  # flood neighbours
  my @new_w;
  for my $pole (@w) {
    push @new_w, $map->neighbours($pole);
  }
  $count -= $#new_w + 1;
  return @new_w unless $count > 0;

  my %w;
  for my $w (@w,@new_w) {
    $w{$w->to_string()} = 1;
  }
  @w = @new_w;

  while ($count) {
    # print "$count ";
    # get a random water field
    my $water_field = floor(rand($#w) + 1);
    my $wf = $w[$water_field];
    # get neigbours without water 
    my @nb = $map->neighbours($wf);
    my @nb_new;
    for my $nb (@nb) {
      unless (exists $w{$nb->to_string()}) {
	push @nb_new, $nb;
      }
    }
    @nb = @nb_new;

    if ($#nb > 0) {
      # get a random neigbour
      my $rn = floor(rand($#nb) + 1);
      my $rnr = $nb[$rn];
      push @w,$rnr;
      $w{$rnr->to_string()} = 1;
      $count --;
    }
  }
  return @w;
}

# distributes $count locations at the map in minimal distance from
# fields not at exclude
# TODO: should be in Map.pm.
# TODO: should incorporate build() and vulcano()
# TODO: make shure there is really no field left.
sub distribute{
  my ($count,$dist,$min_selfdist,$wanted_selfdist,$exclude,@fields) = @_;
  my $fields_distance = 2;
  my $selfdist = $wanted_selfdist;

  # print "minself: $min_selfdist, wantedself: $wanted_selfdist\n";

  # print "fields: @fields\n";

  #print "Exclude: " . print_list(@$exclude);

  my @return_fields;

  my %ex;
  if ($exclude) {
    for my $f (@$exclude) {
      $ex{$f->to_string()} = 1;
    }
  }

  my $loop = $earthlings * 10;
  my $maxloop = $loop;
  my $short_allowed = 0;
  while ($loop and $count) {
    #  while($count){
    my $r = $map->random();
    my $valid = 1;
    #    if ($valid) {
    for my $xy (@fields) {
      my $d = $map->distance($r,$xy);	
      my ($x,$y) = $xy->get();

      if ($d < $dist) {
	$valid = 0;
	last;
      }
    }
    my $short_count = 0;
    for my $xy (@return_fields) {
      my $d = $map->distance($r,$xy);	
      my ($x,$y) = $xy->get();

      if ($d < $selfdist) {
	if($d >= $selfdist - 1 and $short_count < 1 and $short_allowed){
	  $short_count++;
	  print $short_count;
	}else{
	  $valid = 0;
	  last;
	}
      }
    }
    for my $x (@$exclude){
      if($r->to_string() eq $x->to_string()){
	$valid = 0;
	last;
      }
    }
    # }

    if ($valid) {
      # push @fields, $r;
      push @return_fields, $r;
      $count--;
      print "+";
    } else {
      $loop--;
      # print "-";
      if($loop <= 0 and ($selfdist > $min_selfdist)){
	$loop = $maxloop;
	# $selfdist--;
	# print $selfdist;
	$short_allowed = 1;
	print "S";
      }

      next;
    }
    # print "c: $count, l: $loop\n";
    # }
  }

  print "\n";
  unless($loop){
    print "need still room for $count locations\n";
    return 0;
  }
  return @return_fields;
}

sub print_list{
  my @f = @_;
  my $string;
  for my $l (@f){
    $string .= $l->to_string() . ', ';
  }
  $string .= "\n";
  return $string;
}

