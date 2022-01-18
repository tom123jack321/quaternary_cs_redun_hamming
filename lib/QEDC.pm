#!/usr/bin/env perl
##!/Volumes/820g/Mac_app/homebrew/bin/perl
##!/usr/bin/perl
# naming convention: 1. A: array; 2. H: hash; 3. R: reference; 4. Sr: subroutine; 5. crt: correct; 6. err: error; 7. RAR: references to array of references; 8. 
#mark a#
package QEDC;   # quaternary error detection and correction

use v5.21.1;
use utf8;
use strict;
use warnings;
# use YAML;   # say Dump
use POSIX qw/ ceil floor /;
use Data::Dump qw/ dump /;  #dump @AoA;
use Exporter qw/ import /;
# use Storable qw/ store retrieve /;
use List::Util qw/ sum any max first /;
#mark b#

our @ISA = qw/ Exporter /;
our @EXPORT_OK = qw / 
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
#mark c#

my $eps = 1.e-9;

# # test subroutines of quaternary hamming code
# my $len_a_max = 11;
# my $a_in = "";
# # my $a_in = "0123" . "2311" . "010";   # $c : 320012302311010
# for my $l (1 .. $len_a_max){
#   map { $a_in .= int(rand(4)) } 1 .. $l;
#   print '$a_in   '; say $a_in;
#   my $c = & encode_q_hamming ($a_in, );
#   my $len_c = length $c;
#   for my $i (0 .. ($len_c-1)){
#     for my $j (0 .. 3){
#       print '($i, $j, )  '; map {print "|$_"; } ($i, $j, ); say '|';
#       my $c = & encode_q_hamming ($a_in, );
#       print '$c   '; say $c;
#       my $len_c = length $c;
#       substr $c, $i, 1, $j;
#       print '$c   '; say $c;
#       my $a_corrected = & decode_q_hamming ($c, );
#       print '$a_in   '; say $a_in;
#       print '$a_corrected   '; say $a_corrected;
#       die unless $a_corrected eq $a_in;
#     }
#   }
# }

#mark z#

# my $a_in = "0123";
# print '$a_in   '; say $a_in;
# my ($cs, $a_out, ) = & encode_q_cs_v1 ($a_in, );
# print '($cs, $a_out, )  '; map {print "|$_"; } ($cs, $a_out, ); say '|';
sub encode_q_cs_v1 (){
  # $a_in : the input number sequence
  my ($a_in, ) = @_;
  my @a = split //, $a_in;
  my $cs = sum @a;
  $cs %= 4;
  return ($cs, $cs . $a_in);
}

# my $a_R = [ 0 .. 3 ];
# print 'dump $a_R   '; say dump $a_R;
# my ($cs, $c_R, ) = & encode_q_cs_v2 ($a_R, );
# print '$cs   '; say $cs;
# print 'dump $c_R   '; say dump $c_R;
sub encode_q_cs_v2 (){
  # $a_R : reference to an array of numbers
  my ($a_R, ) = @_;
  my $c_R = [ @{$a_R} ];
  my $cs = sum @{$c_R};
  $cs %= 4;
  unshift @{$c_R}, $cs;
  return ($cs, $c_R, );
}

# # my $a_in = "30123";
# my $a_in = "20123";
# my $is_crt = & is_intact_q_cs_v1 ($a_in, );
# print '$is_crt   '; say $is_crt;
# # check whether a number sequence is intact
sub is_intact_q_cs_v1 (){
  # $a_in : the input number sequence, of which the first number is quaternary checksum
  my ($a_in, ) = @_;
  my $cs_old = substr $a_in, 0, 1;
  my $a_most = substr $a_in, 1;
  my @most_A = split //, $a_most;
  my $cs_now = sum @most_A;
  $cs_now %= 4;
  if ( abs($cs_old-$cs_now) < $eps ){
    return 1;
  } else {
    return 0;
  }
}

