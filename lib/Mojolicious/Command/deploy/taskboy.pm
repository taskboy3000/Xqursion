package Mojolicious::Command::deploy::taskboy;
# TOTALLY not a hacked version of deploy::heroku

use Mojo::Base 'Mojolicious::Command';

#use IO::All 'io';
#use File::Path 'make_path';
#use File::Slurp qw/ slurp write_file /;
#use File::Spec;
use Getopt::Long qw/ GetOptions :config no_auto_abbrev no_ignore_case /;
use IPC::Cmd 'can_run';
use Mojo::IOLoop;
use Mojo::UserAgent;
#use Mojolicious::Command::generate::heroku;
#use Mojolicious::Command::generate::makefile;
#use Net::Heroku;

our $VERSION = 0.01;


has ua => sub { Mojo::UserAgent->new->ioloop(Mojo::IOLoop->singleton) };
has description      => "Deploy Mojolicious app to Taskboy.\n";
has opt              => sub { {} };
#has tmpdir => sub { $ENV{MOJO_TMPDIR} || File::Spec->tmpdir };
#has credentials_file => sub {"$ENV{HOME}/.heroku/credentials"};
#has makefile         => 'Makefile.PL';
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
      $self->$stage() or last;
  }
}


sub update_taskboy_sandbox 
{
    my $self = shift;
    my $command = "ssh taskboy.com 'cd ~/sites/Xqursion && git pull && cpanm install'";
    print "$command\n";
    system($command);
}

sub restart_server 
{
    my $self = shift;
    my $command = "ssh taskboy.com 'cd ~/sites/Xqursion && hynotoad script/xqursion'";
    print "$command\n";
    system($command);
}

1;

