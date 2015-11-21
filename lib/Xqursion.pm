package Xqursion;
use strict;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugins;
use Schema;
use List::Util ('any');

has schema => sub {
    return Schema->connect("dbi:SQLite:" . ($ENV{XQURSION_DB} || "share/schema.db"));
};

# This method will run once at server start
sub startup {
    my $self = shift;
    
    $self->secrets([$ENV{XQURSION_APP_SECRET} || '0987654321']);

    $self->app->sessions->cookie_name($self->app->moniker);
    $self->app->sessions->default_expiration(86400);
    
    $self->helper(db => sub { $self->app->schema });

    $self->plugin("Config");
    # push @{$plugins->namespaces}, 'Xqursion::Plugin';
    $self->plugin('Xqursion::Plugin::Routes',);
    $self->plugin('Mojolicious::Plugin::Filter');
    $self->add_filter_class('Xqursion::Filters');
    $self->make_routes();
}

1;
