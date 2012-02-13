#!/usr/bin/perl
########################################################################
# Novell::Bugzilla - Authenticate on 'bugzilla.novell.com'
# Copyright (C) 2010 Matthias Weckbecker,  <matthias@weckbecker.name>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################

use Test::More tests => 5;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

my $username = int rand $$;
my $password = int rand $$;

#3
eval { new Novell::Bugzilla( username => $username, 
                             password => $password ) }
  || pass("Wrong username || password");

#4
eval {
    new Novell::Bugzilla(
        username => "muster_mann",
        password => "mmustermann1"
    );
}
  && pass("Right username && password");

#5
eval { new Novell::Bugzilla( username => $username, ) };
like "$@",
  qr/'username', and 'password' are required arguments./,
  "Missing password.";

#6
eval { new Novell::Bugzilla( password => $password, ) };
like "$@",
  qr/'username', and 'password' are required arguments./,
  "Missing username.";

#7
#my $novell_bugzilla = eval {
#    new Novell::Bugzilla(
#        username => "muster_mann",
#        password => "mmustermann1",
#        timeout  => 360,
#    );
#};
#unlike "$@",
#  qr/'username', and 'password' are required arguments./,
#  "Login succeeded.";
#
#8
#isa_ok $novell_bugzilla, "WWW::Mechanize" 
#    || fail "No WWW::Mechanize object returned";
#
#9
#is( ( ref $novell_bugzilla ),
#    "WWW::Mechanize", "WWW::Mechanize returned upon sucessful login?" );
#
##10
#is( ( $novell_bugzilla->timeout ),
#    360, "Modify HTTP timeout through Novell::Bugzilla." );
