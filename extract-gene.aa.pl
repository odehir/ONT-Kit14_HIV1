#!/usr/bin/perl -w 

use strict;

use strict;
use Getopt::Std;                    
use Math::Complex;

my($region)    = "";
my($geno)      = "";
my($margin)    = 0;

my %list;
$list{ma} = "790-1185";
$list{ca} = "1186-1878";
$list{p2} = "1879-1920";
$list{nc} = "1921-2085";
$list{p1} = "2086-2133";
$list{p6} = "2134-2292";
$list{pr} = "2253-2549";
$list{rt} = "2550-4229";
$list{prrt} = "2253-4229";
$list{in} = "4230-5096";
$list{vif} = "5041-5619";
$list{vpr} = "5559-5850";
$list{tat} = "5831-6045,8379-8469";
$list{rev} = "5970-6045,8379-8653";
$list{vpu} = "6062-6310";
$list{gp120} = "6225-7757";
$list{gp41} = "7758-8795";
$list{nef} = "8797-9417";
$list{v1} = "6615-6692";
$list{v2} = "6693-6812";
$list{v3} = "7110-7217";
# true C2V5 6807-7757 
$list{c2c5} = "6810-7760";
$list{v4} = "7377-7478";
$list{v5} = "7602-7637";
$list{"ma-ca"} = "1171-1200";
$list{"ca-p2"} = "1864-1893";
$list{"p2-nc"} = "1906-1935";
$list{"nc-p1"} = "2071-2100";
$list{"p1-p6"} = "2119-2148";
$list{"tfp-pr"} = "2238-2267";
$list{"pr-rt"} = "2535-2564";
$list{"rt-rt"} = "3855-3884";
$list{"rt-in"} = "4215-4244";

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
  if(getopts('Ogm:r:i:o:',\%opts)){

    my($inname)    = $opts{'i'};      # input log file
    my($outname)   = $opts{'o'};      # output parameter file
      ($region)    = $opts{'r'};      # target region for analysis
      ($geno)      = $opts{'g'};      # force to examine genotypes at the indicated region
      ($margin)    = $opts{'m'} || 0; 
    my($overwrite) = $opts{'O'} || 0; # overwrite option

    if($inname && $region){
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

      if(! exists $list{$region}){
        &usage; 
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
  die   "usage: extract-gene.aa.pl [-O][-g][-m (margin)] -r (region) -i (alignment) -o (output)\n"
      . "usage: extract-gene.aa.pl [-O][-g][-m (margin)] -r (region) -i (alignment)  > (output)\n"
      . "usage: extract-gene.aa.pl [-O][-g][-m (margin)] -r (region)  < (alignment)  > (output)\n"
      . "                      -O:  overwrite output file\n"
      . "                      -g:  force genotype analysis\n"
      . "                      -m:  margin at 3'-end (nt; default: 0 nt)\n"
      . "region:\n"
      . " ma, ca, p2, nc, p1, p6, pr, rt, in, vif, vpr, tat, rev, vpu, gp120, gp41, nef,\n"
      . " v1, v2, v3, v4, v5,\n"
      . " ma-ca, ca-p2, p2-nc, nc-p1, p1-p6, tfp-pr, pr-rt, rt-rt, rt-in,\n";
} 


sub analyses
{
  my $n = -1;
  my $ref = "";
  my $name = "";

  my $del = 0;
  my @ref;
  my @ll;
  my $refaa = "";
  my @refaa;

  my @ra = split /,/, $list{$region};

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

          $ll[$i] = 0;

          for(my $k = 0; $k <= $#ra; $k++){
            my @ra2 = split /\-/, $ra[$k];
            if($ii >= ($ra2[0] - 789 - $del) && $ii <= ($ra2[1] - 789 - $del) ){
              $ll[$i] = 1;
              $last = $i;
            }
          }
        }
        for(my $k = $last + 1; $k <= ($last + $margin); $k++){
          $ll[$k] = 1;
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

      printf "%s,", $name;

      my $aa = "";
      if($region =~ /^v[12345]$/ || $region =~ /\-/){
        $aa = &na2aa_altH($seq2);
      }
      else{
        if($geno){
          $aa = &na2aa_altH($seq2);
        }else{
          $aa = &na2aa_alt($seq2);
        }
      }

      if($n == 0){ 
        $refaa = $aa; 
        @refaa = split /,/, $refaa;
      }

      my @aa = split /,/, $aa;

      for(my $j = 0; $j <= $#aa; $j++){
        printf "%s,", $aa[$j];
      }
      print "\n";
    }
  }
}


