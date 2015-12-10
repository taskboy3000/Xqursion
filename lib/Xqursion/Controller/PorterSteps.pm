package Xqursion::Controller::PorterSteps;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';
use URI;

sub show {
    my ($self) = @_;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $step = $D->resultset('Step')->find($self->param("id")); 

    unless ($step) {
        $L->warn("No step " . $self->param("id") . " found");
    }

    my $session_id = $self->cookie("session_id");
    if (length($session_id)) {
        $L->debug(sprintf("Using existing journey session '%s'", $session_id));
    } else {
        $session_id = ResBase->uuid;
        $L->debug("Creating new journey session '$session_id'");
        $self->cookie("session_id", $session_id);
    }

    return $self->redirect_to($self->process($step, $session_id));
}

sub process {
    my ($self, $step, $session_id) = @_;
    my $L = $self->app->log;
    my $D = $self->app->db;

    $L->debug("Processing journey step '@{[$step->id]}'");

    # Check depedencies with existing session
    unless ($step->check_dependencies($session_id)) {
        $L->debug("Journey step has unmet dependencies");
        return $step->error_url;
    }

    # Create new session as needed
    if ($step->create_new_session) {
        $session_id = ResBase->uuid;
        $L->debug("Creating new journey based on Step attribute: '$session_id'");
        $self->cookie("session_id", $session_id);
    }
    
    $L->debug(sprintf("Add a journey log for this step with session ID '%s'", $session_id));
    my $log = $D->resultset("JourneyLog")->new({session_id => $session_id, step_id => $step->id, journey_id => $step->journey_id});
    $log->create_id();
    $log->insert;

    my $uri = URI->new($step->url());
    $uri->query_form("xqursion_session_id" => $session_id);

    $L->debug("Return step's success URL: " . $uri->as_string);
    
    return $uri->as_string;
}

1;
