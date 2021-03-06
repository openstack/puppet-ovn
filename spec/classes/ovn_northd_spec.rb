require 'spec_helper'

describe 'ovn::northd' do

  shared_examples_for 'systemd env' do
    it 'creates systemd conf' do
      is_expected.to contain_augeas('config-ovn-northd').with({
        :context => platform_params[:ovn_northd_context],
        :changes => "set " + platform_params[:ovn_northd_option_name] +
                    " '\"--db-nb-addr=0.0.0.0 --db-sb-addr=0.0.0.0 --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes\"'",
      })
    end
  end

  shared_examples_for 'ovn northd' do
    it 'includes params' do
      is_expected.to contain_class('ovn::params')
    end

    it 'starts northd' do
      is_expected.to contain_service('northd').with(
        :ensure    => true,
        :name      => platform_params[:ovn_northd_service_name],
        :enable    => true,
        :hasstatus => platform_params[:ovn_northd_service_status],
        :pattern   => platform_params[:ovn_northd_service_pattern],
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

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
        }))
      end

      case facts[:osfamily]
      when 'Debian'
        let(:platform_params) do
          {
            :ovn_northd_package_name    => 'ovn-central',
            :ovn_northd_service_name    => 'ovn-central',
            :ovn_northd_service_status  => false,
            :ovn_northd_service_pattern => 'ovn-northd',
            :ovn_northd_context         => '/files/etc/default/ovn-central',
            :ovn_northd_option_name     => 'OVN_CTL_OPTS'
          }
        end
        it_behaves_like 'ovn northd'
        it_behaves_like 'systemd env'
      when 'RedHat'
        let(:platform_params) do
          {
            :ovn_northd_package_name    => 'openvswitch-ovn-central',
            :ovn_northd_service_name    => 'ovn-northd',
            :ovn_northd_service_status  => true,
            :ovn_northd_service_pattern => nil,
            :ovn_northd_context         => '/files/etc/sysconfig/ovn-northd',
            :ovn_northd_option_name     => 'OVN_NORTHD_OPTS'
          }
        end
        it_behaves_like 'ovn northd'
        it_behaves_like 'systemd env'
      end
    end
  end
end

