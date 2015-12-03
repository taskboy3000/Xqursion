use utf8;
package Schema;
use strict;
use parent ('DBIx::Class::Schema');

our $VERSION = "11";

__PACKAGE__->load_namespaces();
# __PACKAGE__->load_components('Validation');

1;
