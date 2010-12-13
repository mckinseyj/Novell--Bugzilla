#!/usr/bin/perl
########################################################################
# Novell::Bugzilla - Authenticate on 'bugzilla.novell.com' via iChain
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

use Test::More tests => 8;
use Test::WWW::Mechanize;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

my $mech = Test::WWW::Mechanize->new
  || fail("Test::WWW::Mechanize");

#3
isa_ok( $mech, 'Test::WWW::Mechanize' );

#4
$mech->get_ok( 'https://bugzilla.novell.com/index.cgi',
    'Welcome to Novell\'s Bugzilla' );

#5
$mech->get_ok('https://bugzilla.novell.com/index.cgi?GoAheadAndLogIn=1&');

$mech->get('https://bugzilla.novell.com/index.cgi?GoAheadAndLogIn=1&');

#6
$mech->follow_link_ok( { n => 1 }, 'Go after first link' );

#7
$mech->get_ok(
    'https://bugzilla.novell.com/ICSLogin/?%22
     https://bugzilla.novell.com/ichainlogin.cgi
     ?target=index.cgi?GoAheadAndLogIn%3D1%22'
);

#8
$mech->submit_form_ok( { form_number => 1 }, 'Submit Form' );

