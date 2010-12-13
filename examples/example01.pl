#!/usr/bin/perl -w

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

sub cut     { ($_[0]=~m{^(.{30})}) };

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
