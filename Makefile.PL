use Data::Dumper;
use Config;
use ExtUtils::MakeMaker;
use Getopt::Long;

GetOptions(
	   'gdb:s' => \$gdb,
	   debug => \$debug,
	   help => \$help,
	  );

usage() if $help;

#============================================================================
# What ruby are we going to run?
#============================================================================
my @rubies;
for $p (split /$Config{path_sep}/, $ENV{PATH}) {
    $p =~ s/^~/$ENV{HOME}/;
    $p .= "/ruby";
    push @rubies, { path => $p } if -f $p && -x $p;
}

unless (@rubies) {
    print "Could not find the ruby interpreter on your PATH. Stopping...\n";
    exit 1;
}

my $num = 1;
print "Found ${\(scalar @rubies)} ruby executables on your PATH.\n";
print $num++ . ". " . $_->{path} . "\n" for @rubies;

my $sel = prompt("Use which?", (scalar @rubies ? '1' : ()));
$sel = $rubies[$sel-1] if $sel =~ /^\d+$/;
$sel = { path => $sel } unless ref $sel eq 'HASH';

print "Using $sel->{path}\n";

#============================================================================
# Interrogate the ruby interpreter for the required flags
#============================================================================
interrogate($sel);

# Fix up the libpath and libruby
substr($sel->{incpath}, 0, 0) = "-I";
substr($sel->{libpath}, 0, 0) = "-L";
$sel->{libruby} =~ s/lib(.*)(?:\.\Q$Config{dlext}\E|\Q$Config{_a}\E).*/-l$1/;

my @flags;
push @flags, debug_flag() if defined $gdb;
push @flags, '-DI_RB_DEBUG' if $debug;
push @flags, 'none (perl Makefile.PL --help for details)' unless @flags;
print <<END;
Using these settings:
   Extra Libs:  $sel->{syslibs}
   Ruby Lib:    $sel->{libpath} $sel->{libruby}
   Includes:    $sel->{incpath}
   Extra Flags: @flags
END

#============================================================================
# Finalize, and write the makefile
#============================================================================
$defs = join ' ', qw(-UEXPOSE_PERL -DCREATE_RUBY -UCREATE_PERL),
	$debug ? "-DI_RB_DEBUG" : ();

WriteMakefile(
    $defs ? (DEFINE => $defs) : (),
    defined $gdb ? (OPTIMIZE => debug_flag()) : (),
    INC			=> $sel->{incpath},
    LIBS		=> (join ' ', @$sel{qw(libpath libruby syslibs)}),
    OBJECT 		=> 'Ruby.o rb2pl.o',
    NAME		=> 'Inline::Ruby',
    VERSION_FROM	=> 'Ruby.pm', # finds $VERSION
    PREREQ_PM		=> {
			    Inline => 0.42,
			   }, # e.g., Module::Name => 1.1
    realclean		=> { FILES => '_Inline' },
);

#============================================================================
# Asks the ruby interpreter what libraries we need, where its include 
# directories are, etc.
#============================================================================
sub interrogate {
    my $ref = shift;
    $ref->{syslibs} = get_config_var($ref, "LIBS");
    $ref->{libruby} = get_config_var($ref, "LIBRUBY");

    # Ruby 1.6.4 supports archdir, which is what we need. But 1.6.3 (the 
    # earliest version I have) doesn't, so we should build it ourselves.
    $ref->{incpath} = $ref->{libpath} = get_config_var($ref, "archdir");
    if ($ref->{incpath} eq 'nil') {
	$ref->{incpath} = $ref->{libpath} = 
	  join '/', (get_config_var($ref, "libdir"),
		     "ruby",
		     (join '.', get_config_var($ref, "MAJOR"),
				get_config_var($ref, "MINOR")),
		     get_config_var($ref, "arch"));
    }
    return if -f "$ref->{libpath}/$ref->{libruby}";

    # If ruby has been compiled for libruby.so, it continues to think
    # libruby.so is living in .../lib/ruby/1.6/$arch/; but the Makefile
    # installs it into .../lib/. Correct for that here:
    my @other_tries = (
	get_config_var($ref, "libdir"),
	qw(/usr/lib /lib),
    );
    for my $p (@other_tries) {
	$ref->{libpath} = $p and return if -f "$p/$ref->{libruby}";
    }
}

sub get_config_var {
    my $ref = shift;
    my $key = shift;
    my $exe = $ref->{path};
    my $val = `$exe -e "require 'rbconfig'; include Config; puts CONFIG['$key']"`;
    chomp $val;
    return $val;
}

sub debug_flag {
    return $gdb if $gdb;
    $Config{osname} eq 'MSWin32'        ? return '-Zi' : return '-g';
}

sub usage {
    print <<'END';
Options:
    -gdb:   Turn on compiler's debugging flag (use my guess).
    -gdb=x  Pass your own debugging flag, not mine.
    -debug: Turn on many diagnostic print statements inside Inline::Ruby.
            This option is useful for tracing the execution path when
            debugging.
    -help:  This output.
END
# ' stupid vim
    exit 0;
}
