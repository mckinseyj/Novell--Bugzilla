#!/usr/bin/perl -w
########################################################################
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

package Novell::Bugzilla;

our $VERSION = '1.1c';

use strict;
use warnings 'all';
use Carp qw/croak carp/;
use WWW::Mechanize;

{
    
    ##############################################
    # _get_form_by_field()
    # 
    #
    ##############################################
    sub _get_form_by_field {
        my ( $self, $field ) = @_;

        croak 'invalid field' unless $field;

        my $mech = $self->{mech};
        my $i    = 1;

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
    #
    #
    ##############################################
    sub _logged_in {
        my ( $self, $response ) = @_;

        if ($response->content !~ m{Login failed\.}i) {
            # Login failed, return 1
            return 1;
        }
        else {
            # Login succeeded, return 0
            return 0;
        }
    }

    ##############################################
    # _login()
    #
    #
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

        croak "Could not open page $login_page"
          unless $mech->status == '200'
              or $mech->status == '404'
              or not $mech->success;

        $self->_get_form_by_field('username');

        $mech->field( 'url',
            $self->{'protocol'} . "://" . $self->{'server'} . "/" );

        $mech->field( 'proxypath', 'reverse' );
        $mech->field( 'username',  $username );
        $mech->field( 'password',  $password );

        my $response = $mech->submit_form();

        if ($self->_logged_in($response)) {
            # Login succeeded
            return 1;
        }
        else {
            # Login failed
            return 0;
        }
    }

    #########################################################################

    sub new {
        my $class = shift;
        my $self  = {};
        my %args  = @_;

        if (!$args{'username'} or !$args{'password'}) {
            # No username or password given, croak
            croak "'username', and 'password' are required arguments."
        }

        if (!exists $args{'server'}) {
            # No 'server' key in %args, use default
            # bugzilla.novell.com
            $args{'server'} = 'bugzilla.novell.com';
        }

        if (!delete $args{'use_ssl'}) {
            # Use http
            $self->{'protocol'} = 'http';
        }
        else {
            # Use http over SSL
            $self->{'protocol'} = 'https';
        }

        # Create WWW::Mechanize object
        $self->{'mech'} = WWW::Mechanize->new
          or croak 'Could not create WWW::Mechanize object';

        if (!exists $args{'agent'}) {
            $self->{'mech'}->agent('Mozilla/5.0 (X11; U; Linux i686; en-US;)');
        }
        else {
            $self->{'mech'}->agent = $args{'agent'};
        }

        bless $self, $class;

        if (!$self->_login( $args{'username'}, $args{'password'})) {
            # Could not login, maybe wrong username or password,
            # croak
            croak 'Could not login (wrong username or password?)';
        }

        return $self;
    }

}
1;
__END__

