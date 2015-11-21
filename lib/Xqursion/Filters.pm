package Xqursion::Filters;
use Modern::Perl '2014';

sub require_authentication {
    my ($class, $c, $method) = @_;
    my $L = $c->app->log;

    $L->debug(__PACKAGE__ .": Beginning _require_authentication");

    # Check for cookie
    if (my $uid = $c->session("user_id")) {
        my $user = $c->app->db->resultset("User")->single({id => $uid});
        if ($user) {
	    $L->debug(__PACKAGE__ . ": User authenticated");
            return 1;
        }
    }

    $L->debug(__PACKAGE__ . ": User is not authenticated");
    $c->redirect_to("/");
    return 1;
}

1;
