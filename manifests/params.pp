# ovn params
# == Class: ovn::params
#
# This class defines the variable like

class ovn::params {
    case $::osfamily {
      'Redhat': {
          $ovn_northd_package_name     = 'openvswitch-ovn-central'
          $ovn_controller_package_name = 'openvswitch-ovn-host'
          $ovn_northd_service_name     = 'ovn-northd'
          $ovn_controller_service_name = 'ovn-controller'
      }
      'Debian': {
          $ovn_northd_package_name     = 'ovn-central'
          $ovn_controller_package_name = 'ovn-host'
          $ovn_northd_service_name     = 'ovn-central'
          $ovn_controller_service_name = 'ovn-host'
      }
      default: {
        fail " Osfamily ${::osfamily} not supported yet"
      }
    }
}
