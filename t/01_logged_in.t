use Test::More tests => 6;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

$v = Novell::Bugzilla::_logged_in( "self", "LoGin FaiLed" );
$w = Novell::Bugzilla::_logged_in( "self", "LoGiN fAiLeD." );
$x = Novell::Bugzilla::_logged_in( "self", "Login failed." );
$y = Novell::Bugzilla::_logged_in( "self", "foobar" );

is $v, 0, "Login should fail, 0.";       #4
is $x, 0, "Login should fail, 1.";       #5
is $w, 0, "Login should fail, 2.";       #6
is $y, 1, "Login should succeed.";       #7
