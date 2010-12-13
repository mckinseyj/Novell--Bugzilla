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

use Test::More tests => 6;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

$v = Novell::Bugzilla::_logged_in( "self", "LoGin FaiLed"  );
$w = Novell::Bugzilla::_logged_in( "self", "LoGiN fAiLeD." );
$x = Novell::Bugzilla::_logged_in( "self", "Login failed." );
$y = Novell::Bugzilla::_logged_in( "self", "foobar"        );

is $v, 0, "Login should fail, 0.";       #4
is $x, 0, "Login should fail, 1.";       #5
is $w, 0, "Login should fail, 2.";       #6
is $y, 1, "Login should succeed.";       #7
