package Xqursion::Controller::PorterSteps;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

sub show {
    my ($self) = @_;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $step = $D->resultset('Step')->find($self->param("id")); 

    unless ($step) {
        $L->warn("No step " . $self->param("id") . " found");
    }
    
    unless ($self->cookie("session_id")) {
        $L->debug("Creating new journey session");
        $self->cookie("session_id", $current_user->uuid);
    }

    return $self->redirect_to($self->process($step));
}

sub process {
    my ($self, $step) = @_;
    my $L = $self->app->log;
    my $D = $self->app->db;

    $L->debug("Processing journey step '${[$step->id]}'");

    unless ($step->check_dependencies($self->cookie("session_id"))) {
        $L->debug("Journey step has unmet dependencies");
        return $step->error_url;
    }

    $L->debug("Add a journey log for this step");
    my $log = $D->resultset("JourneyLog")->new({session_id => $self->cookie("session_id"), step_id => $step->id});
    $log->create_id();
    $log->insert;

    $L->debug("Return step's success URL: " . $step->url);
    return $step->url;
}

1;
