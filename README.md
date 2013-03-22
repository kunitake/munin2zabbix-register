munin2zabbix-register
=====================

NAME
----------------

munin2zabbix-register.pl - This script can register zabbix items and graphs from munin-node plugins.

SYNOPSIS
----------------
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

DESCRIPTION
----------------
munin2zabbix-register.pl - This script can register zabbix items and graphs from munin-node plugins.

SEE ALSO
----------------
https://raw.github.com/kunitake/munin2zabbix-register/master/README.md

ZabbixAPI for Perl
https://github.com/mikeda/ZabbixAPI
http://mikeda.jp/wiki/zabbixapi.pm

AUTHOR
----------------
KUNITAKE Koichi <koichi@kunitake.org>