sub na2aa_alt
{
  my $s = shift;

  my @s = split //, $s;

  my $na = "";
  my $aa = "";
  my $c  = 0;
  if($region =~ /vpr/){
    my $flag = 0;

#    printf "%s%s%s%s\n", $s[212], $s[213], $s[214], $s[215];
    if($s[212] eq "-" && $flag == 0){ splice @s, 212, 1; $flag++; }
    if($s[213] eq "-" && $flag == 0){ splice @s, 213, 1; $flag++; }
    if($s[214] eq "-" && $flag == 0){ splice @s, 214, 1; $flag++; }
    if($s[215] eq "-" && $flag == 0){ splice @s, 215, 1; $flag++; }

    if($flag == 0){ $s[213] = uc ($s[213])};
  }

  for(my $i = 0; $i <= $#s; $i = $i + 1){

    if($s[$i] =~ /[A-Z]/){
      $na = $na . $s[$i];
    }else{
      $c++;
      $na = $na . $s[$i];

      if($c == 3){
        my $j2 = 0;
        for(my $j = 1; ($i+$j) <= $#s && $s[$i+$j] =~ /[A-Z]/; $j++){
          $na = $na . $s[$i+$j];
          $j2++;
        }
        $i = $i + $j2;

        my $a = &na2aa($na);
        $aa = $aa . $a . ",";  

        $c = 0;
        $na = "";
      }
    }
  }

  return ($aa);
}

sub na2aa_altH
{
  my $s = shift;
  $s =~ s/\-//g;
  $s = lc ($s);

  my @s = split //, $s;

  my $na = "";
  my $aa = "";
  my $c  = 0;
  for(my $i = 0; $i <= $#s; $i = $i + 1){
    $c++;
    $na = $na . $s[$i];

    if($c == 3){
      my $j2 = 0;
      for(my $j = 1; ($i+$j) <= $#s && $s[$i+$j] =~ /[A-Z]/; $j++){
        $na = $na . $s[$i+$j];
        $j2++;
      }
      $i = $i + $j2;

      my $a = &na2aa($na);
      $aa = $aa . $a;  

      $c = 0;
      $na = "";
    }
  }

  return ($aa);
}


