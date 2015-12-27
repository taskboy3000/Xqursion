# The primary container for steps
package Schema::Result::Journey;
use Modern::Perl '2012';
use parent ('ResBase');
use DateTime::Format::MySQL;
use Imager::QRCode;
use Cwd;
use URI::Escape;
use Archive::Zip (':ERROR_CODES', ':CONSTANTS');
use File::Temp ('tempdir');
use File::Copy;

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime",
                             "TimeStamp", "Core","Helper::Row::ToJSON");
__PACKAGE__->table("journeys");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "name" => { data_type => "varchar", is_nullable => 0, size=> 255},
   "user_id" => { data_type => "char", is_nullable => 0, size=>64},
   "start_at" => { data_type => "date", is_nullable => 1 },
   "end_at" => { data_type => "date", is_nullable => 1 },
   "export_file" => { data_type => "varchar", is_nullable => 1, size => 255 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("user" => "Schema::Result::User", "user_id");
__PACKAGE__->has_many("steps" => "Schema::Result::Step", "journey_id");
__PACKAGE__->has_many("logs" => "Schema::Result::JourneyLog", "journey_id");

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
    my ($self) = shift;
    my %args = ( "base_dir" => undef,
                 "step_url_cb" => undef,
                 @_
               );

    mkdir $args{base_dir};
    my $zip_dir = uri_escape($self->name);
    my $Z = Archive::Zip->new;
    $Z->addDirectory($zip_dir);

    my $old_dir = cwd();
    my $dir = tempdir(CLEANUP => 1);
    chdir $dir;

    my $cnt = 0;
    my @steps = $self->steps;
    for my $step (@steps) {	
	if (my $file = $step->generate_qrcode(base_dir => $args{base_dir},
					      step_url_cb => $args{step_url_cb})) {
	    # File::Copy::copy("$args{base_dir}/$file", "./$file");
	    warn("Created step image '$args{base_dir}/$file'\n");
	    $Z->addFile({filename => "$args{base_dir}/$file", zipName => "$zip_dir/$file" });
	    $cnt++;
	}
    }
    
    if ($cnt != @steps) {
        warn(sprintf("Generated different count of expected QR codes %d/%d\n", $cnt, scalar @steps));
    }

    my $zip_filename = uri_escape($self->id) . ".zip";

    unlink "$args{base_dir}/$zip_filename" if -e "$args{base_dir}/$zip_filename";
    unless ((my $rc = $Z->writeToFileNamed("$args{base_dir}/" . $zip_filename)) == AZ_OK) {
        die "Write error[$rc]: $!";
    }
    warn(sprintf("Zip: '$args{base_dir}/$zip_filename' %s\n", (-e "$args{base_dir}/$zip_filename" ? "exists" : "missing")));
    warn("$zip_filename\n");
    $self->export_file($zip_filename);
    $self->update;
    chdir $old_dir;
    return 1;
}

sub export_zipfile {
    my ($self) = @_;
    die "DON'T CALL THIS";
    return "/downloads/" . $self->id . "/" . uri_escape($self->export_file);
}

sub get_unique_session_count {
    my ($self) = @_;
    my %sessions;
    for my $l ($self->logs) {
        $sessions{$l->session_id} = 1;
    }
    return scalar keys %sessions;
}
1;
