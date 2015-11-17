package Xqursion;
use strict;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugins;
use Schema;

has schema => sub {
    return Schema->connect("dbi:SQLite:" . ($ENV{XQURSION_DB} || "share/schema.db"));
};

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->helper(db => sub { $self->app->schema });
  $self->plugin("Config");

  my $plugins = Mojolicious::Plugins->new;
  push @{$plugins->namespaces}, 'Xqursion::Plugin';
  $plugins->register_plugin('Xqursion::Plugin::Routes', $self); 
  $self->make_routes();

}

1;
