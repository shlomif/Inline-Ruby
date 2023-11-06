#! /bin/bash

cd $REPO_DIR
perl --version
cpanm --version
cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
cpanm --verbose --notest --installdeps .
perl Makefile.PL
make
make test
exec bash
