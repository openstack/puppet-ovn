require 'spec_helper_acceptance'

describe 'basic ovn deployment' do

  context 'default parameters' do
    pp= <<-EOS
    include openstack_integration
    include openstack_integration::repos

    include openstack_integration::ovs
    include openstack_integration::ovn
    EOS

    it 'should work with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should show successfully' do
      command('ovn-nbctl show') do |r|
        expect(r.exit_code).to eq 0
      end
      command('ovn-sbctl show') do |r|
        expect(r.exit_code).to eq 0
      end
    end
  end

end
