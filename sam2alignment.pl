#!/usr/bin/perl -w

use strict;

my $dataM;
my $dataI;
my %lenI;
my %name;
my %omit;
my $id = 0;
my %list;
my %list2;
my $ll;


my $file = shift;
my $ref  = shift;

if($ref =~ /.gz$/){
  open REF, "gunzip -cd $ref |";
}else{
  open REF, "$ref";
}
while(<REF>){
  s/^\s+//;
  s/\s+$//;
  my $line = $_;

  if(/^\>/){ printf ">REF\n"; }
  else{
    my $s = lc ($line);
    $ll = length($s);
    printf "%s", $s;
  }
}
close REF;
printf "\n";

if($file =~ /.gz$/){
  open FILE, "gunzip -cd $file |";
}else{
  open FILE, "$file";
}
while(<FILE>){
  s/^\s+//;
  s/\s+$//;
  my $line = $_;

  if(/^\@/){ 
#    my @tmp = split /\s+/, $line;
#    for(my $i = 0; $i <= $#tmp; $i++){
#      if($tmp[$i] =~ /^LN\:(\d+)$/){
#        $ll = $1;
#      }
#    }
    next;
  }


  my @tmp = split /\t+/, $line;

  if($tmp[9] =~ /[Nn]/){ next; }
  if($tmp[9] =~ / /){ next; }

  my $start = $tmp[3];

  my $cigar = $tmp[5];
  my $cigar1 = $tmp[5];
     $cigar1 =~ s/[A-Z]/ /g;
     $cigar1 =~ s/\s+$//;
  my $cigar2 = $tmp[5];
     $cigar2 =~ s/\d+/ /g;
     $cigar2 =~ s/^\s+//;
  my @cigar1 = split /\s+/, $cigar1;
  my @cigar2 = split /\s+/, $cigar2;
  
  $id++;
  if(!exists $list2{$tmp[0]}){ $list2{$tmp[0]} = 1; }
  else{ next; }

  my $n = $start - 1;
  my $n2 = 0;
  my $seq = $tmp[9];
     $seq = lc ($seq);
  my @seq = split //, $seq;
  my $tmp = "";
  for(my $i = 0; $i <= $#cigar2; $i++){
    if($cigar2[$i] eq "S"){
#      $n  = $n  + $cigar1[$i];
      $n2 = $n2 + $cigar1[$i];
    }
    if($cigar2[$i] eq "H"){
      ;
    }
    if($cigar2[$i] eq "M"){
      for(my $j = 0; $j < $cigar1[$i]; $j++){
        if($n >= (1 - 1) && $n <= ($ll - 1)){
          $tmp = $tmp . $seq[$n2];
        }
        $n++;
        $n2++;
      }
    }
    if($cigar2[$i] eq "I"){
      for(my $j = 0; $j < $cigar1[$i]; $j++){
        if($n >= (1) && $n <= $ll){
          $tmp = $tmp . uc ($seq[$n2]);
        }
        $n2++;
      }
    }
    if($cigar2[$i] eq "D"){
      for(my $j = 0; $j < $cigar1[$i]; $j++){
        if($n >= (1 - 1) && $n <= ($ll - 1)){
          if($seq[$n2]){
            $tmp = $tmp . "-";
          }
        }
        $n++;
      }
    }
  }

  if($tmp =~ /[Nn]/){ next; }

  $name{$id} = $tmp[0];
  printf ">%s\n", $tmp[0];
  for(my $i = 1; $i < $start; $i++){
    if($i >= 1 && $i <= $ll){
      printf "-";
    }
  }
  
  printf "%s", $tmp;

  for(my $i = $n; $i <= ($ll - 1); $i++){
    if($i >= 1 && $i <= ($ll - 1)){
      printf "-";
    }
  }
  print "\n";
}
close FILE;
