package Log::Dispatch::Email::EmailSender;

use warnings;
use strict;
use Encode qw(encode);
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP;

use Log::Dispatch::Email;
use base 'Log::Dispatch::Email';

use 5.008008;

our $VERSION = '0.02';

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my %p     = @_;

    my $self = $class->SUPER::new(%p);
    $self->{use_transport} = delete $p{use_transport};
    $self->{host}          = delete $p{host};
    $self->{port}          = delete $p{port};
    $self->{ssl}           = delete $p{ssl};
    $self->{sasl_username} = delete $p{sasl_username};
    $self->{sasl_password} = delete $p{sasl_password};

    return $self;
}

sub send_email {
    my $self = shift;
    my %p    = @_;

    local $?;
    eval {
        my $to_str = join ',', @{ $self->{to} };
        my $d_enc1 = 'MIME-Header-ISO_2022_JP';
        my $d_enc2 = 'iso-2022-jp';
        my $email  = _create_email(
            {   from          => $self->{from},
                to            => $to_str,
                subject       => $self->{subject},
                header_encode => $self->{header_encode} || $d_enc1,
                body_encode   => $self->{body_encode} || $d_enc2,
                body          => $p{message},
            }
        );

        my $transport = {};
        if ( $self->{use_transport} ) {
            $transport->{transport} = Email::Sender::Transport::SMTP->new(
                host => $self->{host} || 'localhost',
                port => $self->{port},
                ssl  => $self->{ssl},
                sasl_username => $self->{sasl_username},
                sasl_password => $self->{sasl_password},
            );
        }
        sendmail( $email, $transport, { to => $self->{to} } );
    };

    warn $@ if $@;
}

sub _create_email {
    my $opt   = shift;
    my $enc1  = $opt->{header_encode};
    my $enc2  = $opt->{body_encode};
    my $email = Email::MIME->create(
        header => [
            From    => encode( $enc1, $opt->{from} ),
            To      => encode( $enc1, $opt->{to} ),
            Subject => encode( $enc1, $opt->{subject} ),
        ],
        attributes => {
            content_type => 'text/plain',
            charset      => $enc2,
            encoding     => '7bit',
        },
        body => encode( $enc2, $opt->{body} ),
    );
    return $email;
}

1;

__END__
=encoding utf-8

=head1 NAME

Log::Dispatch::Email::EmailSender - Subclass of Log::Dispatch::Email that uses the Email::Sender::Simple module

=head1 SYNOPSIS

  ###
  ### simple usage
  ###
  use Log::Dispatch;
  my $log =
      Log::Dispatch->new
          ( outputs =>
                [ [ 'Email::EmailSender',
                    min_level     => 'emerg',
                    from          => 'logger@example.com',
                    to            => [ qw( foo@example.com bar@example.org ) ],
                    subject       => 'Big error!',
                    header_encode => 'MIME-Header-ISO_2022_JP',
                    body_encode   => 'iso-2022-jp', ],
                ],
          );
  $log->emerg("Something bad is happening");

  ###
  ### Sending a message with Email::Sender::Transport::SMTP
  ### Does not support ssl option.
  ###
  use Log::Dispatch;
  my $log =
      Log::Dispatch->new
          ( outputs =>
                [ [ 'Email::EmailSender',
                    min_level     => 'emerg',
                    from          => 'logger@example.com',
                    to            => [ qw( foo@example.com bar@example.org ) ],
                    subject       => 'Big error!',
                    header_encode => 'MIME-Header-ISO_2022_JP',
                    body_encode   => 'iso-2022-jp',
                    use_transport => 1,
                    host          => [your smtp host],
                    port          => [your smtp port number],
                    sasl_username => [your username],
                    sasl_password => [your password], ],
                ],
          );
  $log->emerg("Something bad is happening");

=head1 DESCRIPTION

This is a subclass of L<Log::Dispatch::Email> that implements the
send_email method using the L<Email::Sender::Simple> module.

=head1 DESCRIPTION(ja)

デフォルトで日本語の件名と本文を ISO_2022_JP にエンコーディングしてくれます。
他のモジュールのように文字化けが起こりません。

=head1 DEPENDENCIES

=over

=item L<Log::Dispatch::Email>

=item L<Encode>

=item L<Email::MIME>

=item L<Email::Sender::Simple>

=item L<Email::Sender::Transport::SMTP>

=back


=head1 BUGS AND LIMITATIONS

Does not support SSL on Email::Sender::Transport::SMTP.

I don't understand why it doesn't work.

=head1 AUTHOR

keroyon E<lt>keroyon@cpan.orgE<gt>

=head1 SEE ALSO

Log::Dispatch
Log::Dispatch::Email::MailSender

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

