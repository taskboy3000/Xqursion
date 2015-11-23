# A parent that contains common code
package Schema::ResultBase;
use Modern::Perl '2012';
use base ('DBIx::Class::Core');
use UUID::Tiny (':std');

# These routines happen in all tables.
# All tables have an ID field that is a UUID
# All tables should have a created_at and updated_at
if (__PACKAGE__ ne 'Schema::Result::Base') {
    __PACKAGE__->set_primary_key("id");
    __PACKAGE__->inflate_column("created_at", {
                                               inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                               deflate => sub { shift->epoch }
                                              });
    
    __PACKAGE__->inflate_column("updated_at", {
                                               inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                               deflate => sub { shift->epoch }
                                              });
}

sub create_id {
    my ($self) = @_;
    $self->id(uuid_to_string(create_uuid(UUID_V4)));
}

1;
