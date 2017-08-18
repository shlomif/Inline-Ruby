#!/usr/bin/perl

# Test, whether the code that evaluates the namespace of loaded classes
# and modules compiles (was broken in Inline::Ruby 0.08).

use strict;

use Test::More tests => 2;

use Inline 'Ruby';

ok 1 => 'compiles';

is(httpdate(), 'Fri, 18 Aug 2017 01:23:45 GMT', 'httpdate')

__END__
__Ruby__
require 'time'
require 'pp'

def httpdate
    t = Time.parse('2017-08-18 04:23:45 EEST')
    return t.httpdate
end
