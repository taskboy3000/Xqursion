package Xqursion::Command::deploy::taskboy;
# TOTALLY not a hacked version of deploy::heroku
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Command';

use Getopt::Long qw/ GetOptions :config no_auto_abbrev no_ignore_case /;
use IPC::Cmd 'can_run';
use Mojo::IOLoop;
use Mojo::UserAgent;

our $VERSION = 0.02;

has ua => sub { Mojo::UserAgent->new->ioloop(Mojo::IOLoop->singleton) };
has opt              => sub { {} };
has description      => "Deploy Mojolicious app to Taskboy.\n";
has usage            => <<"EOF";

usage: $0 deploy taskboy [OPTIONS]

  # Updates taskboy with this app
  $0 deploy taskboy

EOF

sub opt_spec 
{
  my $self = shift;
  my $opt  = {};

  return $opt if GetOptions();
}

sub validate 
{
  my $self = shift;
  my $opt  = shift;

  my @errors =
    map $_ . ' command not found' =>
    grep !can_run($_) => qw/ssh/;

  return @errors;
}

sub run 
{
  my $self = shift;

  # App home dir
  $self->ua->server->app($self->app);
  my $home_dir = $self->ua->server->app->home->to_string;

  # Command-line Options
  my $opt = $self->opt_spec(@_);

  # Validate
  my @errors = $self->validate($opt);
  die "\n" . join("\n" => @errors) . "\n" . $self->usage if @errors;

  # do a git pull on TB in the correct directory
  my @stages = (
      "update_taskboy_sandbox",
      "restart_server",
      );
  
  for my $stage (@stages)
  {
      $self->$stage();
  }
}

sub update_taskboy_sandbox 
{
    my $self = shift;
    my $command = "ssh taskboy.com 'cd ~/sites/Xqursion && source env.sh && git pull && carton && dbic-migration upgrade'";
    print "$command\n";
    system($command);
}

sub restart_server 
{
    my $self = shift;
    my $command = "ssh taskboy.com 'cd ~/sites/Xqursion && source env.sh && hynotoad script/xqursion'";
    print "$command\n";
    system($command);
}

1;