# # my $a_in = "30123";
# my $a_in = "20123";
# my $a_R = [ split //, $a_in ];
# my $is_crt = & is_intact_q_cs_v2 ($a_R, );
# print '$is_crt   '; say $is_crt;
sub is_intact_q_cs_v2 (){
  # $a_R : a reference to an array of numbers, of which the first element is quaternary checksum
  # The input $a_R is modified
  my ($a_R, ) = @_;
  my $cs_old = shift @{$a_R};
  my $cs_now = sum @{$a_R};
  $cs_now %= 4;
  if ( abs($cs_old-$cs_now) < $eps ){
    return 1;
  } else {
    return 0;
  }
}

# my $a_in = "30123";
# my $q = 2;
# my $a_crt = & decode_q_cs_v1 ($a_in, $q, );
# print 'dump ($a_in, $q, $a_crt, )   '; say dump ($a_in, $q, $a_crt, );
sub decode_q_cs_v1 (){
  # $a_in : the input number sequence, of which the first number is quaternary checksum and the ($q+1)th number is erroneous (counting from 1), $q > 1
  my ($a_in, $q, ) = @_;
  my @a = split //, $a_in;
  my $cs = shift @a;
  splice @a, $q-1, 1;
  my $s = sum @a;
  my $aq = ($cs - $s);
  $aq %= 4;
  splice @a, $q-1, 0, $aq;
  return join '', @a;
}

# my $a_in = "30123";
# my $q = 2;
# my $a_R = [ split //, $a_in ];
# my $a_crt = & decode_q_cs_v2 ($a_R, $q, );
# print 'dump ($a_in, $q, $a_crt, )   '; say dump ($a_in, $q, $a_crt, );
sub decode_q_cs_v2 (){
  # $a_R : a reference to an array of numbers, of which the first number is quaternary checksum and the ($q+1)th number is erroneous (counting from 1), $q > 1
  my ($a_R, $q, ) = @_;
  my @a = @{$a_R};
  my $cs = shift @a;
  splice @a, $q-1, 1;
  my $s = sum @a;
  my $aq = ($cs - $s);
  $aq %= 4;
  splice @a, $q-1, 0, $aq;
  return join '', @a;
}

# my $a_R = ["01223", "123", "033201", ];
# print 'dump $a_R   '; say dump $a_R;
# my ($redun, $c_R, ) = & encode_q_redun_v1 ($a_R, );
# print '$redun   '; say $redun;
# print 'dump $c_R   '; say dump $c_R;
# encode quaternary redundancy
sub encode_q_redun_v1 (){
  # $a_R : reference to an array of number sequences
  my ($a_R, ) = @_;
  my @a = @{$a_R};
  my @len_A = ();
  map { push @len_A, length $_; } @a;
  my $len_max = max @len_A;
  my $redun = "";
  for my $j (0 .. ($len_max-1)){
    my $redun_j = 0;
    for my $i (0 .. $#a ){
      next if $j+1 > $len_A[$i];
      my $i_j = substr $a[$i], $j, 1;
      $redun_j += $i_j;
    }
    $redun_j %= 4;
    $redun .= $redun_j;
  }
  push @a, $redun;
  return ($redun, \@a, );
}

# my $a_R = ["01223", "123", "033201", ];
# my $a_RAR = & ref_to_RAR ($a_R, );
# print 'dump $a_RAR   '; say dump $a_RAR;
# my ($redun_R, $c_RAR, ) = & encode_q_redun_v2 ($a_RAR, );
# print 'dump $redun_R   '; say dump $redun_R;
# print 'dump $c_RAR   '; say dump $c_RAR;
sub encode_q_redun_v2 (){
  # $a_RAR : reference to an array of "references to arrays of numbers"
  my ($a_RAR, ) = @_;
  my @a = @{$a_RAR};
  my @len_A = ();
  map { push @len_A, scalar @{$_}; } @a;
  my $len_max = max @len_A;
  my @redun = ();
  for my $j (0 .. ($len_max-1)){
    my $redun_j = 0;
    for my $i (0 .. $#a ){
      next if $j+1 > $len_A[$i];
      my $i_j = $a[$i]->[$j];
      $redun_j += $i_j;
    }
    # print '$redun_j   '; say $redun_j;
    $redun_j %= 4;
    push @redun, $redun_j;
  }
  push @a, \@redun;
  return (\@redun, \@a, );
}

