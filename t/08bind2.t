#!/usr/bin/perl -w

use strict;
use Test;
BEGIN { plan tests => 3 }

# Bind only to classes
use Inline RUBY => 'DATA', BIND_TYPE => [undef, 'functions'];
ok(1);

eval { my $obj = Smell->new };
ok($@);

ok(some_func(), "bound");

__END__
__RUBY__

def some_func
  return "bound"
end

class Smell
  def how_bad
    return "very"
  end
end
