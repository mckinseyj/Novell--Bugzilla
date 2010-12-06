use Test::More tests => 5;

BEGIN { use_ok('Novell::Bugzilla') };    #1
require_ok('Novell::Bugzilla');          #2

my $username = int rand $$;
my $password = int rand $$;

#3
eval { new Novell::Bugzilla( username => $username, password => $password ) }
  || pass("Wrong username or password!?");

#4
eval { new Novell::Bugzilla( username => $username, ) };
like "$@",
  qr/'username', and 'password' are required arguments./,
  "Missing password.";

#5
eval { new Novell::Bugzilla( password => $password, ) };
like "$@",
  qr/'username', and 'password' are required arguments./,
  "Missing username.";

