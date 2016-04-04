# ovn northd
# == Class: ovn::northd
#
# installs ovn package starts the ovn-northd service
#
class ovn::northd() {
    include ::ovn::params
    service { 'northd':
        ensure => true,
        enable => true,
        name   => $::ovn::params::ovn_northd_service_name
    }

    package { $::ovn::params::ovn_northd_package_name:
        ensure => present,
        name   => $::ovn::params::ovn_northd_package_name,
        before => Service['northd']
    }
}
