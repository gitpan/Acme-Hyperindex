#!/usr/bin/perl

package Acme::Hyperindex;

=head1 NAME

Acme::Hyperindex - Look deep into structures using a list of indexes

=head1 SYNOPSIS

  use strict;
  use Acme::Hyperindex;

  my @struct = (
      { j_psi => [qw( eta_prime phi kaon )] },
      { j_psi => [qw( selectron down tau_sneutrino )] },
      { j_psi => [qw( upsilon gluino photino )] }
  );

  print @struct[[ 2, 'j_psi', 1 ]], "\n"; ### Prints gluino
  my $row = @struct[[ 1, 'j_psi' ]];      ### Row contains [qw( ... )]

=head1 DESCRIPTION

When you use dynamic datastructures,
the perl index syntax may not be felxible enough.
A little examle:

  my @struct = (
      {
          pion        => [
              [qw(strange j_psi positron)],
              [qw(down_squark electron gluino)],
          ],
          w_plus_wino => [
              [qw(neutralino tau kaon)],
              [qw(charm_squark photino strange_squark)]
          ],
      },
  );

Now to get to the kaon particle, normally we use:

  my $particle = $struct[0]->{w_plus_wino}->[2];
   -- or better --
  my $particle = $struct[0]{w_plus_wino}[2];

But what if you don't know how deep your datastructure is
at compile time? 'Course this is doable:

  my $particle = \@struct;
  $particle = $particle->[$_] for qw(0 pion 2);

Two problems here: Perl will tell you 'Not an ARRAY reference'
once we try to index in the hash on 'pion' with this array indexing syntax.
It's damn ugly and looks complicated.

So Acme::Hyperindex lets you index on a .... amount of ...

  my $particle = @struct[[ 0, 'pion', 2 ]];
    -- or even --
  my $particle = @struct[[ @indexes ]];

=cut

use strict;
use warnings;

use base qw(Exporter);
use vars qw(@EXPORT $VERSION);

use Carp qw(croak);
use Filter::Simple;

@EXPORT = qw(hyperindex);

$VERSION = 0.02;

FILTER_ONLY
    code => sub { s/(\$|\@)\s*(\w+)\[\[(.*?)\]\]/hyperindex( $1$2, \@{[ $3 ]} )/g };

sub hyperindex ($\@) {
    my $structure = shift;
    my $indexes   = shift;

    my $item = $structure;
    for my $index ( @$indexes ) {
        if ( ref $item eq 'HASH' ) {
            $item = $item->{$index};
        } elsif ( ref $item eq 'ARRAY' ) {
            $item = $item->[$index];
        } else {
            use Data::Dumper;
            print Dumper { item => $item, struct => $structure, index => $index, indexes => $indexes };
            croak "Can't index on type '". (ref($item) || 'undef') ."' with index '$index'";
        }
    }

    return $item;
}

=head1 TODO

=over 4

=item * make hyperindex work for all perl's datatypes

=back

=head1 AUTHOR

Berik Visschers <berikv@xs4all.nl>

=head1 COPYRIGHT

Copyright 2005 by Berik Visschers E<lt>berikv@xs4all.nlE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut

1
