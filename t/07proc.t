#!/usr/bin/perl -w

use Test;
BEGIN { plan tests => 3 }

use Inline Ruby;
use strict;

sub a {
    my ($i, $n) = @_;
    ok($i);
    print "Elapsed: $n\n";
}

invoke_wait(0.1, \&a, \&{"main::a"}, \&a);

__END__
__Ruby__

def invoke_wait(t, *procs)
  n = 0;
  i = 0;
  procs.each { |pr|
    i = i + 1
    n = n + sleep(t)
    p pr
    pr.call(i, n)
  }
end
