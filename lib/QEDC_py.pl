#!/usr/bin/env perl
##!/usr/bin/perl
#mark a#
# This perl script is written for python users to call the perl module "QEDC.pm". Users do not need to invoke this script directly.
# usage: 
#   chmod +x QEDC_py.pl; ./QEDC_py.pl "type" "data"

use v5.21.1;
use utf8;
use strict;
use warnings;
# use YAML;   # say Dump
use POSIX qw/ ceil floor /;
use Data::Dump qw/ dump /;  #dump @AoA;
use lib $ENV{HOME} . '/perl/lib/';
use QEDC qw/ 
  encode_q_cs_v1 
  encode_q_cs_v2 
  is_intact_q_cs_v1 
  is_intact_q_cs_v2 
  decode_q_cs_v1 
  decode_q_cs_v2 
  encode_q_redun_v1 
  encode_q_redun_v2 
  is_intact_q_redun_v1 
  decode_q_redun_v1 
  decode_q_redun_v2 
  encode_comb_q_cs_redun 
  decode_comb_q_cs_redun 
  encode_q_hamming 
  decode_q_hamming 
  ref_to_RAR 
  /;
#mark b#
# naming convention: 1. A: array; 2. H: hash; 3. R: reference; 4. Sr: subroutine; 5. crt: correct; 6. err: error; 7. RAR: references to array of references; 8. 

# @ARGV = ("encode_q_redun", "0123 2231", );
# my $type = "encode_q_cs ";   # type
# my $a_in = "0123";    # input data
my $type = shift @ARGV;
my $a_in = shift @ARGV;
die "Type undefined!" unless defined $type;
$type =~ s/\s//g;
if ( "encode_q_cs" =~ $type ){
  my ($cs, $a_out, ) = & encode_q_cs_v1 ($a_in, );
  print $a_out;
} elsif ( "is_intact_q_cs" =~ $type ){
  my $is_crt = & is_intact_q_cs_v1 ($a_in, );
  print $is_crt;
} elsif ( "decode_q_cs" =~ $type ){
  my $q = shift @ARGV;
  my $a_crt = & decode_q_cs_v1 ($a_in, $q, );
  print $a_crt;
} elsif ( "encode_q_redun" =~ $type ){
  # $a_in : one string of strings separated by spaces
  my $a_R = [ split /\s+/, $a_in ];   
  my ($redun, $c_R, ) = & encode_q_redun_v1 ($a_R, );
  print dump $c_R;
} elsif ( "is_intact_q_redun" =~ $type ){
  my $a_R = [ split /\s+/, $a_in ];
  my $is_crt = & is_intact_q_redun_v1 ($a_R, );
  print $is_crt;
} elsif ( "decode_q_redun" =~ $type ){
  # $a_in : one string of strings separated by spaces
  my $a_R = [ split /\s+/, $a_in ];
  my $q = shift @ARGV;
  my $nq = shift @ARGV;
  my $c_R = & decode_q_redun_v1 ($a_R, $q, $nq );
  print dump $c_R;
} elsif ( "encode_comb_q_cs_redun" =~ $type ){
  # $a_in : one string of strings separated by spaces
  my $a_R = [ split /\s+/, $a_in ];   
  my $c_R = & encode_comb_q_cs_redun ($a_R, );
  print dump $c_R;
} elsif ( "decode_comb_q_cs_redun" =~ $type ){
  my $c_R = [ split /\s+/, $a_in ];
  my $nq = shift @ARGV;
  my $out_R = & decode_comb_q_cs_redun ($c_R, $nq, );
  print dump $out_R;
} elsif ( "encode_q_hamming" =~ $type ){
  # $a_in : one string
  my $c = & encode_q_hamming ($a_in, );
  print $c;
} elsif ( "decode_q_hamming" =~ $type ){
  my $a = & decode_q_hamming ($a_in, );
  print $a;
}
   
#mark z#