# # my $a_R = ["01223", "123", "033201", "120031"];   # intact
# # my $a_R = ["01223", "023", "033201", "120031"]; # erroneous
# my $a_R = ["01223", "12", "033201", "120031"]; # erroneous
# my $is_crt = & is_intact_q_redun_v1 ($a_R, );
# print '$is_crt   '; say $is_crt;
# # check whether the array is intact (correct)
sub is_intact_q_redun_v1 (){
  # $a_R : reference to an array of number sequences
  my ($a_R, ) = @_;
  my @a = @{$a_R};
  my ($r_1, $r_2, );
  $r_1 = pop @a;
  ($r_2, ) = & encode_q_redun_v1 (\@a, );
  if ( $r_1 eq $r_2 ){
    return 1;
  } else {
    return 0;
  }
}

# # my $a_R = ["01223", "123", "033201", "120031"];   # intact
# # my $a_R = ["01223", "023", "033201", "120031"]; # erroneous
# my $a_R = ["01223", "12", "033201", "120031"]; # erroneous
# print 'dump $a_R   '; say dump $a_R;
# my $c_R = & decode_q_redun_v1 ($a_R, 2, 3 );
# print 'dump $c_R   '; say dump $c_R;
sub decode_q_redun_v1 (){
  # $a_R : reference to an array of number sequences, of which the ($q)th sequence (counting from 1) is erroneous and the last sequence is redundancy (intact). The ($q)th sequence has $nq numbers
  my ($a_R, $q, $nq, ) = @_;
  my @a = @{$a_R};
  my $redun = pop @a;
  splice @a, $q-1, 1;
  my ($r_2, );
  ($r_2, ) = & encode_q_redun_v1 (\@a, );
  my $aq = "";
  map { $aq .= (substr($redun, $_, 1) - substr($r_2, $_, 1))%4 } 0 .. ($nq-1);
  splice @a, $q-1, 0, $aq;
  return \@a;
}

# # my $a_R = ["01223", "123", "033201", "120031"];   # intact
# my $a_R = ["01223", "023", "033201", "120031"]; # erroneous
# # my $a_R = ["01223", "12", "033201", "120031"]; # erroneous
# my $a_RAR = & ref_to_RAR ( $a_R, );
# print 'dump $a_RAR   '; say dump $a_RAR;
# my $q = 2;
# my $nq = 3;
# print '($q, $nq, )  '; map {print "|$_"; } ($q, $nq, ); say '|';
# my $c_RAR = & decode_q_redun_v2 ($a_RAR, $q, $nq, );
# print 'dump $c_RAR   '; say dump $c_RAR;
sub decode_q_redun_v2 (){
  # $a_RAR : reference to an array of (references to arrays of numbers, of which the ($q)th array, counting from 1, is erroneous and the last sequence is redundancy, being intact). The ($q)th array has $nq numbers
  my ($a_RAR, $q, $nq, ) = @_;
  my @a = @{$a_RAR};
  my $re_1_R = pop @a;
  splice @a, $q-1, 1;
  my ($re_2_R, ) = & encode_q_redun_v2 (\@a, );
  my ($aq, );
  map { push @{$aq}, ($re_1_R->[$_] - $re_2_R->[$_])%4 } 0 .. ($nq-1);
  splice @a, $q-1, 0, $aq;
  return \@a;
}

