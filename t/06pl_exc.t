#!/usr/bin/perl -w

use Test;
BEGIN { plan tests => 8 }

use Inline Ruby;
use strict;
use Data::Dumper;

my @exc;
my $n = 0;
sub e (&) {
    my $iter = shift;
    eval { iter($iter)->callback($n) };
    return unless $@;
    my $x = $@;

    # Methods:
    ok($x->message =~ $exc[$n][0]);
    print Dumper $x->message;

    ok($x->type, $exc[$n][1]);
    print Dumper $x->type;

    ok("$x", $x->inspect . "\n");

    # Not tested:
    print Dumper $x->inspect;
    print "Stringified: $x\n";
    print Dumper $x->backtrace;

    $n++;
}

@exc  = (
    [qr{Illegal division by zero}, 'PerlException'],
    [qr{Missing right (?:curly or square )?bracket}, 'PerlException'],
);

# Division by zero
e {
    local $^W;
    my $a = 0;
    my $b = 1;
    return $b/$a;
};

e {
    local $^W;
    eval "sub bar {";
    die $@;
};

# Inline::Ruby must clear $@ if there is no exception:
iter(sub { 0 })->catch_perlerr;
ok($@, '');

# If a Perl exception occurs, but is trapped by a Ruby rescue block, we need
# to notice and clean it up. Yay!
iter(sub {
    local $^W;
    my $a = 0;
    my $b = 1;
    return $b/$a;
})->catch_perlerr;
print "But... $@\n";
ok($@, '');

__END__
__Ruby__

def callback(t)
    yield t
end

def catch_perlerr
  begin
    return yield "neil"
  rescue PerlException => e
    print "Note: ruby caught an exception. No biggie!\n"
    return nil
  end
end
