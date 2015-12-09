package Xqursion::Controller::JourneyLogs;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'show' ] };

sub index {
    my ($self) = shift;
    my $D = $self->app->db;
    my $L = $self->app->log;

    my $current_user = $self->current_user;
   
    my $journey = $D->resultset("Journey")->find($self->param("journey_id"));
    die "no journey" unless $journey;

    my @ids = map { $_->id } $journey->steps;
    $L->debug("OK");
    my @logs = $D->resultset("JourneyLog")->search({ journey_id => $self->param("journey_id"), },);
#                                                   [ {"-desc" => 'created_at'}, {"-asc" => 'session_id'} ]);

    $L->debug(sprintf("Found %d journey logs for journey %s", scalar @logs, $journey->name));

=pod
    my @sessions = ();
    my $current_session = {};

    for my $l (@logs) {
        if ($current_session->{session_id} ne $l->session_id) {
            push @sessions, $current_session if keys %$current_session;
            $current_session = { $l->session_id => [ $l ] };
        } else {
            push @{$current_session->{ $l->session_id }}, $l;
        }
    }
=cut

    return $self->render(sessions => \@logs);
}

sub show {
    my ($self) = shift;
    my $D = $self->app->db;
    my $L = $self->app->log;
    
    my $journey = $D->resultset("Journey")->find($self->param("journey_id"));
    my @journey_logs = $D->resultset('JourneyLog')->search( 
                                                            { session_id => $self->param("session_id") }, 
                                                           [ { "-desc" => 'created_at' } ]
                                                          );
    
    return $self->render(journey => $journey, logs => \@journey_logs);
}

1;
