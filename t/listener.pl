#!/usr/bin/env perl

use 5.16.0;
use warnings;

package mylogcollectorscript;
use Moose;
use Message::Passing::DSL;

with 'MooseX::Getopt',
    'Message::Passing::Role::Script';

has socket_bind => (
    is => 'ro',
    isa => 'Str',
    default => 'tcp://*:5558',
);



sub build_chain {
    my $self = shift;
    message_chain {
        output console => (
            class => 'Lol',
        );
        input zmq => (
            class => 'ZeroMQ',
            output_to => 'console',
            socket_bind => $self->socket_bind,
        );
    };
}

__PACKAGE__->start unless caller;
1;

BEGIN {
   package Message::Passing::Output::Lol;

   use JSON::XS;
   use Moo;
   with 'Message::Passing::Role::Output';
   has sprinter => (
      is => 'ro',
      required => 1,
   );

   sub BUILDARGS {
      my ($self, @args) = @_;

      my $args = $self->next::method(@args);

      require Log::Sprintf;
      $args->{sprinter} = Log::Sprintf->new({
         format => '[%l][%p][%c] %m',
      });

      return $args;
   }

   sub consume {
      say $_[0]->sprinter->sprintf(decode_json($_[1]))
   }
}
