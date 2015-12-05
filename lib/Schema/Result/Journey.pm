# The primary container for steps
package Schema::Result::Journey;
use Modern::Perl '2012';
use parent ('ResBase');
use DateTime::Format::MySQL;

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core",);
__PACKAGE__->table("journeys");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "name" => { data_type => "varchar", is_nullable => 0, size=> 255},
   "user_id" => { data_type => "char", is_nullable => 0, size=>64},
   "start_at" => { data_type => "date", is_nullable => 1 },
   "end_at" => { data_type => "date", is_nullable => 1 },
    "export_url" => { data_type => "varchar", is_nullable => 1, size => 255 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("user" => "Schema::Result::User", "user_id");
__PACKAGE__->has_many("steps" => "Schema::Result::Step", "journey_id");
__PACKAGE__->inflate_column("created_at", {
                                           inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                           deflate => sub { shift->epoch }
                                          });

__PACKAGE__->inflate_column("updated_at", {
                                           inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                           deflate => sub { shift->epoch }
                                          });

__PACKAGE__->inflate_column("start_at", {
                                         inflate => sub { my $d = shift;
                                                          return unless $d;
                                                          DateTime::Format::MySQL->parse_date($d) },
                                         deflate => sub { 
                                                          my $s = DateTime::Format::MySQL->format_date(shift);
                                                          return $s;
                                                      },
                                        });

__PACKAGE__->inflate_column("end_at", {
                                         inflate => sub { my $d = shift;
                                                          return unless $d;
                                                          DateTime::Format::MySQL->parse_date($d) 
                                                        },
                                         deflate => sub { my $s = DateTime::Format::MySQL->format_date(shift);
                                                          return $s;
                                                      },
                                        });
__PACKAGE__->subclass;
__PACKAGE__->init();

sub form_date {
    my ($self, $field) = @_;
    if ($self->$field) {
        return $self->$field->ymd();
    }
}

sub export {
    my ($self) = @_;
    # Export this journey
    # record URL to the journey ZIP file
    return 1;
}

1;
