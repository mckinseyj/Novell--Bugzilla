#!/usr/bin/perl -w
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

use strict;
use warnings 'all';
use Novell::Bugzilla;
use Data::Dumper   qw/Dumper/;
use Compress::Zlib qw/memGunzip/;
use XML::Simple;

my $nb = new Novell::Bugzilla(
    username => "mweckbecker",
    password => "insertpassw",
);

my $bugzilla_url  = "https://bugzilla.novell.com/";
my $search_string =
    "$bugzilla_url"
  . "/buglist.cgi?status_whiteboard_type=casesubstring"
  . "&status_whiteboard=openL3"
  . "&bug_status=NEW%2CASSIGNED%2CREOPENED"
  . "&columnlist=bug_id";

my (@open_l3) =
  ( memGunzip $nb->get($search_string)->content ) =~
  m{(show_bug.cgi\?id=(?:\d+))}g;

sub cut { ( $_[0] =~ m{^(.{30})} ) }

foreach (@open_l3) {
    my $current_url     = "$bugzilla_url/$_&ctype=xml";
    my $current_content = $nb->get($current_url)->content;

    my $xml = XMLin( memGunzip $current_content );

    print $_ =~ m/=(\d+)/, "\t";
    print cut $xml->{bug}->{short_desc}, "\t";
    print $xml->{bug}->{bug_status},     "\t";
    print $xml->{bug}->{priority},       "\t";
    print $xml->{bug}->{bug_severity},   "\t";
}
