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
# Generell database methods are gathered here.
use strict;
use DBI;
use POSIX qw(floor);
use FROGS::Config qw($conf);
use FROGS::Util;
use Date::Parse qw(str2time);
use Date::Calc qw(Time_to_Date Delta_DHMS);

package DataBase;

# the constructor connects to the DB
sub new{
  my ($class,$dbh) = @_;
  my $self = {};
  if (defined $dbh){
    $self->{-dbh} = $dbh;
  }else{
  	$self->{-dbh} = DBI->connect("dbi:$::conf->{-DB_SOURCE}",
				       $::conf->{-DB_USER},
				       $::conf->{-DB_PASSWD},
				       {'RaiseError' => 1, 'AutoCommit' => 0}
                				              );
  }
  #TODO: should specify iso date and time format explicitly for the session!!

  $self->{-lang} = $self->{-dbh}->quote($::conf->{-DEFAULT_LANGUAGE});

  bless ($self,$class);
}

sub commit{
  my $self = shift;
  unless(defined $self->{-nowrite}){
    $self->{-dbh}->commit();
    Util::log('committed.',2);
  }
}

sub nowrite{
  my $self = shift;
  Util::log("DataBase: nowrite activated!",1);
  $self->{-nowrite} = 1;
}

# automaticly called destructor
sub DESTROY{
  my $self = shift;
  $self->{-dbh}->disconnect();
}

# wrapper for database functions:

sub quote{
  my ($self, $text) = @_;
  return $self->{-dbh}->quote($text);
}

sub quote_all{
  my ($self, @plain) = @_;
  my @quoted;
  for my $s (@plain){
    push @quoted, $self->{-dbh}->quote($s);
  }
  return @quoted;
}

