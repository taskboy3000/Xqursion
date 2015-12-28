package Xqursion::Controller::Dashboards;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index' ] };

sub index {
    my ($self) = shift;
    my @tips = (
	"Journeys are collections of steps.  Each step has a URL to your content",
	"Each step is represented by a QR Code",
	"Consumers of your journey are called travelers",
	"Travelers are not required to have accounts on Xqursion",
	"Whenever a traveler successfully scans a step's QR code, that fact is recorded in the journey log", 
	"If a traveler scans a step and is rejected based on the access control, that step is not recorded for that user in the journey log",
	"Steps contain two URLs. The main URL is shown unless the traveler gets rejected by an access control",
	"Insert your QRCodes into a Google doc for easy PDF creation",
	"Use a journey's start_at date to prevent travelers from getting to your content before you are ready",
	"The 'End current travel session' step option is a great way to begin a journey",
        "Access controls on steps can introduce game-like mechanics to your journeys",
	"Access controls look at the steps a traveler has already visited in the current travel session",
	"Step error URLs are shown to a user who fails the requirements of the step's access control",
	"The 'Require All' access control operation requires the traveler to have visited the steps listed",
	"The 'Require One' access control operation means that a traveler must have successfully visited at least one of the listed steps",
	"The 'Forbid These' access control operation enforces an exclusive choice of steps that a user must choose from",
	);
    my $totd = @tips[ rand @tips ];
    $self->stash(tip_of_the_day => $totd);
    $self->stash(current_user => $self->current_user);
    $self->render();

}

1;
