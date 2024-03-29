#!/usr/bin/perl -w
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

package Novell::Bugzilla;

use version;
our $VERSION = qv("1.3.2");

our $logged_in = 0;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT    = qw();
our @EXPORT_OK = qw(logged_in);

use strict;
use warnings 'all';
use Readonly;
use Carp qw(croak);
use MIME::Base64;
use WWW::Mechanize;
use WWW::Mechanize::DecodedContent;

Readonly my $BUGZILLA_URL => qq(apibugzilla.novell.com);
Readonly my $DEFAULT_AGENT =>
  qq(Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.6));

{

    ##############################################
    # _logged_in()
    # Returns true if authentication succeded, or
    # otherwise false.
    ##############################################
    sub _logged_in {
        my ($self) = @_;

        if ( $self->{'mech'}->status == 200 ) {
            $logged_in = 1;
            return 1;
        }
        else {
            $logged_in = 0;
            return 0;
        }
    }

    ##############################################
    # _login()
    # Perform the authentication
    # return 1 on success, 0 on failure
    ##############################################
    sub _login {
        my ( $self, $username, $password ) = @_;

        $self->{mech}->default_header( Authorization => 'Basic '
              . encode_base64( $username . ':' . $password ) );

        $self->{mech}->get( $self->{protocol} . "://" . $BUGZILLA_URL );

        if ( $self->_logged_in ) {

            # Login succeeded
            return 1;
        }
        else {

            # Login failed
            return 0;
        }
    }

    #########################################################################
    #                            </helper-subs>
    #########################################################################

    sub new {
        my ( $class, $self, %args ) = ( shift, {}, @_ );

        if ( !$args{'username'} || !$args{'password'} ) {

            # No username or password given, croak
            croak "'username', and 'password' are required arguments.\n";
        }

        if ( !$args{'use_ssl'} ) {

            # Use HTTP
            $self->{'protocol'} = 'http';
        }
        else {

            # Use HTTP over SSL
            $self->{'protocol'} = 'https';
        }

        # Create WWW::Mechanize object in $self
        $self->{'mech'} = WWW::Mechanize->new( autocheck => 0 )
          || croak "Could not create WWW::Mechanize object.\n";

        if ( exists $args{'timeout'} ) {
            $self->{'mech'}->timeout( $args{'timeout'} );
        }

        if ( !exists $args{'agent'} ) {

            # No custom agent specified, use default agent instead
            $self->{'mech'}->agent($DEFAULT_AGENT);
        }
        else {
            $self->{'mech'}->agent( $args{'agent'} );
        }

        if ( exists $args{'proxy'} && exists $args{'proxy_type'} ) {

            # Custom proxy required, set it
            $self->{'mech'}->proxy( [ $args{'proxy_type'} ], $args{'proxy'} );
        }

        bless $self, $class;

        if ( !$self->_login( $args{'username'}, $args{'password'} ) ) {

            # Could not login, maybe wrong username or password,
            # croak
            croak "Could not login (wrong username or password?)\n";
        }

        return $self->{'mech'};
    }

}
1;
__END__

=pod 

=head1 SYNOPSIS

        # load Novell::Bugzilla
        use Data::Dumper;
        use Novell::Bugzilla qw/logged_in/;

        # minimalistic example of indirect invocation:
        my $novell_bugzilla = new Novell::Bugzilla(username => 'foo',
                                                   password => 'bar');

        # ... or better, direct invocation w/:
        # my $novell_bugzilla = Novell::Bugzilla->new(...);

        # $novell_bugzilla is a fully authenticated WWW::Mechanize object
        # on 'bugzilla.novell.com' now.
        print Dumper \$novell_bugzilla;
        
        # are we logged in?
        return $logged_in;

=head1 DESCRIPTION

Novell::Bugzilla is a lightweight, easy and useful interface for creating
fully authenticated WWW::Mechanize objects on bugzilla.novell.com.
It can either work on HTTP or HTTP over SSL and allows its users to set a
custom HTTP User-Agent or a HTTP(s) Proxy, and probably more in future if
time permits.

=head1 FEATURES

=over 4

=item * Authentication using apibugzilla.novell.com

=item * HTTP or HTTP over SSL, customizable

=item * HTTP User-Agent customizable as well

=item * Proxy-Support for different types of proxies

=item * Customizable HTTP Timeouts

=item * Leightweightness++ =)

=back

=head1 OPTIONS

During instance creation you can provide the following optional keys to the 
package. ('username' and 'password' are B<required> keys!)

=over 2

=item use_ssl (B<required> to be 1 on bugzilla.novell.com (default))

  $nb = new Novell::Bugzilla(use_ssl => 0);

=item agent (be careful when changing)

  $nb = new Novell::Bugzilla(agent => "Mozilla/1.37");

=item timeout

  $nb = new Novell::Bugzilla(timeout => 120);

=item proxy and proxy_type

  $nb = new Novell::Bugzilla(proxy      => "http://localhost:80", 
                             proxy_type => ["http"]);

=back

=head1 EXAMPLES

Please take a look in the I<examples/> directory that is shipped along with 
this package.

=head1 BUGS

Although Novell::Bugzilla is pretty leightweight and tiny there might still be
some bugs. However, there is no known one at the moment. If you find some bugs
please don't hesitate to fix them yourself and send me the patches.

=head1 SECURITY

Be careful when running this in a shared environment. Make sure that you don't
hardcode username and password readable for someone else.

=head1 RESOURCES

There will perhaps be a CPAN version, but currently there is only the version
on github you may want to checkout:

https://github.com/mweckbecker/Novell--Bugzilla

=head1 LICENSE

This code is free software and released under the GPLv3 license. Please see the
LICENSE file that comes along with this distribution for further information.

=head1 AUTHOR
Copyright (C) 2010 Matthias Weckbecker,  <matthias@weckbecker.name>