# this does not support any possible SQL-conditions
# just a small subset
# TODO: this function is really ugly :-(
# TODO: just use an escape-character in calls to mark, which fields should be
# TODO: quoted
sub quote_condition{
  my ($self, $cond) = @_;

  Util::log("condition: $cond",2);

  my @bracket = ('(',')');
  my @bool = ('AND', 'OR');
  my @ops = ('=', '!=');
  my @noops = ('<'); # forbidden substrings of pairs. ugly workaround for "time < now()"

  # split string at boolean operators
  my $splitstring = '';
  for my $bool (@bool){
    $splitstring .= '\b'.$bool.'\b|';
  }
  $splitstring =~ s/(.*)\|/$1/;

  #Util::log("splitstring: $splitstring\n",2);

  my @pairs = split /\s$splitstring\s/, $cond;

  Util::log("pairs: @pairs",2);

  my $opstring = '';
  for my $o (@ops){
    $opstring .= "$o|";
  }
  $opstring =~ s/(.*)\|/$1/;

  my $noopstring = '';
  for my $no (@noops){
    $noopstring .= "$no|";
  }
  $noopstring =~ s/(.*)\|/$1/;

  # quote right hand of operator if necessary
  for my $pair (@pairs){
    next if $pair =~ /$noopstring/;
    my ($left,$right) = split /$opstring/, $pair;
    #Util::log("1 left: $left, right: $right",2);
    $right =~ s/^\(*-?([\w\s].*)$/$1/; # remove leading brackets
    #Util::log("2 left: $left, right: $right",2);
    $right =~ s/-?(.*[\w\s])\)*$/$1/; # remove trailing brackets
    #Util::log("3 left: $left, right: $right",2);
    $right =~ s/^\s*-?(\S.*)/$1/; # remove leading whitespace
    #Util::log("4 left: $left, right: $right",2);
    $right =~ s/(.*\S)\s*$/$1/; # remove trailing whitespace
    #Util::log("5 left: $left, right: $right",2);

    next if $right =~ /^\d+$/;
    # this could be misfunctional in some SQL-Dialect. We assume single-quotes
    my $qright = ($right =~ /^\'.*\'/) ? $right : $self->quote($right);

    # Util::log("qright: $qright",2);
    next if $cond =~ /$qright/;
    $cond =~ s/($opstring\s*)$right/$1$qright/;
  }
  Util::log("new condition: $cond",2);
  return $cond;
}

# assumes that a single row is returned from database
# returns a list of selected columns
sub single_select{
  my ($self,$stmt) = @_;

  Util::log("single_select: $stmt",2);
  my $dat = $self->{-dbh}->selectall_arrayref($stmt);
  return () if not defined $dat or not defined $dat->[0];
  return @{$dat->[0]};
}

sub single_hash_select{
	my ($self,$table,$cond) = @_;

	$cond = $self->quote_condition($cond);
	my $stmt = "SELECT * FROM $table where $cond";
	Util::log("single_hash_select: $stmt",2);
	return $self->{-dbh}->selectrow_hashref($stmt);
}	

sub select_hash{
  my ($self, $table, $key, $fields, $cond) = @_;

  my $stmt = $fields ? "SELECT $key, $fields FROM $table"
                     : "SELECT $key FROM $table";
  $stmt .= " WHERE $cond" if $cond;
  return $self->{-dbh}->selectall_hashref($stmt, $key);
}

sub select_array{
  my ($self, $table, $fields, $cond, $order) = @_;
  my $stmt = "SELECT $fields FROM $table";
  if( $cond){
    $cond = $self->quote_condition($cond);
    $stmt .= " WHERE $cond";
    if(defined $order){
      $stmt .= " ORDER BY $order";
    }
  }

  Util::log("select_array: $stmt",2);
  return $self->{-dbh}->selectall_arrayref($stmt);
}

# returns number of fields with given condition
sub count{
  my ($self, $table, $cond) = @_;
  my $array = $self->select_array($table,'*',$cond);
  my @a = @$array;
  my $count = $#a + 1;
  Util::log("counted $cond in $table: $count",1);
  return $count;
}

# insert a row in one table of the database
#
# parameterlist:
#   table: the database-table we work on
#   hash:  give here a hash with the new values
#   noquote: if hash, than dont quote all keys which are in this hash,
#            if no hash but defined, than we dont quote all the new values
#            (useful for things simmilar to COUNT = COUNT + 1)
sub insert_hash{
  my ($self, $table, $hash,$noquote) = @_;
  my $noquote_type = ref($noquote);
  my $noquote_global = 1 if defined $noquote and not $noquote_type eq 'HASH';
  my $noquote_hash = 1 if $noquote_type eq 'HASH';

  my $insert = "INSERT INTO $table (";
  for my $key (keys %$hash){
    # $key = $self->{-dbh}->quote_identifier($key);
    $insert .= "$key,";
  }
  chop($insert);
  $insert .=") VALUES (";
  while( my ($k,$val) = each %$hash){
    $val = $self->quote($val) if not $noquote_global or
      ($noquote_hash and exists $noquote->{$k});
    $insert .= "$val,";
  }
  chop($insert);
  $insert .= ')';

  Util::log("INSERT: $insert",2);
  my $h = $self->{-dbh}->prepare($insert);
  $h->execute();
  $h->finish();
}

# parameter: see insert_hash() and update_hash()
sub insert_or_update_hash{
  my ($self, $table, $cond, $hash, $noquote) = @_;
  $cond = $self->quote_condition($cond);
  my @row = $self->single_select("SELECT * FROM $table WHERE $cond");
  use Data::Dumper;
  if($#row >= 0){
    $self->update_hash($table,$cond,$hash,$noquote);
  }else{
    $self->insert_hash($table,$hash,$noquote);
  }
}

# update a set of rows in one table of the database
#
# parameterlist:
#   table: the database-table we work on
#   cond:  only rows are effected, which evaluates this condition as true
#   hash:  give here a hash with the new values
#   noquote: if hash, than dont quote all keys which are in this hash,
#            if no hash but defined, than we dont quote all the new values
#            (useful for things simmilar to COUNT = COUNT + 1)
sub update_hash{
  my ($self, $table, $cond, $hash, $noquote) = @_;
  my $noquote_type = ref($noquote);
  my $noquote_global = 1 if defined $noquote and not $noquote_type eq 'HASH';
  my $noquote_hash = 1 if $noquote_type eq 'HASH';

  my $stmt = "UPDATE $table SET ";
  while( my ($k,$v) = each %$hash){
    $v = $self->quote($v) if not $noquote_global or
      ($noquote_hash and exists $noquote->{$k});
    $stmt .= "$k=$v,";
  }
  chop($stmt);

  $stmt .= " WHERE ". $self->quote_condition($cond);

  Util::log("update_hash: $stmt",2);
  my $h = $self->{-dbh}->prepare($stmt);
  $h->execute();
  $h->finish();
}

sub delete_from{
  my ($self,$table,$cond) = @_;

  die "do you really want to delete a complete table?" unless $cond;

  my $sql = "DELETE FROM $table";
  if($cond){
    $cond = $self->quote_condition($cond);
    $sql .= " WHERE $cond";
  }
  Util::log($sql,2);
  my $dbh = $self->{-dbh};
  my $h = $dbh->prepare($sql);
  $h->execute();
  $h->finish();
}

sub find_first_free{
  my ($self,$table,$field) = @_;

  my $t = $self->select_array($table, $field);
  my @ids = sort {$a <=> $b} (map {$_->[0]} @$t);

  my $id = 1;
  for my $try (@ids){
    next if $try < 0; # unfortunately some tabels contain the id -1 and id 0 is free :-(
    last if $id < $try;
    $id = $try + 1;
  }
  return $id;
}

sub read_game{
  my ($self,$game,$field) = @_;
  my $stmt = "SELECT $field from GAME where GAME=$game";
  return $self->single_select($stmt);
}

# localisation

sub set_language{
  my ($self, $lang) = @_;
  $self->{-lang} = $self->{-dbh}->quote($lang) if $lang;
}

# returns the localisation of a tag. 
# if the result contains tags again, localize these too.
sub loc{
  my ($self, $tag, @args) = @_;

  Util::log("args: @args",2);

  $tag = $self->{-dbh}->quote($tag);
  my $stmt = 'SELECT TEXT FROM LOCALIZE WHERE LANGUAGE='.$self->{-lang}." AND TAG=$tag";
  my ($text) = $self->single_select($stmt);

  # replace %x with arg[x]
  while($text =~ /\%(\d+)/){
    my $nr = $1;
    Util::log("found $nr in $text",2);
    $text =~ s/(\%$nr)/$args[$nr-1]/g;
  }

  return $text =~ /^\s*$/ ? "Error: Tag $tag not defined for language $self->{-lang}."
    : $self->localize_string($text);
}

# calls loc() for all uppercase-only-words and returns new string
# TODO: allow arguments in brackets after uppercase-words with length >= 3
sub localize_string{
  my ($self,$string) = @_;

  $string =~ s/(\b[^\Wa-z0-9]{3,}\b)/$self->loc($1)/ge;
  return $string;
}

# game management:

sub new_account{
  my ($self,$login,$name,$email,$lang) = @_;

  my ($qlogin,$qname,$qemail) = $self->quote_all($login,$name,$email);

  my $cond = "LOGIN=$qlogin OR REALNAME=$qname OR EMAIL=$qemail";
  my $habschon = $self->select_array('PLAYER','PLAYER',$cond);
  my @habschon = @$habschon;
  return 0 if @habschon;

  # generate new password
  my $pwd = '';
  my $allowed = '2345679ACDEFGHIJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  for my $i (0..7){
    $pwd .= substr($allowed, POSIX::floor(rand(72)), 1);
  }
  my $qpwd = $self->{-dbh}->quote($pwd);

  # search first free player ID
  my $player = $self->find_first_free('PLAYER','PLAYER');

  # write new player
  $self->insert_hash('PLAYER', {PLAYER   => $player,
 				REALNAME => $name,
				LOGIN    => $login,
 				EMAIL    => $email,
 				PASSWORD => $pwd,
				LANGUAGE => $lang,
 			       });
  $self->commit();

  my $mail = "From: registration\@aymargeddon.de\nTo: $name <$email>\n"
           . "Subject: ".$self->loc('REGISTER_MAIL_SUBJECT')."\n\n"
           . $self->loc('REGISTER_MAIL_TEXT', $name, $login, $pwd)."\n";

  # print $mail;
# aus man mail:
#           env MAILRC=/dev/null from=scriptreply@domain smtp=host \
#                smtp-auth-user=login smtp-auth-password=secret \
#               smtp-auth=login mailx -n -s "subject" \
#              -a attachment_file recipient@domain <content_file

  open(SENDMAIL, "|mail $email") or Util::log("Can't fork for sendmail: $!",0);
  print SENDMAIL $mail;
  close(SENDMAIL) or Util::log("sendmail didn't close nicely",0);

  return $pwd;
}

