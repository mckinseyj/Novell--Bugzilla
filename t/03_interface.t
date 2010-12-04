use Test::More tests => 3;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

my $username = int rand 1000;
my $password = int rand 1000;

eval { new Novell::Bugzilla( username => $username, password => $password ) }
  || pass("Wrong username or password!?");

