use FROGS::DataBase;
# use Aymargeddon;
# use DBI;
use strict;
use Data::Dumper;
use Date::Calc qw(Time_to_Date);

use FROGS::Command;

use FROGS::Config qw($conf);

$| = 1;

my $d = DataBase->new();
# $d->nowrite();

my $dbhash =
#  {'LOCATION' => '2_0',
#   'COMMAND' => 'BUILD_TEMPLE',
#   'ARGUMENTS' => 'MOBILE=1',
#   'PLAYER' => 1,
#   'GAME' => 1,
#   'ID' => 1007
#  };
  {'LOCATION' => '11_3',
   'COMMAND' => 'PRODUCE',
   'ARGUMENTS' => 'ROLE=-1',
   'PLAYER' => -1,
   'GAME' => 4,
   'ID' => 1007,
  };


# print Dumper $dbhash;

require "AymCommand.pm";

my $c = $dbhash->{'COMMAND'}->new($dbhash,$d);

# print "is valid\n" if $c->is_valid();
$c->{-phase} = 1;
my $fp = $c->first_phase();

if ($fp){
  print "first phase correct. duration: $c->{-duration}\n";
  $c->{-phase} = 2;
  print "second phase correct\n" if $c->second_phase();
}else{
  print "no second phase\n";
}

$d->commit();

# $d->{-dbh}->disconnect();

# print Dumper $c;






