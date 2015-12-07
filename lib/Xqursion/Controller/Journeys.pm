package Xqursion::Controller::Journeys;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';
use Mojo::Home;

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'New', 'create', 'edit', 'delete' ] };

sub index {
    my $self = shift;
    my $L = $self->app->log;
    my $journeys = [];

    my $current_user = $self->current_user;
    if ($current_user) {
        $journeys = [ $current_user->journeys() ];
    }

    $self->render(journeys => $journeys);
}

# Form to create new 
sub New {
    my $self = shift;
    my $journey = $self->app->db->resultset("Journey")->new({});
    $self->render(journey => $journey);
}

# Form handler for new
sub create {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;

    my $current_user = $self->current_user;

    if ($current_user && $self->param("name")) {
	my $journey = $current_user->new_related('journeys', {name => $self->param("name") });

	$journey->start_at($self->param("start_at")) if $self->param("start_at");
	$journey->end_at($self->param("end_at")) if $self->param("end_at");
	$journey->create_id;
	if ($journey->insert) {
	    $L->debug("Created journey: " . $journey->id);
	} else {
	    $L->warn("Failed to create journey");
	}
    } else {
	# XXX ERROR
    }
    return $self->redirect_to("journeys_index");
}

# Form to edit existing
sub edit {
    my $self = shift;
    my $journey = $self->app->db->resultset("Journey")->find($self->param("id"));
    $self->render(journey => $journey, c => $self);
}

# Form handler for edit
sub update {
    my $self = shift;

    my $journey = $self->app->db->resultset("Journey")->find($self->param("id"));
    for my $f ("name", "start_at", "end_at") {
        $journey->$f($self->param($f));
    }

    unless ($journey->update) {
        # redirect to form for validation errors
    }
    return $self->redirect_to("journeys_index");
}

sub delete {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $journey = $D->resultset("Journey")->find($self->param("id"));
    if ($journey) {
        if ($journey->user_id ne $current_user->id) {
            $L->warn("Permission error: user '@{$current_user->email}' tried to remove journey '@{$journey->id}'");
        } else {
            $journey->delete;
        }
    }
    
    $self->respond_to( json => { json => { success => 1 } });
}

sub export {
    my $self = shift;

    my $L = $self->app->log;
    my $D = $self->app->db;

    my $current_user = $self->current_user;
    my $journey = $D->resultset("Journey")->find($self->param("id"));
    return unless $journey;
    
    if ($journey->user_id ne $current_user->id) {
        return $self->render(text => "Not authorized", status => 403);
    }

    my $base_dir = "$ENV{XQURSION_HOME}/public/downloads/" . $journey->id;
    $L->debug("Export base directory: $base_dir");
    $journey->export(base_dir => $base_dir,
                     step_url_cb => sub { 
                         my $step = shift;
                         return $self->url_for("public_step_show", {id => $step->id});
                     });

    return $self->redirect_to($journey->export_zipfile);
}

1;
