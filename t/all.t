#!/usr/bin/perl -w

use strict;
use Test;

# First check that the module loads OK.
use vars qw($loaded);
BEGIN { $| = 1; plan tests => 18; }
END {print "not ok 1\n" unless $loaded;}
use Mail::Field::Received;
print "! Testing module load ...\n";
ok(++$loaded);

use Data::Dumper;


print "! Testing constructor ...\n";
my $received = Mail::Field->new('Received');
ok($received);
ok($received->tag(), 'Received');

print "! Testing setting debug level ...\n";
$received->debug(5);
ok($received->debug(), 5);


print "! Testing parsing ...\n";
my $in = 'from tr909.mediaconsult.com (mediacons.tecc.co.uk [193.128.6.132]) by host5.hostingcheck.com (8.9.3/8.9.3) with ESMTP id VAA24164 for <adam@spiers.net>; Tue, 1 Feb 2000 21:57:18 -0500';
print "!   date format 3\n";
ok($received->parse($in));
ok($received->parsed_ok());
my $parse_tree = {
                  'by' => {
                           'domain' => 'host5.hostingcheck.com',
                           'whole' => 'by host5.hostingcheck.com'
                          },
                  'date_time' => {
                                  'year' => 2000,
                                  'week_day' => 'Tue',
                                  'minute' => 57,
                                  'day_of_year' => '1 Feb',
                                  'month_day' => ' 1',
                                  'zone' => '-0500',
                                  'second' => 18,
                                  'hms' => '21:57:18',
                                  'date_time' => 'Tue, 1 Feb 2000 21:57:18 -0500',
                                  'hour' => 21,
                                  'month' => 'Feb',
                                  'rest' => '2000 21:57:18 -0500',
                                  'whole' => 'Tue, 1 Feb 2000 21:57:18 -0500'
                                 },
                  'with' => {
                             'with' => 'ESMTP',
                             'whole' => 'with ESMTP'
                            },
                  'from' => {
                             'domain' => 'mediacons.tecc.co.uk',
                             'HELO' => undef,
                             'address' => '193.128.6.132',
                             'comments' => [
                                            '(mediacons.tecc.co.uk [193.128.6.132])',
                                            '(8.9.3/8.9.3)',
                                           ],
                             'whole' => 'from tr909.mediaconsult.com (mediacons.tecc.co.uk [193.128.6.132])
 (8.9.3/8.9.3)
'
                            },
                  'id' => {
                           'id' => 'VAA24164',
                           'whole' => 'id VAA24164'
                          },
                  'comments' => [
                                 '(mediacons.tecc.co.uk [193.128.6.132])',
                                 '(8.9.3/8.9.3)'
                                ],
                  'for' => {
                            'for' => '<adam@spiers.net>',
                            'whole' => 'for <adam@spiers.net>'
                           },
                  'whole' => 'from tr909.mediaconsult.com (mediacons.tecc.co.uk [193.128.6.132]) by host5.hostingcheck.com (8.9.3/8.9.3) with ESMTP id VAA24164 for <adam@spiers.net>; Tue, 1 Feb 2000 21:57:18 -0500'
                 };
ok(equal_hashes($parse_tree, $received->parse_tree()));


print "!   date format 3 again\n";
$in = '(qmail 7119 invoked from network); 22 Feb 1999 22:01:53 -0000';
$received->parse($in);
ok($received->parsed_ok());
$parse_tree = {
               'date_time' => {
                               'year' => 1999,
                               'week_day' => undef,
                               'minute' => '01',
                               'day_of_year' => '22 Feb',
                               'month_day' => 22,
                               'zone' => '-0000',
                               'second' => 53,
                               'date_time' => '22 Feb 1999 22:01:53 -0000',
                               'hms' => '22:01:53',
                               'hour' => 22,
                               'month' => 'Feb',
                               'rest' => '1999 22:01:53 -0000',
                               'whole' => '22 Feb 1999 22:01:53 -0000'
                              },
               'comments' => [
                              '(qmail 7119 invoked from network)'
                             ],
               'whole' => '(qmail 7119 invoked from network); 22 Feb 1999 22:01:53 -0000'
              };
ok(equal_hashes($parse_tree, $received->parse_tree()));


print "!   date format 1\n";
my $new_date = '22 Feb';
my $new_rest = '22:01:53 1999 -0000';
my $new_date_time = "$new_date $new_rest";
$in = "(qmail 7119 invoked from network); $new_date_time";
$received->parse($in);
ok($received->parsed_ok());
$parse_tree->{date_time}{whole} = $new_date_time;
$parse_tree->{date_time}{date_time} = $new_date_time;
$parse_tree->{date_time}{rest} = $new_rest;
$parse_tree->{whole} = $in;
ok(equal_hashes($parse_tree, $received->parse_tree()));