sub na2aa
{
  my $s = shift;

  my @s = split //, lc ($s);

  my $aa = "";

  for(my $i = 0; $i <= $#s; $i = $i + 3){
    my $na = $s[$i];
    if(($i+1) <= $#s){ 
       $na = $na . $s[$i+1];
    }
    if(($i+2) <= $#s){ 
       $na = $na . $s[$i+2];
    }

    my $flag = 0;
    if($na eq "ttt"){ $aa = $aa . "F"; $flag++; }
    if($na eq "ttc"){ $aa = $aa . "F"; $flag++; }
    if($na eq "tta"){ $aa = $aa . "L"; $flag++; }
    if($na eq "ttg"){ $aa = $aa . "L"; $flag++; }

    if($na eq "tct"){ $aa = $aa . "S"; $flag++; }
    if($na eq "tcc"){ $aa = $aa . "S"; $flag++; }
    if($na eq "tca"){ $aa = $aa . "S"; $flag++; }
    if($na eq "tcg"){ $aa = $aa . "S"; $flag++; }

    if($na eq "tat"){ $aa = $aa . "Y"; $flag++; }
    if($na eq "tac"){ $aa = $aa . "Y"; $flag++; }
    if($na eq "taa"){ $aa = $aa . "*"; $flag++; }
    if($na eq "tag"){ $aa = $aa . "*"; $flag++; }

    if($na eq "tgt"){ $aa = $aa . "C"; $flag++; }
    if($na eq "tgc"){ $aa = $aa . "C"; $flag++; }
    if($na eq "tga"){ $aa = $aa . "*"; $flag++; }
    if($na eq "tgg"){ $aa = $aa . "W"; $flag++; }


    if($na eq "ctt"){ $aa = $aa . "L"; $flag++; }
    if($na eq "ctc"){ $aa = $aa . "L"; $flag++; }
    if($na eq "cta"){ $aa = $aa . "L"; $flag++; }
    if($na eq "ctg"){ $aa = $aa . "L"; $flag++; }

    if($na eq "cct"){ $aa = $aa . "P"; $flag++; }
    if($na eq "ccc"){ $aa = $aa . "P"; $flag++; }
    if($na eq "cca"){ $aa = $aa . "P"; $flag++; }
    if($na eq "ccg"){ $aa = $aa . "P"; $flag++; }

    if($na eq "cat"){ $aa = $aa . "H"; $flag++; }
    if($na eq "cac"){ $aa = $aa . "H"; $flag++; }
    if($na eq "caa"){ $aa = $aa . "Q"; $flag++; }
    if($na eq "cag"){ $aa = $aa . "Q"; $flag++; }

    if($na eq "cgt"){ $aa = $aa . "R"; $flag++; }
    if($na eq "cgc"){ $aa = $aa . "R"; $flag++; }
    if($na eq "cga"){ $aa = $aa . "R"; $flag++; }
    if($na eq "cgg"){ $aa = $aa . "R"; $flag++; }


    if($na eq "att"){ $aa = $aa . "I"; $flag++; }
    if($na eq "atc"){ $aa = $aa . "I"; $flag++; }
    if($na eq "ata"){ $aa = $aa . "I"; $flag++; }
    if($na eq "atg"){ $aa = $aa . "M"; $flag++; }

    if($na eq "act"){ $aa = $aa . "T"; $flag++; }
    if($na eq "acc"){ $aa = $aa . "T"; $flag++; }
    if($na eq "aca"){ $aa = $aa . "T"; $flag++; }
    if($na eq "acg"){ $aa = $aa . "T"; $flag++; }

    if($na eq "aat"){ $aa = $aa . "N"; $flag++; }
    if($na eq "aac"){ $aa = $aa . "N"; $flag++; }
    if($na eq "aaa"){ $aa = $aa . "K"; $flag++; }
    if($na eq "aag"){ $aa = $aa . "K"; $flag++; }

    if($na eq "agt"){ $aa = $aa . "S"; $flag++; }
    if($na eq "agc"){ $aa = $aa . "S"; $flag++; }
    if($na eq "aga"){ $aa = $aa . "R"; $flag++; }
    if($na eq "agg"){ $aa = $aa . "R"; $flag++; }


    if($na eq "gtt"){ $aa = $aa . "V"; $flag++; }
    if($na eq "gtc"){ $aa = $aa . "V"; $flag++; }
    if($na eq "gta"){ $aa = $aa . "V"; $flag++; }
    if($na eq "gtg"){ $aa = $aa . "V"; $flag++; }

    if($na eq "gct"){ $aa = $aa . "A"; $flag++; }
    if($na eq "gcc"){ $aa = $aa . "A"; $flag++; }
    if($na eq "gca"){ $aa = $aa . "A"; $flag++; }
    if($na eq "gcg"){ $aa = $aa . "A"; $flag++; }

    if($na eq "gat"){ $aa = $aa . "D"; $flag++; }
    if($na eq "gac"){ $aa = $aa . "D"; $flag++; }
    if($na eq "gaa"){ $aa = $aa . "E"; $flag++; }
    if($na eq "gag"){ $aa = $aa . "E"; $flag++; }

    if($na eq "ggt"){ $aa = $aa . "G"; $flag++; }
    if($na eq "ggc"){ $aa = $aa . "G"; $flag++; }
    if($na eq "gga"){ $aa = $aa . "G"; $flag++; }
    if($na eq "ggg"){ $aa = $aa . "G"; $flag++; }

    if($na eq "---"){ $aa = $aa . "-"; $flag++; }

    if($flag == 0){ $aa = $aa . "X"; }
  }

  return ($aa);
}

