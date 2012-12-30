use common::sense;

use lib 'local/lib/perl5';
use Net::Twitter;
use JSON;
use IO::All -utf8;

my ($ddir) = @ARGV;
my $json = JSON->new->ascii;

die "Usage: $0 data-dir" unless defined $ddir;
my $conf = $json->decode(io("$ddir/config.json")->all);
my $since = $conf->{max_id} // 0;

die "$ddir/$since doesn't exists, exiting" unless $since == 0 or -d "$ddir/$since";

my $nt = Net::Twitter->new(traits => [ qw[ API::REST API::Search RateLimit ] ]);
$nt->rate_limit_status({ authenticate => 0 });
printf "%d / %d calls remaining\n", $nt->rate_remaining, $nt->rate_limit;

my $maxid;
for (my $page = 1; ; ++$page) {
	my $r = $nt->search({ q => '#rtmstats', rpp => 100, page => $page, since_id => $since });
	last unless $r and @{$r->{results}};
	if (!$maxid) {
		$maxid = $r->{max_id_str};
		die "Can't find max_id in the results, exiting" unless $maxid;
		mkdir "$ddir/$maxid" or die "Error creating dir $ddir/$maxid: $!";
	}
	$json->encode($r) > io("$ddir/$maxid/_$page.json");
}

if (! defined $maxid) {
	say "No new tweets.";
} else {
	say "Tweet up to $maxid fetched.";
	$conf->{max_id} = $maxid;
	$json->encode($conf) > io "$ddir/config.json";
}