# my $a_R = ["01223", "123", "033201"];   # intact
# print 'dump $a_R   '; say dump $a_R;
# my $c_R = & encode_comb_q_cs_redun ($a_R, );
# print 'dump $c_R   '; say dump $c_R;
# encode the combination of quaternary checksum and redundancy
sub encode_comb_q_cs_redun (){
  # $a_R : reference to an array of number sequences
  my ($a_R, ) = @_;
  # $a_RAR : reference to an array of (references to arrays of numbers)
  my ($a_RAR, $re_R, $cs, );
  $a_RAR = & ref_to_RAR ( $a_R, );
  ($re_R, $a_RAR, ) = & encode_q_redun_v2 ($a_RAR, ); 
  # map { & encode_q_cs_v2 ($_, ) } @{$a_RAR};
  map { ($cs, $_, ) = & encode_q_cs_v2 ($_, ) } @{$a_RAR};
  my ($c_R, );
  map { push @{$c_R}, join "", @{$_} } @{$a_RAR};
  return $c_R;
}

# # my $c_R = ["001223", "2123", "1033201", "3120031"];   # intact
# my $c_R = ["001", "2123", "1033201", "3120031"];   # erroneous
# my $out_R = & decode_comb_q_cs_redun ($c_R, 5, );
# print 'dump $out_R   '; say dump $out_R;
# decode the combination of quaternary checksum and redundancy
sub decode_comb_q_cs_redun (){
  # $a_R : reference to an array of number sequences, of which the last sequence is redundancy and at most one data sequence is erroneous. The first number of each sequence is checksum
  # $nq shoud be a priori
  my ($a_R, $nq, ) = @_;
  my $n_seq = scalar @{$a_R};
  my ($a_RAR, ) = & ref_to_RAR ($a_R, );
  my @is_crt_A = ();
  map { push @is_crt_A, & is_intact_q_cs_v2 ($_, ) } @{$a_RAR};
  my $n_crt = sum @is_crt_A;
  # the index of the wrong sequence
  my $q = first { $is_crt_A[$_] < 1 } 0 .. ($n_seq-1);     
  # the length of ($q)th sequence. Note that this value should be fed or known
  $nq = scalar @{$a_RAR->[$q]} unless defined $nq;        
  if ( abs($n_seq-$n_crt-1) < $eps and $q < $n_seq-1 ){
    $a_RAR = & decode_q_redun_v2 ($a_RAR, $q+1, $nq, );
  } else {
    pop @{$a_RAR};
  }
  my $out_R;
  map { push @{$out_R}, join('', @{$_}) } @{$a_RAR};
  return $out_R;
}


# my $a_in = "0123" . "2311" . "010";   # $c : 320012302311010
# my $c = & encode_q_hamming ($a_in, );
# print 'dump ($a_in, $c, )   '; say dump ($a_in, $c, );
sub encode_q_hamming (){
  # $a_in : the input number sequence
  my ($a_in, ) = @_;
  my @a = split //, $a_in;
  my $n = scalar @a;
  # $m : the length of parity checksum series
  my $m = 0;
  ++$m until 2**$m > $n + $m;
  # print '$m   '; say $m;
  my (@c, );
  # initialise @c
  for my $i (1 .. $m){
    for my $j ( (2**($i-1)+1) .. (2**$i-1) ){
      $c[$j-1] = $a[$j-$i-1] if $j <= $n+$m; 
    }
  }
  # print '@a  '; map {print "|$_"; } @a; say '|';
  # print 'dump @c   '; say dump @c;
  for my $i (1 .. $m){
    my $p = 0;          # $p : checksum
    my $k_max = 0;
    ++$k_max until 2**($i-1) *(2*$k_max+1) > $n + $m;
    --$k_max;
    for my $k (0 .. $k_max ){
      my $j_sta = 2**($i-1) * (2*$k+1);
      my $j_end = 2**($i-1) * (2*$k+2) -1;
      for my $j ( $j_sta .. $j_end ){
        $p += $c[$j-1] if $j > 2**($i-1) and $j <= $n+$m;
      }
    }
    $p %= 4;
    $c[2**($i-1)-1] = $p;
  }
  return join '', @c;
}

