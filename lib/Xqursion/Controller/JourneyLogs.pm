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
    my $rs = $D->resultset("JourneyLog")->search(undef,
                                               { where => [ { journey_id => $self->param("journey_id") } ],
                                                 order_by => [ {"-desc" => 'created_at'}, {"-asc" => 'session_id'} ],
                                                 rows => $self->param("rows") || 10,
                                                 page => $self->param("page") || 1,
                                               }
                                                  );


    $self->stash(journey => $journey);
    $self->stash(sessions => [ $rs->all ]);
    $self->stash(pager => $rs->pager);
    return $self->render();
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
