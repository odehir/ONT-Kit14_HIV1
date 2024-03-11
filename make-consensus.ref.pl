#!/usr/bin/perl -w 

use strict;

use strict;
use Getopt::Std;                    
use Math::Complex;

&main;


# * main routine *
sub main
{
 # Unix style get arguments for filenames
  &fileargs;
  
  &analyses;

}


# * subroutine fileargs *
sub fileargs 
{
  my(%opts);
  if(getopts('Oi:o:',\%opts)){

    my($inname)    = $opts{'i'};      # input log file
    my($outname)   = $opts{'o'};      # output parameter file
    my($overwrite) = $opts{'O'} || 0; # overwrite option

    if($inname){
      #case of GZIP
      if($inname =~ /\.gz$/){
        open STDIN, "gunzip -c $inname |" || die "Can't open $inname!!\n";
      }
      #case of COMPRESS
      elsif($inname =~ /\.Z$/){
        open STDIN, "zcat $inname |" || die "Can't open $inname!!\n";
      }
      else{
        open STDIN, "$inname" || die "Can't open $inname!!\n";
      }

      if($outname){
        if($overwrite){
          open STDOUT, ">$outname" || die "Can't open $outname!!\n";
        }else{
          if(!(-e $outname)){
            open STDOUT, ">$outname" || die "Can't open $outname!!\n";
          }else{
            die "File $outname already exists.\n";
          }
        }
      }
    }else{
      if($outname){ 
        &usage; }
    }
  }else{ 
    &usage; }
}

# * subroutine usage *
sub usage
{
  die   "usage: make-consensus.ref.pl [-O] -i (alignment) -o (output)\n"
      . "usage: make-consensus.ref.pl [-O] -i (alignment)  > (output)\n"
      . "usage: make-consensus.ref.pl [-O]  < (alignment)  > (output)\n"
      . "                      -O:  overwrite output file\n"
} 


sub analyses
{
  my $n = -1;
  my $ref = "";
  my $name = "";

  my $del = 0;
  my @ref;
  my @ll;
  my $refna = "";
  my @refna;
  my $conna;

  while(<>){
    s/\A\s+//;
    s/\s+\Z//;
    my $line = $_;

    if(/^\>([\W\w]+)$/){
      $n++;
      $name = $1;
    }else{
      my $seq = $line;
      if($n == 0){
        $ref = $line;
        @ref = split //, $ref;
        my $ii = 0;
        my $last = 0;
        for(my $i = 0; $i <= $#ref; $i++){
          if($ref[$i] =~ /[atgc]/){ $ii++; }

          $ll[$i] = 1;
          $last = $i;
        }
      }
   
      my @ss = split //, $seq;
      my $seq2 = "";
      my $ins = 0;
      for(my $j = 0; $j <= $#ss; $j++){
        if($ss[$j] =~ /[A-Z]/){ $ins++; }

        if($ll[$j-$ins] > 0){
          if($ref[$j-$ins] ne "-"){
#          if($ss[$j] ne "-"){
            $seq2 = $seq2 . $ss[$j]
          }
        }
      }

      my $na = "";
      $na = &na2na_alt($seq2);

      if($n == 0){ 
        $refna = $na; 
        @refna = split /,/, $refna;
      }else{

        my @na = split /,/, $na;
        for(my $j = 0; $j <= $#na; $j++){
          if(exists $conna->{$j}->{$na[$j]}){
            $conna->{$j}->{$na[$j]} = $conna->{$j}->{$na[$j]} + 1;
          }else{
            $conna->{$j}->{$na[$j]} = 1;
          }
        }
      }
    }
  }

  printf ">REF\n";
  foreach my $j (sort {$main::a <=> $main::b} keys %{$conna}){
    my $l = 0;
    foreach my $k (sort {$conna->{$j}->{$main::b} <=> $conna->{$j}->{$main::a}} keys %{$conna->{$j}}){
      if($l == 0){
        if($k =~ /^[atgc]$/){ printf "%s", $k; }
        else{ printf "%s", $refna[$j]; }
        $l++;
      }
    }
  }
  print "\n";
}


sub na2na_alt
{
  my $s = shift;

  my @s = split //, $s;

  my $na = "";
  my $na2 = "";
  my $c  = 0;

  for(my $i = 0; $i <= $#s; $i = $i + 1){

    if($s[$i] =~ /[A-Z]/){
      $na = $na . $s[$i];
    }else{
      $c++;
      $na = $na . $s[$i];

      if($c == 1){
        my $j2 = 0;
        for(my $j = 1; ($i+$j) <= $#s && $s[$i+$j] =~ /[A-Z]/; $j++){
          $na = $na . $s[$i+$j];
          $j2++;
        }
        $i = $i + $j2;

        my $a = $na;
        $na2 = $na2 . $a . ",";  

        $c = 0;
        $na = "";
      }
    }
  }

  return ($na2);
}



