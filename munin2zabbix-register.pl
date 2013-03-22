#!/usr/bin/perl
use strict;
use warnings;

use ZabbixAPI;

use Getopt::Long;
use Pod::Usage 'pod2usage';

######################################################################
# DO NOT EDIT following lines
my $version = [ 'version 0.01 alpha   2013/03/22', ];

######################################################################
# EDIT following lines as you like.

# Path of Command and plugins dir.
my $munin_run_command = '/usr/sbin/munin-run';
my $munin_plugins_dir = '/etc/munin/plugins';

my $user    = 'Admin';
my $pass    = '';
my $api_url = 'http://localhost/zabbix/';

my $template = 'Template_Linux';

######################################################################

# type
# 0 - Zabbix agent;
# 1 - SNMPv1 agent;
# 2 - Zabbix trapper;
# 3 - simple check;
# 4 - SNMPv2 agent;
# 5 - Zabbix internal;
# 6 - SNMPv3 agent;
# 7 - Zabbix agent (active);
# 8 - Zabbix aggregate;
# 9 - web item;
# 10 - external check;
# 11 - database monitor;
# 12 - IPMI agent;
# 13 - SSH agent;
# 14 - TELNET agent;
# 15 - calculated;
# 16 - JMX agent.
my $type = 2;

# value_type
# 0 - numeric float;
# 1 - character;
# 2 - log;
# 3 - numeric unsigned;
# 4 - text.
my $value_type = 0;

# Delta
# 0 - As is
# 1 - Delta (speed per second)
# 2 - Delta (simple change)
my $delta = 0;

# calc_fnc
# 1 - min
# 2 - avg
# 4 - max
# 7 - all
my $calc_fnc = 2;

# yaxisside
# 0 - left
# 1 - right
my $yaxisside = 0;

#graph type
# 0 - Normal
# 1 - Stacked
# 2 - Pie
# 3 - Exploted
my $graphtype = 0;

# RBG
my @colors = qw/0 1 2 3 4 5 6 7 8 9 a b c d e f/;

######################################################################

my ( $help, $verbose, $called_plugin, $all_plugins );

GetOptions(
    'help'     => \$help,
    'verbose'  => \$verbose,
    'plugin=s' => \$called_plugin,
    'all'      => \$all_plugins,
);
if ( $help || ( !$called_plugin && !$all_plugins ) ) {
    pod2usage(1);
}

my @munin_plugins;
if ($all_plugins) {
    @munin_plugins = `ls $munin_plugins_dir`;
}
else {
    @munin_plugins = split( /,|:/, $called_plugin );
}

my $za = ZabbixAPI->new("$api_url");
$za->login( "$user", "$pass" );

my @templates = $template;
my $templateids
    = $za->template_get( { filter => { host => \@templates } },
    'templateid' );
my $templateid = @$templateids[0];

foreach my $plugin (@munin_plugins) {

    # get from munin config
    my @munin_configs = `$munin_run_command $plugin config`;
    my %munin_graph   = ();
    my %munin_item    = ();
    foreach my $line (@munin_configs) {
        my ( $key, @data ) = split( /\s/, $line );
        my $value = join( " ", @data );

        if ( $line =~ /^graph_/ ) {
            $munin_graph{$key} = $value;
        }
        elsif ( $line =~ /\./ ) {
            my ( $item, $type ) = split( /\./, $key );
            $munin_item{$item}{$type} = $value;
            $graphtype = 1 if ( $type eq 'draw' && $value eq 'STACK' );
        }
    }

    #
    my @gitems;
    my $sortorder = 0;
    foreach my $key ( keys %munin_item ) {
        $delta = 1
            if ( $munin_item{$key}{'type'} eq 'DERIVE'
            || $munin_item{$key}{draw} eq 'COUNTER' );
        $delta = 2 if ( $munin_item{$key}{'type'} eq 'ABSOLUTE' );
        my $gitem_ref = '';
        my $createitems = $za->item_create(
            {   'name'       => 'Munin Plugin $1.$2',
                'key_'       => "munin[$plugin,$key]",
                'hostid'     => $templateid,
                'type'       => $type,
                'value_type' => $value_type,
                'delta'      => $delta,
            }
        );
        $gitem_ref->{'itemid'} = $createitems->{'itemids'}[0];

        my $hex_rgb = '';
        for ( my $i = 1; $i <= 6; $i++ ) {
            $hex_rgb .= $colors[ int( rand scalar @colors ) ];
        }
        $gitem_ref->{'color'}     = $hex_rgb;
        $gitem_ref->{'drawtype'}  = 0;
        $gitem_ref->{'sortorder'} = $sortorder;
        $gitem_ref->{'yaxisside'} = $yaxisside;
        $gitem_ref->{'calc_fnc'}  = $calc_fnc;
        $gitem_ref->{'type'}      = 0;
        $sortorder++;

        if ( $graphtype == 1 ) {
            push( @gitems, $gitem_ref )
                if ( $munin_item{$key}{'draw'} eq 'STACK' );
        }
        else {
            push( @gitems, $gitem_ref );
        }

    }

    my $result = $za->graph_create(
        {   'gitems'           => \@gitems,
            'name'             => $munin_graph{'graph_title'},
            'width'            => 900,
            'height'           => 200,
            'yaxismin'         => '0.0000',
            'yaxismax'         => '3.0000',
            'show_work_period' => 1,
            'show_triggers'    => 1,
            'graphtype'        => $graphtype,
            'show_legend'      => 1,
            'show_3d'          => 0,
            'percent_left'     => '0.0000',
            'percent_right'    => '0.0000',
            'ymin_type'        => 0,
            'ymax_type'        => 0,
            'ymin_itemid'      => 0,
            'ymax_itemid'      => 0,
        }
    );
}

1;

__END__

=head1 NAME

 munin2zabbix-register.pl - This script can register zabbix items and graphs from munin-node plugins.

=head1 SYNOPSIS

munin2zabbix-register.pl [options]

  Options
    [-h|--help]      Print message.
    [-v|--verbose]   Print verbose messages.
    [-p|--plugin]    <name of munin plugin>  Register items and graph of munin plugin.
    [-a|--all]       Register items and graphs which available munin-node plugins.

  Examples:
    # munin2zabbix-register.pl -p mysql_select_types

    # munin2zabbix-register.pl -a


  See Also:
    $ perldoc munin2zabbix-register.pl

=head1 DESCRIPTION

 munin2zabbix-register.pl - This script can register zabbix items and graphs from munin-node plugins.

=head1 SEE ALSO

https://raw.github.com/kunitake/munin2zabbix-register/master/README.md

ZabbixAPI for Perl
 https://github.com/mikeda/ZabbixAPI
 http://mikeda.jp/wiki/zabbixapi.pm

=head1 AUTHOR

KUNITAKE Koichi <koichi@kunitake.org>

=cut