# my $c = "310012302311010";
# my $a = & decode_q_hamming ($c, );
# print 'dump ($c, $a, )   '; say dump ($c, $a, );
sub decode_q_hamming (){
  # $c_in : codeword. 
  # The codeword might differ from the correct one in one number at most
  my ($c_in, ) = @_;
  my @c = split //, $c_in;
  my $len_c = scalar @c;
  my $m = ceil( log($len_c)/log(2) );
  my $n = $len_c - $m;
  my $v = 0;
  # attention: to use indices later, minus 1
  my @set_index_p = 1 .. $m;
  my ($set_index_each_p_R, @w, );
  for my $i (@set_index_p){
    my $p = 0;          # $p : checksum
    my $k_max = 0;
    # ++$k_max until 2**($i-1) *(2*$k_max+1) > $n + $m;
    ++$k_max until 2**($i-1) *(2*$k_max+1) > $len_c;
    --$k_max;
    for my $k (0 .. $k_max ){
      my $j_sta = 2**($i-1) * (2*$k+1);
      my $j_end = 2**($i-1) * (2*$k+2) -1;
      for my $j ( $j_sta .. $j_end ){
        if ( $j > 2**($i-1) and $j <= $n+$m ){
          $p += $c[$j-1];
          push @{ $set_index_each_p_R->[$i-1] }, $j;
        }
      }
    }
    $p %= 4;
    $w[$i-1] = $p;
    if ( abs($c[2**($i-1)-1] - $p)<$eps ){ 
      $v += 2**($i-1) * 0;
    } else { 
      $v += 2**($i-1) * 1;
    }
  }
  # print 'dump $set_index_each_p_R     '; say dump $set_index_each_p_R  ;
  # print '$v   '; say $v;
  # if no errors or only one of the checksum digits is wrong
  if ( abs($v)<$eps or any { abs($v- 2**($_-1))<$eps } @set_index_p ){
    # $a_crt : corrected a
    my $a_crt = & extract_data_qh (\@c, $m);
    return $a_crt;
  }
  # if one element of the data sequence is wrong
  for my $i (@set_index_p){
    if ( any { abs($v-$_)<$eps } @{$set_index_each_p_R->[$i-1]} ){
      my $p_i = $c[2**($i-1)-1];
      my $c_v = $c[$v-1];         # the wrong element
      $c_v = ($p_i - ($w[$i-1]-$c_v) )%4;     # the correct one
      $c[$v-1] = $c_v;
      my $a_crt = & extract_data_qh (\@c, $m);
      return $a_crt;
    }
  }
}

#mark d#

# my $c_R = [ split //, $c ];
# my $len_c = length $c;
# my $m = ceil( log($len_c)/log(2) );
# my $a_crt = & extract_data_qh ($c_R, $m);
# print '@$a_crt  '; map {print "|$_"; } @$a_crt; say '|';
sub extract_data_qh (){
  # $c_R : reference to the array of codeword
  # $m : the number of checksum digits
  my ($c_R, $m, ) = @_; 
  my @c = @{$c_R};
  for my $i (1 .. $m){
    undef $c[2**($i-1)-1];
  }
  my @a;
  for (@c){
    push @a, $_ if defined $_ 
  }
  return join '', @a;
}

# my $a_R = [ ("0123", "3211", "00223", ) ];
# my ($a_RAR, ) = & ref_to_RAR ($a_R, );
# print 'dump $a_RAR   '; say dump $a_RAR;
sub ref_to_RAR (){
  # convert from one to another
  # $a_R : reference to an array of number sequences
  # $a_RAR : reference to an array of (references to arrays of numbers)
  my ($a_R, ) = @_;
  my ($a_RAR, );
  map { push @{$a_RAR}, [ split //, $_ ] } @{$a_R};
  return ($a_RAR, );
}

1;  # return true
