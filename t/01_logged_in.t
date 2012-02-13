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

use Test::More tests => 3;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

eval { $nb = Novell::Bugzilla->new(username => "foo",
                                   password => "bar"); };

like $@, qr/Could not login \(wrong username or password\?\)/; #3
