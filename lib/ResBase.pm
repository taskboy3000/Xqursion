# A parent that contains common code
package ResBase;
use Modern::Perl '2012';
use parent ('DBIx::Class');
use UUID::Tiny (':std');

# These routines happen in all tables.
# All tables have an ID field that is a UUID
# All tables should have a created_at and updated_at

sub init {
    my ($class) = @_;
}

sub create_id {
    my ($self) = @_;
    $self->id(uuid_to_string(create_uuid(UUID_V4)));
}


1;
