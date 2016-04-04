require 'spec_helper'

describe 'ovn::controller' do

  let :redhat_platform_params do {
    :ovn_controller_package_name => 'openvswitch-ovn-host',
    :ovn_controller_service_name => 'ovn-controller'
  }
  end

  shared_examples 'ovn controller' do
    it 'includes params' do
      is_expected.to contain_class('ovn::params')
    end

    it 'includes controller' do
      is_expected.to contain_class('ovn::controller')
    end

    it 'starts controller' do
      is_expected.to contain_service('controller').with(
        :ensure  => true,
        :name    => platform_params[:ovn_controller_service_name],
        :enable  => true,
        )
    end

    it 'installs controller package' do
      is_expected.to contain_package(platform_params[:ovn_controller_package_name]).with(
        :ensure => 'present',
        :name   => platform_params[:ovn_controller_package_name],
        :before => 'Service[controller]'
      )
    end

    it 'configures ovsdb' do
      is_expected.to contain_vs_config('external_ids:ovn-remote').with(
        :ensure  => 'present',
        :value   => params[:ovn_remote],
        :require => 'Service[openvswitch]'
      )

      is_expected.to contain_vs_config('external_ids:ovn-encap-type').with(
        :ensure  => 'present',
        :value   => params[:ovn_encap_type],
        :require => 'Service[openvswitch]'
      )

      is_expected.to contain_vs_config('external_ids:ovn-encap-ip').with(
        :ensure  => 'present',
        :value   => params[:ovn_encap_ip],
        :require => 'Service[openvswitch]'
      )
    end
  end

  context 'with redhat platform' do
    let :params do {
      :ovn_remote     => 'tcp:x.x.x.x:5000',
      :ovn_encap_type => 'geneve',
      :ovn_encap_ip   => '1.2.3.4'
    }
    end

    let :facts do
      {:osfamily => 'Redhat',
      }
    end

    let :platform_params do redhat_platform_params end

    it_configures 'ovn controller'
  end
end
