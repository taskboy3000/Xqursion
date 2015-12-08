use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

our $T = Test::Mojo->new('Xqursion');
our $SESSION_ID = "-1";

my $journey_id = create_journey();
ok($journey_id, "create journey");

ok(create_steps($journey_id), "create steps with dependencies");

# Create a journey log and and test the steps
clear_journey_log();

# Forbidden paths, 3, 6
my $path = 3;
ok(!travel($journey_id, $path), "Forbidden travel to step $path");

$path = 6;
ok(!travel($journey_id, $path), "Forbidden travel to step $path");

# Travel to 1
$path = 1;
ok(travel($journey_id, $path), "Travel to step $path");

# Travel to 5
$path = 5;
ok(!travel($journey_id, $path), "Forbidden travel to step $path");

# Travel to 3
$path = 3;
ok(travel($journey_id, $path), "Travel to step $path");

# Travel to 6
$path = 6;
ok(!travel($journey_id, $path), "Forbidden travel to step $path");

clear_journey_log();

# Travel to 4
$path = 4;
ok(travel($journey_id, $path), "Travel to step $path");

# Travel to 5 - OK now
$path = 5;
ok(travel($journey_id, $path), "Travel to step $path");


# Travel to 6 - OK now
$path = 6;
ok(travel($journey_id, $path), "Travel to step $path");


ok(delete_journey($journey_id), "delete journey");




done_testing();

sub create_journey {
    my $D = $T->app->db;
    my $journey = $D->resultset('Journey')->new({name => "TESTING", user_id => "-1"});
    $journey->create_id();
    $journey->insert;

    return $journey->id;
}

sub create_steps {
    my ($id) = @_;
    my $D = $T->app->db;
    my $journey = $D->resultset('Journey')->find($id);
    
    my @steps;
    for my $i (1..6) {
        my $step = $journey->new_related("steps", {title => "TEST Step $i", url => "http://example.com"})->create_id();
        $step->insert;
        push @steps, $step;
    }

    # Step 1 + Step 2 have no dependencies

    # Create OR dependency for Step 3
    my $dg1 = $steps[2]->new_related("dependency_group", {"title" => "TEST OR", "operation" => "OR"})->create_id();
    $dg1->insert();
    $steps[2]->dependency_group_id($dg1->id);
    $steps[2]->update;

    $dg1->new_related("dependencies", { step_id => $steps[0]->id })->create_id()->insert;
    $dg1->new_related("dependencies", { step_id => $steps[1]->id })->create_id()->insert;

    # Create NOT dependency for Step 5 (cannot have seen steps 1 or steps 3)
    my $dg2 = $steps[4]->new_related("dependency_group", {"title" => "TEST NOT", "operation" => "NOT"})->create_id();
    $dg2->insert();
    $steps[4]->dependency_group_id($dg2->id);
    $steps[4]->update;

    $dg2->new_related("dependencies", { step_id => $steps[0]->id })->create_id()->insert;
    $dg2->new_related("dependencies", { step_id => $steps[2]->id })->create_id()->insert;
    
    # Create AND dependency for Step 6 - Steps 4 and 5
    my $dg3 = $steps[5]->new_related("dependency_group", {"title" => "TEST AND", "operation" => "AND"})->create_id();
    $dg3->insert();
    $steps[5]->dependency_group_id($dg3->id);
    $steps[5]->update;

    $dg3->new_related("dependencies", { step_id => $steps[3]->id })->create_id()->insert;
    $dg3->new_related("dependencies", { step_id => $steps[4]->id })->create_id()->insert;

    return 1;
}


sub delete_journey {
    my ($id) = @_;
    my $D = $T->app->db;
    my $journey = $D->resultset('Journey')->find($id);
    $journey->delete;
}

# Attempt to "travel" to step number - 1
sub travel {
    my ($journey_id, $step_num) = @_;
    my $D = $T->app->db;
    my $journey = $D->resultset('Journey')->find($journey_id);

    my $step = ($journey->steps)[ $step_num - 1];
    unless ($step->check_dependencies($SESSION_ID)) {
        #warn("Travel forbidden to " . $step->title . "\n");
        return;
    }

    # OK to log this
    return $D->resultset("JourneyLog")->new({session_id => $SESSION_ID, step_id => $step->id})->create_id()->insert;
}

sub clear_journey_log {
    my $D = $T->app->db;
    for my $jl ($D->resultset('JourneyLog')->search({session_id => $SESSION_ID})) {
        $jl->delete;
    }
}
