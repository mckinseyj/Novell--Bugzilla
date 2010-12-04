#!/usr/bin/perl -w
########################################################################
#
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
#
########################################################################

package Novell::Bugzilla;

our $VERSION   = '1.2c';
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(_logged_in);

use strict;
use warnings 'all';
use Readonly;
use Carp qw/croak carp/;
use WWW::Mechanize;

Readonly my $BUGZILLA_URL => qq(bugzilla.novell.com);

{

    ##############################################
    # _get_form_by_field()
    # Set the login form to the current form in
    # $mech or croak
    ##############################################
    sub _get_form_by_field {
        my ( $self, $field ) = @_;
        my $i = 1;

        if ( !$field ) {
            croak "invalid field";
        }

        my $mech = $self->{mech};

        foreach my $form ( $mech->forms() ) {
            if ( $form->find_input($field) ) {
                $mech->form_number($i);
                return;
            }
            $i++;
        }

        croak "No form with the field $field available";
    }

    ##############################################
    # _logged_in()
    # Returns ture if authentication succeded, or
    # otherwise false.
    ##############################################
    sub _logged_in {
        my ( $self, $content ) = @_;

        if ( $content !~ m{Login failed\.}ix ) {

            # Login succeeded, return 1
            return 1;
        }
        else {

            # Login failed, return 0
            return 0;
        }
    }

    ##############################################
    # _login()
    # Perform the authentication on iChain, return
    # 1 on success, 0 on failure
    ##############################################
    sub _login {
        my $self = shift;
        my ( $username, $password ) = @_;

        my $mech = $self->{'mech'};

        my $login_page =
            $self->{'protocol'} . '://'
          . $self->{'server'}
          . '/index.cgi?GoAheadAndLogIn=1';

        $mech->get($login_page);

        if ( $mech->status != 200 || !$mech->success ) {

            # HTTP code > 200, !$mech->success
            croak "Could not _login(), http code was != 200";
        }

        $self->_get_form_by_field('username');

        $mech->field( 'url',
            $self->{'protocol'} . "://" . $self->{'server'} . "/" );

        $mech->field( 'proxypath', 'reverse' );
        $mech->field( 'username',  $username );
        $mech->field( 'password',  $password );

        my $response = $mech->submit_form();

        if ( $self->_logged_in( $response->content ) ) {

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
        my $class = shift;
        my $self  = {};
        my %args  = @_;

        if ( !$args{'username'} || !$args{'password'} ) {

            # No username or password given, croak
            croak "'username', and 'password' are required arguments.";
        }

        if ( !exists $args{'server'} ) {

            # No 'server' key in %args, use default
            # 'bugzilla.novell.com'
            $self->{'server'} = $BUGZILLA_URL;
        }
        else {

            # Different server specified
            $self->{'server'} = $args{'server'};
        }

        if ( !delete $args{'use_ssl'} ) {

            # Use HTTP
            $self->{'protocol'} = 'http';
        }
        else {

            # Use HTTP over SSL
            $self->{'protocol'} = 'https';
        }

        # Create WWW::Mechanize object in $self
        $self->{'mech'} = WWW::Mechanize->new
          or croak 'Could not create WWW::Mechanize object';

        if ( !exists $args{'agent'} ) {

            # No custom agent specified, use default agent instead
            $self->{'mech'}->agent('Mozilla/5.0 (X11; U; Linux i686; en-US;)');
        }
        else {
            $self->{'mech'}->agent = $args{'agent'};
        }

        if ( exists $args{'proxy'} && exists $args{'proxy_type'} ) {
            
            # Custom proxy required, set it
            $self->{'mech'}->proxy([$proxy_type], $proxy);
        }

        bless $self, $class;

        if ( !$self->_login( $args{'username'}, $args{'password'} ) ) {

            # Could not login, maybe wrong username or password,
            # croak
            croak 'Could not login (wrong username or password?)';
        }

        return $self->{'mech'};
    }

}
1;
__END__

=pod 

=head1 SYNOPSIS
        
        use Novell::Bugzilla;
        use Data::Dumper;

        my $novell_bugzilla = new Novell::Bugzilla(username => 'foo',
                                                   password => 'bar');

        # $novell_bugzilla is a fully authenticated WWW::Mechanize object
        # on 'bugzilla.novell.com' now.
        print Dumper \$novell_bugzilla;
        return 0;

=head1 DESCRIPTION

Novell::Bugzilla is a lightweight, easy and useful interface for creating
fully iChain authenticated WWW::Mechanize objects on bugzilla.novell.com.
It can either work on HTTP or HTTP over SSL and allows its users to set a
custom HTTP User-Agent or a HTTP(s) Proxy, and probably more in future if
time permits.

=head1 FEATURES

=over 2
=item Authentication through iChain on 'bugzilla.novell.com' or any other 
      iChain based application.

=item HTTP or HTTP over SSL, customizable

=item HTTP User-Agent customizable as well

=item Proxy-Support for different types of proxies

=item Leightweightness++ =)
=back


=head1 OPTIONS


=head1 EXAMPLES

Please take a look in the L<examples/> directory that is shipped along with 
this package.

=head1 BUGS

Although Novell::Bugzilla is pretty leightweight and tiny there might still be
some bugs. However, there is no known one at the moment. If you find some bugs
please don't hesitate to fix them yourself and send me the patches.

=head1 RESOURCES

There will perhaps be a CPAN version, but currently there is only the version
on github you may want to checkout:

=over2
https://github.com/mweckbecker/Novell--Bugzilla
=back

=head1 LICENSE

This code is free software and released under the GPLv2 license. Please see the
LICENSE file that comes along with this distribution.

=head1 AUTHOR
Copyright (C) 2010 Matthias Weckbecker,  <matthias@weckbecker.name>
