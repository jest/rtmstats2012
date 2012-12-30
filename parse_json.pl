use utf8;

use common::sense;
use JSON;
use IO::All -utf8;

my %qr = (
	en => qr/I completed ([0-9,]+) tasks with (Remember The Milk|\@rememberthemilk) in 2012(\.?) #rtmstats/i,
	ja => qr/^2012年に\@rememberthemilkで(\d+)個/,
);
my $fname = $ARGV[0] // '-';
my $cnt < io $fname;
my $answer = from_json $cnt;

my $resu = $answer->{results};
for my $r (@$resu) {
	my $txt = $r->{text};
	my ($matched, $num);
	for my $lang (keys %qr) {
		next unless $txt =~ $qr{$lang};
		
		$matched = $lang;
		$num = $1;
		$num =~ s/,//g;
		last;
	}
	if ($matched) {
		;#say "$matched: $num";
	} else {
		say $txt;
	}
}
