#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;


my $btab = $ARGV[0];
my $meta = $ARGV[1];
my @arry = [];
my %hash = ();
my $count = 0;

open(BTAB, $btab) or die "Could not find $btab\n";

while (<BTAB>){
	chomp $_;
	@arry = split (/\t/, $_);
	my $header = $arry[1];
	$hash{$header} = 1;
}

close BTAB;

#print Dumper \%hash;

open(META, $meta) or die "Could not find $meta\n";

my @new;

while (<META>){
	chomp $_;
	my $line = $_;

	my $mod;
	if($line =~ />/){
		@new = split (/ /, $line);
		my $header = $new[0];
		$mod = substr ($header, 1);
	
		foreach my $head (keys %hash){
			if($head eq $mod){
				print $line . "\n";
			}	
		}
		$count = 1;
	}
	
	elsif($count == 1){
		print $line . "\n";
		$count = 0;
	}
	
	else {
		next;
	}
	
}

close META;

exit 0;

