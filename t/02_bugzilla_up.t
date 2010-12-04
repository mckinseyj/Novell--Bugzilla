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

