use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Xqursion');
$t->get_ok('/')->status_is(200)->content_like(qr/xcursion/i);

done_testing();
