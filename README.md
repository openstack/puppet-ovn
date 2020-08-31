Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/tc/badges/puppet-ovn.svg)](https://governance.openstack.org/tc/reference/tags/index.html)

<!-- Change things from this point on -->

# OVN

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ovn](#setup)
    * [What ovn affects](#what-ovn-affects)

## Overview

Puppet module for the OVN project.

## Module Description

This module has two class
1. ovn::northd to be used in machines that needs to run ovn-northd daemon
2. ovn::controller to be used in the compute nodes

## Setup

### Effects

ovn::northd just installs the ovn package and starts the ovn-northd serivce.
ovn::controller installs ovn package and starts the ovn-controller service.
Before starting ovn-controller process it updates the external_ids column
of Open_vSwitch table in vswitchd ovsdb. It relies on external data for some
of its parameters
* ovn_remote_ip - This should point to the url where ovn-nb and ovn-sb 
  db server is running
* ovn_encap_ip - This should point to the ip address that other hypervisors
  would use to tunnel to this hypervisor.
* ovn_encap_type - Encapsulation type to be used by this controller. Defaults
  to geneve

Release notes for the project can be found at:
  https://docs.openstack.org/releasenotes/puppet-ovn/

The project source code repository is located at:
   https://opendev.org/openstack/puppet-ovn/

Developer documentation for the entire puppet-openstack project can be found at:
  https://docs.openstack.org/puppet-openstack-guide/latest/
