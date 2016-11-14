#!/usr/bin/perl -w
use strict;


################## VARIABLES ####################

my $infile = $ARGV[0];
my %HoA; ## {contig_id}[orf_id] = cluster_id
         ## {IXX_sngl100000065498}[1] = 0
my %Results;
my $cluster_id;

#################################################


################## MAIN #########################

## Parses incomming headers for mmi library
## 0       142aa, >IXX_sngl100000065498_1_430_1... at 72.54% 
## IXX_sngl100000065498

open(IN,"<$infile") || die "\n Cannot open the infile: $infile\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$cluster_id = $_;
	$cluster_id =~ s/>Cluster //;
    }
    else {
	my $whole_orf_id = $_;
	$whole_orf_id =~ s/.*>//;
	$whole_orf_id =~ s/\.\.\..*//;
	my @a = split(/_/, $whole_orf_id);
	my $orf_id = pop(@a);
	pop(@a); pop(@a);
	my $contig_id = join("_", @a);
	$HoA{$contig_id}[$orf_id-1] = $cluster_id;
    }
}
close(IN);

foreach my $ctgid (keys %HoA) {
    # foreach my $orf (@{$HoA{$ctgid}}) {
    # 	print $ctgid . "\t" . $orf . "\n";
    # }
    for (my $i=0; $i < scalar(@{$HoA{$ctgid}}); $i++) {
	if (exists $HoA{$ctgid}[$i]) {
	    # print $ctgid . "\t" . $i . "\t" . $HoA{$ctgid}[$i] . "\n";
	    for (my $j = $i+1; $j < scalar(@{$HoA{$ctgid}}); $j++) {
		my $a = $HoA{$ctgid}[$i];
		my $b = $HoA{$ctgid}[$j];
		$Results{$a}{$b}++;
	    }
	}
	else {
	    die "\n Error: we are missing the $i th orf for $ctgid\n";
	}
    }
}

foreach my $a (keys %Results) {
    foreach my $b (keys %{$Results{$a}}) {
	my $checker = $Results{$a}{$b};
	if($checker >= 8){
	print $a . "\t" . $b . "\t" . $Results{$a}{$b} . "\n";
      }
   }
}

exit 0;


################### END #########################




################# SUBROUTINES ###################




#################### END ########################