print "!   date format 2\n";
$new_date = '22 Feb';
$new_rest = '22:01:53 -0000 1999';
$new_date_time = "$new_date $new_rest";
$in = "(qmail 7119 invoked from network); $new_date_time";
$received->parse($in);
ok($received->parsed_ok());
$parse_tree->{date_time}{whole} = $new_date_time;
$parse_tree->{date_time}{date_time} = $new_date_time;
$parse_tree->{date_time}{rest} = $new_rest;
$parse_tree->{whole} = $in;
ok(equal_hashes($parse_tree, $received->parse_tree()));


print "! Testing different constructor method ...\n";
$in = 'from lists.securityfocus.com (lists.securityfocus.com [207.126.127.68]) by lists.securityfocus.com (Postfix) with ESMTP id 1C2AF1F138; Mon, 14 Feb 2000 10:24:11 -0800 (PST)';
my $received2 = Mail::Field->new('Received', $in);
ok($received2->parsed_ok());
$parse_tree = {
               'by' => {
                        'domain' => 'lists.securityfocus.com',
                        'whole' => 'by lists.securityfocus.com'
                       },
               'date_time' => {
                               'year' => 2000,
                               'week_day' => 'Mon',
                               'minute' => 24,
                               'day_of_year' => '14 Feb',
                               'month_day' => 14,
                               'zone' => '-0800 (PST)',
                               'second' => 11,
                               'date_time' => 'Mon, 14 Feb 2000 10:24:11 -0800 (PST)',
                               'hour' => 10,
                               'hms' => '10:24:11',
                               'month' => 'Feb',
                               'rest' => '2000 10:24:11 -0800 (PST)',
                               'whole' => 'Mon, 14 Feb 2000 10:24:11 -0800 (PST)'
                              },
               'with' => {
                          'with' => 'ESMTP',
                          'whole' => 'with ESMTP'
                         },
               'from' => {
                          'domain' => 'lists.securityfocus.com',
                          'HELO' => undef,
                          'address' => '207.126.127.68',
                          'comments' => [
                                         '(lists.securityfocus.com [207.126.127.68])',
                                         '(Postfix)'
                                        ],
                          'whole' => 'from lists.securityfocus.com (lists.securityfocus.com [207.126.127.68])
 (Postfix)
'
                         },
               'id' => {
                        'id' => '1C2AF1F138',
                        'whole' => 'id 1C2AF1F138'
                       },
               'comments' => [
                              '(lists.securityfocus.com [207.126.127.68])',
                              '(Postfix)'
                             ],
               'whole' => 'from lists.securityfocus.com (lists.securityfocus.com [207.126.127.68]) by lists.securityfocus.com (Postfix) with ESMTP id 1C2AF1F138; Mon, 14 Feb 2000 10:24:11 -0800 (PST)'
              };
ok(equal_hashes($parse_tree, $received2->parse_tree()));


print "Testing stringify() ...\n";
ok($received2->stringify(), $in);


print "Testing diagnostics code ...\n";
ok($received2->diagnostics()); # bit difficult to check this one properly
$received2->diagnose('squr', 'gle');
ok($received2->diagnostics(), '/squrgle/');



exit 0;


##############################################################################

sub equal_hashes {
  my ($a, $b) = @_;

  my @a = sort keys %$a;
  my @b = sort keys %$b;
  
  my $diags = '';
  
  while (my $p = shift @a and my $q = shift @b) {
#   print "Comparing `$p' and `$q' ...\n";
    
    if (defined($p) xor defined($q)) {
      print "first key undefined\n" unless defined($p);
      print "second key undefined\n" unless defined($q);
      return 0;
    }
    if ($p ne $q) {
      print "`$p' ne `$q'\n";
      return 0;
    }
    if (defined($a->{$p}) xor defined($b->{$q})) {
      print "first value (key `$p') undef\n" unless defined($a->{$p});
      print "second value (key `$q') undef\n" unless defined($b->{$q});
      return 0;
    }
    elsif (! defined($a->{$p}) and ! defined($b->{$q})) {
      next;
    }
    elsif (ref($a->{$p}) ne ref($b->{$q})) {
      print "ref mismatch on values for `$p' and `$q'\n";
      return 0;
    }
    elsif (ref($a->{$p}) eq 'HASH') {
      # recursion rules
      return 0 unless equal_hashes($a->{$p}, $b->{$q});
    }
    elsif (ref($a->{$p}) eq 'ARRAY') {
      return 0 unless equal_arrays($a->{$p}, $b->{$q});
    }
    elsif (ref($a->{$p})) {
      die "found unsupported type of ref\n" .
          "(value of `$p' was " . ref($a->{$p}) . " ref)";
    }
    else {
      if ($a->{$p} ne $b->{$q}) {
        print "key `$p': `$a->{$p}' ne `$b->{$q}'\n";
        return 0;
      }
    }
  }

  return 1;
}

sub equal_arrays {
  my ($a, $b) = @_;

  local $^W = 0;  # silence spurious -w undef complaints
  if (@$a != @$b) {
    print "Array of different length\n";
    return 0;
  }
  
  for (my $i = 0; $i < @$a; $i++) {
#   print "Comparing `$a->[$i]' and `$b->[$i]' ...\n";
    return 0 if $a->[$i] ne $b->[$i];
  }
  return 1;
}
  
