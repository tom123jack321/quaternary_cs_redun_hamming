#!/usr/bin/env perl
##!/usr/bin/perl
#mark a#
# Sample script for perl users to use quaternary checksum, redundancy and their combination as well as quaternary Hamming code.

use v5.21.1;
use utf8;
use strict;
use warnings;
# use YAML;   # say Dump
# use POSIX qw/ ceil floor /;
use Data::Dump qw/ dump /;  #dump @AoA;
# use lib $ENV{HOME} . '/perl/lib/';
use lib './lib/';
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

say '================================================';
say "Encoding algorithm of quaternary checksum";
my $a_in = "0123";           # change this as necessary
print '$a_in   '; say $a_in;
my ($cs, $a_out, ) = & encode_q_cs_v1 ($a_in, );
print '($cs, $a_out, )  '; map {print "|$_"; } ($cs, $a_out, ); say '|';

say '================================================';
say "Detect the occurence of errors using quaternary checksum";
# my $a_in = "30123";          # change this as necessary
my $a_in = "20123";          # change this as necessary
my $is_correct = & is_intact_q_cs_v1 ($a_in, );
print '$is_correct   '; say $is_correct;

say '================================================';
say "Decoding algorithm of quaternary checksum";
my $a_in = "30123";          # change this as necessary
my $q = 2;                   # change this as necessary
my $a_crt = & decode_q_cs_v1 ($a_in, $q, );
print 'dump ($a_in, $q, $a_crt, )   '; say dump ($a_in, $q, $a_crt, );

say '================================================';
say "Encoding algorithm of quaternary redundancy";
my $a_R = ["01223", "123", "033201", ];   # change this as necessary
print 'dump $a_R   '; say dump $a_R;
my ($redun, $c_R, ) = & encode_q_redun_v1 ($a_R, );
print '$redun   '; say $redun;
print 'dump $c_R   '; say dump $c_R;

say '================================================';
say "Detect the occurence of errors using quaternary redundancy";
# change this as necessary
my $a_R = ["01223", "123", "033201", "120031"];   # intact
# my $a_R = ["01223", "023", "033201", "120031"]; # erroneous
# my $a_R = ["01223", "12", "033201", "120031"]; # erroneous
my $is_correct = & is_intact_q_redun_v1 ($a_R, );
print '$is_correct   '; say $is_correct;

say '================================================';
say "Decoding algorithm of quaternary redundancy";
# change this as necessary
# my $a_R = ["01223", "123", "033201", "120031"];   # intact
# my $a_R = ["01223", "023", "033201", "120031"]; # erroneous
my $a_R = ["01223", "12", "033201", "120031"]; # erroneous
print 'dump $a_R   '; say dump $a_R;
my $c_R = & decode_q_redun_v1 ($a_R, 2, 3 );
print 'dump $c_R   '; say dump $c_R;

say '================================================';
say "Encoding algorithm of the combination of quaternary checksum and redundancy";
say 'Example 1, for sequences of possibly different length';
# change this as necessary
my $a_R = ["01223", "123", "033201"];   
print 'dump $a_R   '; say dump $a_R;
my $c_R = & encode_comb_q_cs_redun ($a_R, );
print 'dump $c_R   '; say dump $c_R;

say '================================================';
say 'Decoding algorithm of the combination of quaternary checksum and redundancy';
say 'Example 1, for sequences of possibly different length';
# change this as necessary
# my $c_R = ["001223", "2123", "1033201", "3120031"];   # intact
my $c_R = ["001", "2123", "1033201", "3120031"];   # erroneous
my $out_R = & decode_comb_q_cs_redun ($c_R, 5, );
print 'dump $out_R   '; say dump $out_R;

say '================================================';
say "Encoding algorithm of the combination of quaternary checksum and redundancy";
say 'Example 2, for sequences of the same length';
# change this as necessary
# my $a_R = ["01223", "12300", "03320"];  
my $a_R = ["0122310132", "1230022132", "0332013213"];  
print 'dump $a_R   '; say dump $a_R;
my $c_R = & encode_comb_q_cs_redun ($a_R, );
print 'dump $c_R   '; say dump $c_R;

say '================================================';
say "Decoding algorithm of the combination of quaternary checksum and redundancy";
say 'Example 2, for sequences of the same length';
# change this as necessary
# my $c_R = ["001223", 212300, "003320", 212003];   # intact
my $c_R = ["001", 212300, "003320", 212003];   # erroneous
my $out_R = & decode_comb_q_cs_redun ($c_R, 5, );
print 'dump $out_R   '; say dump $out_R;

say '================================================';
say "Encoding algorithm of quaternary Hamming code";
# change this as necessary
# my $a_in = "0123" . "2311" . "010";   # $c : 320012302311010
# my $a_in = "3102302031020310201";       # $c : 313210223020310120310201
my $a_in = "0122310132";       # $c : 13031222310132
my $c = & encode_q_hamming ($a_in, );
print 'dump ($a_in, $c, )   '; say dump ($a_in, $c, );

say '================================================';
say "Decoding algorithm of quaternary Hamming code";
# change this as necessary
# my $c = "310012302311010";              # $a : 01232311010
# my $c = "313210223020310120310201";   # $a : 3102302031020310201
# my $c = "313210223020310120310211";   # $a : 3102302031020310201
my $c = "13031222310132";   # $a : 0122310132
my $a = & decode_q_hamming ($c, );    
print 'dump ($c, $a, )   '; say dump ($c, $a, );

#mark z#
