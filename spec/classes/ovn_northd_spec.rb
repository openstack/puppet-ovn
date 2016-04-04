require 'spec_helper'

describe 'ovn::northd' do

  let :redhat_platform_params do {
    :ovn_northd_package_name => 'openvswitch-ovn-central',
    :ovn_northd_service_name => 'ovn-northd' 
  }
  end

  shared_examples 'ovn northd' do
    it 'includes params' do
      is_expected.to contain_class('ovn::params')
    end

    it 'starts northd' do
      is_expected.to contain_service('northd').with(
        :ensure  => true,
        :name    => platform_params[:ovn_northd_service_name],
        :enable  => true,
      )
    end

    it 'installs package' do
      is_expected.to contain_package(platform_params[:ovn_northd_package_name]).with(
        :ensure => 'present',
        :name   => platform_params[:ovn_northd_package_name],
        :before => 'Service[northd]'
      )
    end
  end

  context 'on redhat' do
    let :platform_params do redhat_platform_params end

    let :facts do
      {:osfamily => 'Redhat',
      }
    end

    it_configures 'ovn northd'
  end

end

