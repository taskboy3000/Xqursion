package Xqursion::Command::export;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Command';
use FindBin;

has description => "This is merely for debugging the export process";
has usage => "USAGE: export [JOURNEY_ID]";

sub run {
    my ($self) = shift;
    my ($journey_id) = @_;
    unless ($journey_id) {
        warn("No journey given\n");
        return;
    }

    my $D = $self->app->db;
    my $journey;
    eval {
        $journey = $D->resultset("Journey")->find($journey_id);
    };

    warn("fatal: $@") if $@;

    unless ($journey) {
        warn("Journey '$journey_id' not found\n");
        return;
    }

    $journey->export($FindBin::Bin . "/../public/downloads");
    printf("Wrote public/downloads/%s\n", $journey->export_file);
    return 1;
}

1;
