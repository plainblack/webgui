package WebGUI::Middleware::Debug::Performance;
use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Base);
our $VERSION = '0.07';

sub panel_name { 'Asset Performance' }

sub run {
    my ($self, $env, $panel) = @_;

    my $perf_log = [];
    $env->{'webgui.perf.logger'} = sub {
        my $args = shift;
        my $asset = $args->{asset};
        my $log_data = {
            'time'          => $args->{time},
            'type'          => $args->{type},
            'message'       => $args->{message},
            $asset ? (
                'viewUrl'       => $asset->getUrl,
                'editUrl'       => $asset->getUrl('func=edit'),
                'assetTitle'    => $asset->title,
            ) : (),
        };
        push @$perf_log, $log_data;
    };

    return sub {
        my $res = shift;

        $panel->nav_subtitle(scalar @$perf_log . ' events');
        if (@$perf_log) {
            $panel->content($self->render_log($perf_log));
        }
    };
}

my $log_template = __PACKAGE__->build_template(<<'EOTMPL');
<table>
    <thead>
        <tr>
            <th>Time</th>
            <th>Type</th>
            <th>Item</th>
        </tr>
    </thead>
    <tbody>
% my $i;
% for my $event ( @{ $_[0]->{list} } ) {
            <tr class="<%= ++$i % 2 ? 'plDebugOdd' : 'plDebugEven' %>">
                <td><%= $event->{time} %></td>
                <td><%= $event->{type} %></td>
                <td>
%     if ($event->{message}) {
                    <%= $event->{message} %>
%     }
%     if ($event->{assetTitle}) {
                    <a href="<%= $event->{viewUrl} %>">View</a>
                    <a href="<%= $event->{editUrl} %>">Edit</a>
                    <%= $event->{assetTitle} %>
%     }
                </td>
            </tr>
% }
    </tbody>
</table>
EOTMPL

sub render_log {
    my ($self, $events) = @_;
    $self->render($log_template, { list => $events });
}

1;

