use Test::More tests => 3;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

can_ok 'Novell::Bugzilla', qw/_logged_in
  _get_form_by_field
  _login
  new/;                                  #3

