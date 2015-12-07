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

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core",);
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
    my ($self, $base_dir) = @_;

    unless ($base_dir && -d $base_dir) {
        die("Pass in a valid base directory. Cannot find '$base_dir'. Currently in " . cwd());
    }

    my $old_dir = cwd();
    my $dir = tempdir(CLEANUP => 1);
    chdir $dir;
    my $Z = Archive::Zip->new;
    my $zip_dir = uri_escape($self->name);
    $Z->addDirectory($zip_dir);

    my $qrcode = Imager::QRCode->new(
				     size          => 4,
				     margin        => 3,
				     version       => 1,
				     level         => 'M',
				     casesensitive => 1,
				     lightcolor    => Imager::Color->new(255, 255, 255),
				     darkcolor     => Imager::Color->new(0, 0, 0),
				    );

    my $cnt = 0;
    my @steps = $self->steps;
    for my $step (@steps) {
      # FIXME
      my $img = $qrcode->plot(qq[http://qr.taskboy.com/l/?id=] . $step->id);
      my $name = $step->title;
      my $file = uri_escape($name) . ".png";
      
      $img->write(file => $file);
      
      if ($img->{ERRSTR}) {
	warn("$img->{ERRSTR}");
      } else {
        $Z->addFile({filename => $file, zipName => "$zip_dir/$file" });
	$cnt++;
      }
    }

    if ($cnt != @steps) {
        warn(sprintf("Generated different count of expected QR codes %d/%d\n", $cnt, scalar @steps));
    }

    my $zip_filename = uri_escape($self->name) . ".zip";

    unlink "$base_dir/$zip_filename" if -e "$base_dir/$zip_filename";

    unless ((my $rc = $Z->writeToFileNamed("$base_dir/" . $zip_filename)) == AZ_OK) {
        die "Write error[$rc]: $!";
    }

    $self->export_file($zip_filename);
    $self->update;

    chdir $old_dir;

    return 1;
}

1;
