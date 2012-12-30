use common::sense;

use lib 'local/lib/perl5';
use Net::Twitter;
use JSON;
use IO::All -utf8;

my ($ddir, $since) = @ARGV;
die "Usage: $0 data-dir since-id" unless defined $since;
die "$ddir/$since doesn't exists, exiting" unless -d "$ddir/$since";


my $nt = Net::Twitter->new(traits => [ 'API::Search' ]);
my $maxid;
for (my $page = 1; ; ++$page) {
	my $r = $nt->search({ q => '#rtmstats', rpp => 100, page => $page });
	last unless $r and @{$r->{results}};
	if (!$maxid) {
		$maxid = $r->{max_id_str};
		die "Can't find max_id in the results, exiting" unless $maxid;
		mkdir "$ddir/$maxid" or die "Error creating dir $ddir/$maxid: $!";
	}
	to_json($r) > io("$ddir/$maxid/_$page.json");
	last;
}
