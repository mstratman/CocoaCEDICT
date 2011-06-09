#!/usr/bin/perl -w

use strict;

while (<>) {
	my $line = $_;
	chomp $line;
	next if $line =~ /^#/;
	my ($trad, $simp, $rest) = split /\s+/, $line, 3;
	unless (defined $trad && length $trad
	        && defined $simp && length $simp
	        && defined $rest && length $rest)
	{
		warn "Split failed '$_'";
		next;
	}
	my @eng = ();
	my $py;
	if ($rest =~ m#\[([^\]]+)\]\s+/(.*)/\s*$#) {
		$py = $1;
		@eng = split /\//, $2;
	} else {
		warn "regexp not matched '$_'";
		next;
	}
	unless (scalar @eng) {
		warn "No eng '$_'";
		next;
	}
	#print "Trad:'$trad' Simp:'$simp' Pinyin:'$py'\n";
	#print "\tEnglish:'$_'\n" for @eng;

	## Ok, clearly there is extra space.. Be sure to take this into account
=cut
	for (@eng) {
		warn "Eng '$_' has extra space" if /^\s+/ || /\s+$/;
	}
	if ($py =~ /^\s+/ || $py =~ /\s+$/) {
		warn "PY '$py' has extra space";
	}
	if ($simp =~ /^\s+/ || $simp =~ /\s+$/) {
		warn "Simp '$simp' has extra space";
	}
	if ($trad =~ /^\s+/ || $trad =~ /\s+$/) {
		warn "Simp '$trad' has extra space";
	}
=cut
}

