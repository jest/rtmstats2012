use utf8;

use lib 'local/lib/perl5';
use common::sense;
use JSON;
use IO::All -utf8;
use DateTime::Format::Strptime;

my %qr = (
	en => qr/I completed ([0-9,]+) tasks with (Remember The Milk|\@rememberthemilk) in 2012/i,
	ja => qr/^2012年に(?:Remember The Milk|\@rememberthemilk)で(\d+)個/i,
);
my $strp = DateTime::Format::Strptime->new(pattern => '%a, %d %b %Y %H:%M:%S %z');
@ARGV = ('-') if !@ARGV;

for my $fname (@ARGV) {
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
			my $dt = $strp->parse_datetime($r->{created_at});
			say join ",", $r->{iso_language_code}, $r->{created_at}, $dt->ymd, $dt->hms, $dt->time_zone, $num; 
		} else {
#			say $txt;
		}
	}
}