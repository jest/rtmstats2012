use common::sense;

use JSON;
use IO::All -utf8;

my $fname = $ARGV[0] // '-';
my $cnt < io $fname;
my $resu = decode_json $cnt;