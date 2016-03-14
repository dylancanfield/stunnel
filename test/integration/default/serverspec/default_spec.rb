require 'spec_helper'

describe 'stunnel::default' do

  case os[:family]
  when 'debian', 'ubuntu'
    package_name = 'stunnel4'
  else
    package_name = 'stunnel'
  end

  describe package(package_name) do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  %w(/etc/stunnel/stunnel.conf /etc/default/stunnel4).each do |f|
  describe file(f) do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:size) { is_expected.to be > 0 }
      it { is_expected.to be_owned_by('root') }
      it { is_expected.to be_grouped_into('root') }
      it { is_expected.to be_mode(644) }
  end
  end

end