sub authenticate{
  my ($self, $user, $pwd, $pwd2, $pwd3 ) = @_;

  my $admin = $self->quote('admin');
  # you can log into any account with adminpassword
  my ($adminpwd) = $self->single_select("SELECT PASSWORD FROM PLAYER ".
					"WHERE LOGIN=$admin");
  ($user,$pwd,$adminpwd) = $self->quote_all($user,$pwd,$adminpwd);


  # Util::log("Adminpassword: $adminpwd, password: $pwd",2);

  my ($player, $sec);
  if($adminpwd eq $pwd){
    my $stmt = "SELECT PLAYER,SECURITY FROM PLAYER WHERE ".
      "LOGIN=$user";
    ($player, $sec) = $self->single_select($stmt);
  }else{
    my $stmt = "SELECT PLAYER,SECURITY FROM PLAYER WHERE ".
    "LOGIN=$user AND PASSWORD=$pwd";
    ($player, $sec) = $self->single_select($stmt);
  }

  if($player){
    if($pwd2 and $pwd3 and $pwd2 eq $pwd3){
      # change password!
      $self->update_hash('PLAYER',
			 "LOGIN=$user",
			 {'PASSWORD' => $pwd2});
      Util::log("password changed!",0); # todo: localize and aufhübschen
    }
    # TODO: write last_login
    return $player;
  }
  return 0;
}

