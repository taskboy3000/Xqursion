package Xqursion::Filters;
use Modern::Perl '2012';

sub require_authentication {
    my ($class, $c, $method) = @_;
    my $L = $c->app->log;

    $L->debug(__PACKAGE__ .": Beginning _require_authentication");

    # Check for cookie
    if (my $uid = $c->session("user_id")) {
        my $user = $c->app->db->resultset("User")->single({id => $uid});
        if ($user) {
            # has the cookie expired (8 hour lease)?
            if (time() - $c->session("started") > 60*60*8) {
                $L->debug(__PACKAGE__ . ": Session has expired");
                $c->flash(info => "Your session has expired");
                return $c->redirect_to("/");
            }
	    $L->debug(__PACKAGE__ . ": User authenticated");
            return 1;
        }
    }

    $L->debug(__PACKAGE__ . ": User is not authenticated");
    return $c->redirect_to("/");
}

1;
