# ovn params
# == Class: ovn::params
#
# This class defines the variable like
#
class ovn::params {
  include openstacklib::defaults
    case $facts['os']['family'] {
      'RedHat': {
          $ovn_northd_package_name     = 'openvswitch-ovn-central'
          $ovn_controller_package_name = 'openvswitch-ovn-host'
          $ovn_northd_service_name     = 'ovn-northd'
          $ovn_northd_context          = '/files/etc/sysconfig/ovn-northd'
          $ovn_northd_option_name      = 'OVN_NORTHD_OPTS'
          $ovn_controller_service_name = 'ovn-controller'
          $ovn_controller_context      = '/files/etc/sysconfig/ovn-controller'
          $ovn_controller_option_name  = 'OVN_CONTROLLER_OPTS'
      }
      'Debian': {
          $ovn_northd_package_name     = 'ovn-central'
          $ovn_controller_package_name = 'ovn-host'
          $ovn_northd_service_name     = 'ovn-central'
          $ovn_northd_context          = '/files/etc/default/ovn-central'
          $ovn_northd_option_name      = 'OVN_CTL_OPTS'
          $ovn_controller_service_name = 'ovn-host'
          $ovn_controller_context      = '/files/etc/default/ovn-host'
          $ovn_controller_option_name  = 'OVN_CTL_OPTS'
      }
      default: {
        fail " Osfamily ${facts['os']['family']} not supported yet"
      }
    }
}
