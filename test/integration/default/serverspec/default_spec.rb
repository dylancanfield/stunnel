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

  describe file('/var/log/stunnel.log') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    its(:size) { is_expected.to be == 0 }
    it { is_expected.to be_owned_by('root') }
    it { is_expected.to be_grouped_into('root') }
    it { is_expected.to be_mode(644) }
  end

  case IO.read('/proc/1/comm').chomp
  when 'init'
    service_file = '/etc/init.d/stunnel4'
    service_file_perms = 755
  when 'systemd'
    service_file = '/etc/systemd/system/stunnel4.service'
    service_file_perms = 644
  end

  if service_file && service_file_perms
    describe file(service_file) do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:size) { is_expected.to be > 0 }
      it { is_expected.to be_owned_by('root') }
      it { is_expected.to be_grouped_into('root') }
      it { is_expected.to be_mode(service_file_perms) }
    end
  end
end
