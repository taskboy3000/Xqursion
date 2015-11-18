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
    
    $self->secrets([$ENV{XQURSION_APP_SECRET} || '0987654321']);

    $self->app->sessions->cookie_name($self->app->moniker);
    $self->app->sessions->default_expiration(86400);
    
    $self->helper(db => sub { $self->app->schema });
    $self->plugin("Config");
    $self->plugin("authentication" => {
                                       autoload_user => 1,
                                       session_key => "user_id",
                                       load_user => sub {
                                           my ($app, $user_id) = @_;
                                           return $self->db->resultset("User")->find($user_id);
                                       },
                                       validate_user => sub {
                                           my ($c, $username, $password, $extradata) = @_;
                                           $c->app->log->warn("Looking up '$username'");
                                           my $user = $self->db->resultset("User")->single({username => $username});
                                         if ($user) {
                                             if ($user->is_password_valid($password)) {
                                                 return $user->id;
                                             }
                                         } else {
                                             $c->app->log->warn("Could not find user");  
                                         }                                         
                                           return;
                                       },
                                      });
    
    my $plugins = Mojolicious::Plugins->new;
    push @{$plugins->namespaces}, 'Xqursion::Plugin';
    $plugins->register_plugin('Xqursion::Plugin::Routes', $self); 
    $self->make_routes();
}

1;
