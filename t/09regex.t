#!/usr/bin/perl -w

use strict;
use Test;
BEGIN { plan tests => 3 }

use Inline Ruby => 'DATA', REGEX => qr/^pl_/;
ok(1);

my $a = eval { pl_entry_point() };
ok($a, 0);

my $b = eval { entry_point() };
ok($@);

__END__
__Ruby__

def pl_entry_point
  return 0
end

def other_func
  return 0
end
