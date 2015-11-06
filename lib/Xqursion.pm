package Xqursion;
use strict;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugins;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $plugins = Mojolicious::Plugins->new;
  push @{$plugins->namespaces}, 'Xqursion::Plugin';
  $plugins->register_plugin('Xqursion::Plugin::Routes', $self); 
  $self->make_routes();

}

1;
