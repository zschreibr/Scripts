#!/usr/bin/perl -w

=head1 NAME

	cdhit_scrambler.pl - Takes all ORFs belonging to a contig and rearranges the position over a specified amount 
			     of iterations from a cd-hit output .clstr file. 

=head1 SYNOPSIS

USAGE: execute_pipeline.pl --input_file=/path/to/input_file.clstr --iterations= number --help

=head1 OPTIONS

=head1  INPUT

    Input cd-hit cluster file

=head1  OUTPUT

	A directory containing 'n' amounts of randomized ORFs along a specific contig across a cd-hit cluster file. 

=head1  CONTACT

	Zach Schreiber zschreib@udel.edu

=cut

use strict;
use warnings;
use Data::Dumper;
use Cwd;
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);


my %options = ();

my $results = GetOptions (\%options,
			  'input_file|i=s',
			  'iterations|n=i',
                          'help|h') || pod2usage();

if( $options{'help'} ){
    pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}

##user input error flags
die "Missing input cd-hit cluster file! -i\n" unless $options{input_file};
die "Missing iterations ! -n\n" unless $options{iterations};
##

## VARS 
my $cluster = $options{input_file};
my $it = $options{iterations};

my ($cluster_id, $whole_orf_id, @a, $contig_id, $start_id, $stop_id, @orfs, $orf_id, $header, $randomize);

my %HoH = ();
my %new = ();
my $rHoH = \%HoH;

my $dir = getcwd;
my $file = "simulations";
##

mkdir $file;
die "Cannot create directory $dir : $!\n" unless -d $dir;

## Simulation
for (my $i=1; $i <= $it; $i++) { 

my $filename = 'cluster_randomize' . "_" . "$i";

open(my $fh, '>', $dir . "/" . $file . "/" . $filename) or die;

## LOAD DATA INTO HASH

open(IN,"<$cluster") || die "\n Cannot open the infile: $cluster\n";

while(<IN>) {
    chomp $_;
    if ($_ =~ m/^>/) {
        $cluster_id = $_;
    }

    else {
        $whole_orf_id = $_;
        $whole_orf_id =~ s/.*>//;
        $whole_orf_id =~ s/\.\.\..*//;

        @a = split(/_/, $whole_orf_id);    #full header => ABC_ctg12352124134_23_430_1
        $orf_id = pop(@a);                 #orf position on the contig => 1
        $stop_id = pop(@a);                #stopping position of orf on contig => 430
        $start_id = pop(@a);               #starting position of orf on contig => 23
	$contig_id = join("_", @a);

        $HoH { $contig_id }{ 'POSITION' }[$orf_id-1] = $orf_id;
        $HoH { $contig_id }{ 'CLUSTER' }[$orf_id-1]  = $cluster_id;
	$HoH { $contig_id }{ 'START' }[$orf_id-1]    = $start_id;
	$HoH { $contig_id }{ 'STOP' }[$orf_id-1]     = $stop_id;
    }
}

close(IN);

##

my @rand;

## RANDOMIZE ORF POSITIONS THAT LIE ON SAME CONTIG ID

foreach my $key (keys %$rHoH){

	for (my $i=0; $i < scalar(@{$rHoH->{$key}->{'POSITION'}}); $i++){
		push @rand, $rHoH->{$key}->{'POSITION'}[$i]; ## puts all possible positions for that key into an array
	}

	for (my $i=0; $i < scalar(@{$rHoH->{$key}->{'POSITION'}}); $i++){
			$header = $key . "_" . $rHoH->{$key}->{'START'}[$i] . "_" . $rHoH->{$key}->{'STOP'}[$i]; ## uniq header
                        $randomize =  splice @rand, rand @rand, 1; #pull a random position from the key then discard the value so there are no duplicates
                        $new{$header} = $randomize; #new random position gets pushed into hash with full header
        }	
}

##

#print Dumper(\%new);

## RECREATE cluster file with new randomized ORFs

open(FILE,"<$cluster") || die "\n Cannot open the infile: $cluster\n";

my $count = 0;

while(<FILE>) {
    chomp $_;
    if ($_ =~ m/^>/) {
        print $fh $_ . "\n";
	$count = 0;
    }

    else {
        $whole_orf_id = $_;
        $whole_orf_id =~ s/.*>//;
        $whole_orf_id =~ s/\.\.\..*//;

        @a = split(/_/, $whole_orf_id);    #full header => ABC_ctg12352124134_23_430_1
        $orf_id = pop(@a);                 #orf position on the contig => 1

        $contig_id = join("_", @a);

	if(exists $new{$contig_id} ){
		print $fh $count . "\t" . "1aa," . "\t" . ">" . $contig_id . "_" . $new{$contig_id} . "..." . "\n";
		$count ++;
	}
    }
}

close(FILE);

}


## END SIMULATIONS

##

