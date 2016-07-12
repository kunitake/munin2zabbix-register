munin2zabbix-register
=====================
NAME
--------------

        munin2zabbix-register.pl - This script can register zabbix items and graphs from munin-node plugins.

SYSOPSIS
--------------
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
--------------
        munin2zabbix-register.pl - This script can register zabbix items and graphs from munin-node plugins.
        This program was inspired by zabbix_munin_plugin.py.
        
LIMITATION!!
---------------
        munin2zabbix-register.pl CAN NOT take care of CDEF itself.

SEE ALSO
--------------
      munin2zabbix-sender ( This script can send data from munin plugins to zabbix via zabbix_sender. )
      https://github.com/kunitake/munin2zabbix-sender

       https://raw.github.com/kunitake/munin2zabbix-register/master/README.md

       ZabbixAPI for Perl
        https://github.com/mikeda/ZabbixAPI
        http://mikeda.jp/wiki/zabbixapi.pm

       zabbix_munin_plugin.py
        https://github.com/oopsops/scripts/tree/master/zabbix

AUTHOR
--------------
       KUNITAKE Koichi

