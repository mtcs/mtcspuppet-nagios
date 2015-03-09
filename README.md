# Nagios Puppet Module

__This module is under heavy contruction, caution is advised__

This is a puppet mmodule  for nagios. It configures the nagios server and the agents in the machines to be monitored.
If the server is included in a host and agents, the nodes that  include the agent class will automatically appear in the monitoring environment with performance charts.
To do so, it depends on nagiosgrapher to provide performance charts and uses PuppetDB to configure client resources in the server config files.

Operating systems tested:

* Ubuntu 12.04

This module depends on:

* puppetlabs/apache puppet module

The agent monitoring is set by hostgroups in the server node. One needs to declare hostgroups in the server node in order to attribute service monitoring to them.
