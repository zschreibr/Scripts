#!/usr/bin/perl

=head1 NAME
	fragment_finder.pl  

=head1 SYNOPSIS

    USAGE: fragment_finder.pl -i=btab.file

=head1 OPTIONS

B<--input, -i>
	btab file containing annotated ORFs

B<--help,-h>
 
=head1  DESCRIPTION
	Takes the ORFs in a btab file and counts the amount of times a similar function or fragment is shared across a contig.

=head1 HEADER
	Must be in MgOl header format.

=head1  INPUT
	Btab file of annotated ORFs.

=head1  OUTPUT
        Tab file displaying how many ORFs share a fragmented funciton. 
        
=head1  CONTACT
        Zach Schreiber @ zschreib[at]gmail[dot]com

=head1 EXAMPLE
         fragment_finder.pl -i=mgol_data.btab

=cut

use strict;
use warnings;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use List::Util qw(min max);

my %options = ();
my $results = GetOptions (\%options,
                                                  'input|i=s',
                                                  'help|h') || pod2usage();
#### display documentation
if( $options{'help'} ) {
  pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}

##user input error flags
die "Missing input btab file! -i\n" unless $options{input};
##end error


##user input
my $infile = $options{input};
my (@a,@id,$ctgid,$position,$orf_id,$function,$eval);
my %hoh = ();
##end input

#my $rHoH = \%hoh;


open(IN,"<$infile") || die "\n Cannot open the infile: $infile\n";

while (<IN>){
	chomp $_;
	if($_ =~ /^>/){
		my $line = $_;
		my @a = split(' ', $line);
		my $header = shift @a;
		
		my @head = split(/_/, $header);
		my $pos = pop @head;
		my $stop = pop @head;
		my $start = pop @head;
		my $ctgid = join("_", @head);
		
	 	$hoh{$ctgid}{'POSITION'}[$pos-1] = $pos;
		$hoh{$ctgid}{'START'}[$pos-1]    = $start;
		$hoh{$ctgid}{'STOP'}[$pos-1]     = $stop;
	}		 
	else{
		next;
	}
}

close(IN);

my $rHoH = \%hoh;


foreach my $ctgid (keys %$rHoH){
   for (my $i=0; $i < scalar(@{$rHoH->{$ctgid}->{'POSITION'}}); $i++){
        if(exists $rHoH->{$ctgid}->{'POSITION'}[$i]){
		for (my $j = $i+1; $j < scalar(@{$rHoH->{$ctgid}->{'POSITION'}}); $j++) {
                      if(exists $rHoH->{$ctgid}->{'POSITION'}[$j]){
					my $pos_a = $rHoH->{$ctgid}->{'POSITION'}[$i];
					my $pos_b = $rHoH->{$ctgid}->{'POSITION'}[$j];
                                        my $start_a  = $rHoH->{$ctgid}->{'START'}[$i];
			                my $stop_a   = $rHoH->{$ctgid}->{'STOP'}[$i];
                                        my $start_b  = $rHoH->{$ctgid}->{'START'}[$j];
                                        my $stop_b   = $rHoH->{$ctgid}->{'STOP'}[$j];	   
					my $prox = 100;
			#++ forward forward
			if($pos_b - $pos_a == 1){
                         if($stop_a - $start_a >= 0 && $stop_b - $start_b >= 0){
                                if(abs($stop_a - $start_b) > $prox){
                                        print  $ctgid . "_" . $start_a . "_" . $stop_a . "_" . $pos_a . "\t" . $ctgid . "_" . $start_b . "_" . $stop_b . "_" . $pos_b . "\n";
                                }
                         }
                        #-- reverse reverse
                         elsif($stop_a - $start_a <= 0 && $stop_b - $start_b <= 0){
                                if(abs($start_a - $stop_b) > $prox){
					print  $ctgid . "_" . $start_a . "_" . $stop_a . "_" . $pos_a . "\t" . $ctgid . "_" . $start_b . "_" . $stop_b . "_" . $pos_b . "\n";
                                }
                         }
                        #+- forward reverse
                         elsif($stop_a - $start_a >= 0 && $stop_b - $start_b <= 0){
                                if(abs($stop_a - $stop_b) > $prox){
					print  $ctgid . "_" . $start_a . "_" . $stop_a . "_" . $pos_a . "\t" . $ctgid . "_" . $start_b . "_" . $stop_b . "_" . $pos_b . "\n";
                                }
                         }
                        #-+ reverse forward
                         elsif($stop_a - $start_a <= 0 && $stop_b - $start_b >= 0){
                                if(abs($start_a - $start_b) > $prox){
					print  $ctgid . "_" . $start_a . "_" . $stop_a . "_" . $pos_a . "\t" . $ctgid . "_" . $start_b . "_" . $stop_b . "_" . $pos_b . "\n";
                                }
                         }
                         else{
                                last;
                            }
			 }
                      }                                                 
                   }
          }
      }
}

#print Dumper($rHoH);
exit 0;
