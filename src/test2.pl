use strict;
use FROGS::DataBase;
use Data::Dumper;
use Aymargeddon;
use AymCommand;
use FROGS::Command;

$| = 1;

use FROGS::Config qw($conf);

$::conf->{-DEBUG} = 2;

# $::conf->{-DEBUG} = 2;

my $db =  new DataBase();

my $dbhash = {
    "PLAYER" => 5,
    "GAME" => 1,
    "ID" => 2,
    "LOCATION" => "2_0",
};

my $command = BUILD_ARK->new($dbhash,$db);

print $command->first_phase_ajax()."\n";





#$db->update_hash('MOBILE',
#		 "LOCATION=0_1",
#		 {'COUNT' => 'COUNT + 1'},'noquote');

#$db->commit();

# print $db->relative("2004-05-13 03:40:37") ."\n";

#my $aym = new Aymargeddon(1,3,$db,'DE');

#print $aym->show_statistic();

# print $aym->read_single_relation(1,2). "\n";

#print "place is: $place.\n";

# print Dumper $::conf;
# exit;

#my $d = DataBase->new();
#$d->nowrite();

