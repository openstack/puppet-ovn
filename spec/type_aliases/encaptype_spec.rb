require 'spec_helper'

describe 'Ovn::EncapType' do
  describe 'valid types' do
    context 'with valid types' do
      [
        'geneve',
        'vxlan'
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        '',
        'vlan',
        true,
        false,
        1,
        ['vxlan'],
        {'' => 'vxlan'},
        {'vxlan' => ''}
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
