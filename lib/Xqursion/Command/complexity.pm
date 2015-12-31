package Xqursion::Command::complexity;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Command';
use Mojo::Home;
use File::Find;
use Perl::Metrics::Simple::Analysis::File;
use Data::Dumper;
use List::Util ('sum');
has description => "For each perl module, describe the complexity of each";
has usage => "";

our @Problems;
our @Complexities;

sub run {
    my ($self) = shift;
    my $home = Mojo::Home->new;
    $home->detect;

    find(\&_report_complexity, $home->to_string . "/../lib");

    my $avg = (sum @Complexities)/scalar @Complexities;
            printf "%s\n", ("="x60);

    printf("AVERAGE COMPLEXITY: %0.2f\n\n", $avg);

    if (@Problems) {
        printf ("The following subroutines are particularly complex\n");
        for my $p (@Problems) {
            printf "%55s: ", _trim($p->{file}) . "[" . $p->{sub} . "]";
            printf "lines: %3d; complexity: %d\n", $p->{lines}, $p->{complexity};
        }
    }
}

sub _report_complexity {
    return unless $File::Find::name =~ /\.pm$/;

    my $analyzer = Perl::Metrics::Simple::Analysis::File->new(path => $File::Find::name);
    my $stats = $analyzer->all_counts;
    printf("\nFile: %s\n", _trim($File::Find::name));

    for my $key ('main_stats') {
        printf("  %-35s: lines: %3d; complexity: %d\n", 
               "main", 
               $stats->{$key}->{lines}, 
               $stats->{$key}->{mccabe_complexity});
               push @Complexities, $stats->{mccabe_complexity} if $stats->{mccabe_complexity};
    }

    for my $sub (@{$stats->{subs}}) {
        printf("  %-35s: lines: %3d; complexity: %s\n", 
               $sub->{name}, 
               $sub->{lines}, 
               _markup($sub->{mccabe_complexity}));
        push @Complexities, $sub->{mccabe_complexity} if $sub->{mccabe_complexity};

        if ($sub->{mccabe_complexity} > 10) {
            push @Problems, { file => $File::Find::name, 
                              sub => $sub->{name},
                              lines => $sub->{lines},
                              complexity => $sub->{mccabe_complexity}
                            };

        }
    }
    print "-------\n";
}

sub _markup {
    my ($num) = @_;
    if ($num > 10) {
        return "$num **";
    }
    return $num;
}

sub _trim {
    my ($path) = @_;
    return (split(m!/\.\./!, $path, 2))[1];
}

1;