sub write_event{
  my ($self, $content) = @_;

  $self->insert_hash('EVENT', $content);
}

sub read_event{
  my ($self, $id) = @_;

  my $e = $self->single_hash_select('EVENT',"ID=$id");
  my @args;
  for my $a (1..($::conf->{-MAX_ARGS})){
    Util::log("search for ARG$a...",2);
    push @args, $e->{"ARG$a"};
  }

  Util::log("args in read_event: @args",2);

  my ($loc,$to);
  $to = $e->{'LOCATION'} || 'Game';

  return ($to,$e->{'TIME'},$self->loc($e->{'TAG'},@args));
}

sub delete_event{
  my ($self, $id) = @_;
  $self->delete_from('EVENT',"ID=$id");
}

sub send_message{
  my ($self, $msg_hash) = @_;

  $msg_hash->{'TIME'} = $self->now();
  $self->insert_hash('MESSAGE',$msg_hash);
}

sub read_message{
  my ($self, $id) = @_;

  my $stmt = "SELECT TIME, MFROM, MSG_TAG, MSG_TEXT, ARG1, ARG2, ARG3, ARG4 ".
    "FROM MESSAGE WHERE ID=$id";
  my ($time, $from, $tag, $text, @args) = $self->single_select($stmt);

  # localize it
  if($tag){
    # print "tag!";
    $text = $self->loc($tag, @args);
    return ($time, $from, $text, @args);
  }elsif($text){
    # print "text!";
    $text = $self->localize_string($text) unless $from;
    return ($time, $from, $text);
  }else{
    return (0, 'unknown message type error in DataBase');
  }
}

sub delete_message{
  my ($self, $id) = @_;

  $self->delete_from('MESSAGE',"ID=$id");
}

sub read_player{
  my ($self,$player,$field) = @_;
  my $stmt = "SELECT $field from PLAYER where PLAYER=$player";
  return $self->single_select($stmt);
}

# returns all games for id -1 (admin)
sub games_of_player{
  my ($self,$player) = @_;

  if($player > 0){
    return $self->select_array('ROLE','GAME',"PLAYER=$player");
  }else{
    return $self->select_array('GAME','GAME');
  }
}

sub open_games{
  my ($self,$cond) = @_;
  my $games = $self->select_array('GAME','GAME');

  my @log;
  for my $game (@$games){
      Util::log( Dumper($game)."\n",1);
    my $c = "GAME=". $game->[0];
    $c .= " AND $cond" if $cond;
      Util::log($c."\n",1);
    my $unused = $self->select_array('MAP','LOCATION','',$c);
    
    print $unused;

      Util::log(Dumper(@$unused),1);
      
    push @log, $game->[0] if @$unused + 1;
  }
  return \@log;
}

sub read_single_mobile{
  my($self,$id) = @_;

  return $self->single_hash_select('MOBILE',"ID=$id");
}

sub now{
  my $self = shift;
  my ($ret) = $self->single_select("SELECT NOW()");
  return $ret;
}

# generates a relative time string from an absolute time
sub relative{
  my ($self, $absolute) = @_;

  my $now = $self->now();
  # print "now: $now\nabsolute: $absolute\n";

  my $now_unix = Date::Parse::str2time($now,'GMT');
  my $absolute_unix = Date::Parse::str2time($absolute,'GMT');
  # print "now_unix: $now_unix\nabsolute_unix: $absolute_unix\n";
  my $diff = $absolute_unix - $now_unix;

  if($diff > 0){

    my ($days,$hours,$minutes,$seconds) = 
      Date::Calc::Delta_DHMS(1970,1,1,0,0,0,Date::Calc::Time_to_Date($diff));

    if($days){
      return $self->loc('TIME_WITH_DAYS',$days,$hours,$minutes,$seconds);
    }elsif($hours){
      return $self->loc('TIME_WITH_HOURS',$hours,$minutes,$seconds);
    }elsif($minutes){
      return $self->loc('TIME_WITH_MINUTES',$minutes,$seconds);
    }else{
      return $self->loc('TIME_WITH_SECONDS',$seconds);
    }
  }else{ # $diff <= 0
    return '';
  }
}

1;


