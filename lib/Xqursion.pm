package Xqursion;
use strict;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugins;
use Schema;
use List::Util ('any');

has schema => sub {
    return Schema->connect($ENV{XQURSION_DBI_CONNECT} || "dbi:SQLite:share/schema.db",
                           $ENV{XQURSION_DBI_USERNAME},
                           $ENV{XQURSION_DBI_PASSWORD}
                          );
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->secrets([$ENV{XQURSION_SECRET} || '0987654321']);
    push @{$self->commands->namespaces}, 'Xqursion::Command';

    $self->app->sessions->cookie_name($self->app->moniker);
    $self->app->sessions->default_expiration(86400);

    $self->helper(db => sub { $self->app->schema });

    $self->plugin("Config");
    $self->plugin(mail => {
                           from => "xqursion\@taskboy.com",
                           encoding => "base64",
                           type => "text/html",
                           how => "sendmail",
                           howargs => [ '/usr/sbin/sendmail -t' ],
                          });
    
    # push @{$plugins->namespaces}, 'Xqursion::Plugin';
    $self->plugin('Xqursion::Plugin::Routes',);
    $self->plugin('Mojolicious::Plugin::BeforeFilter');    
    $self->add_filter_class('Xqursion::Filters');
    $self->make_routes();
}

1;
