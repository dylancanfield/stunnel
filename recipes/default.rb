node[:stunnel][:packages].each do |s_pkg|
  package s_pkg
end

# Create directory to hold the pid inside the chroot jail
if(node[:stunnel][:use_chroot])
  directory "#{node[:stunnel][:chroot_path]}" do
    owner node[:stunnel][:user]
    group node[:stunnel][:group]
    recursive true
    action :create
  end
end

user 'stunnel4' do
  home '/var/run/stunnel4'
  system true
  shell '/bin/false'
  supports :manage_home => true
  not_if { node['platform_family'] == 'debian' }
end

template '/etc/init.d/stunnel4' do
  source 'sysvinit/stunnel4.erb'
  user 'root'
  group 'root'
  mode 0755
  not_if { node['platform_family'] == 'debian' }
  only_if { IO.read('/proc/1/comm').strip == 'init' }
 end

cookbook_file '/etc/systemd/system/stunnel4.service' do
  source 'systemd/stunnel4.service'
  mode 0644
  user 'root'
  group 'root'
  not_if { node['platform_family'] == 'debian' }
  only_if { IO.read('/proc/1/comm').strip == 'systemd' }
end

ruby_block 'stunnel.conf notifier' do
  block do
    true
  end
  notifies :create, 'template[/etc/stunnel/stunnel.conf]', :delayed
end

template "/etc/stunnel/stunnel.conf" do
  source "stunnel.conf.erb"
  mode 0644
  action :nothing
  notifies :restart, 'service[stunnel4]', :delayed
end

template "/etc/default/stunnel4" do
  source "stunnel.default.erb"
  mode 0644
end

service "stunnel4" do
  service_name node[:stunnel][:service_name]
  supports :restart => true, :reload => true
  action [ :enable, :start ]
  not_if do
    node[:stunnel][:services].empty?
  end
end

directory 'stunnel_log_dir' do
  path Pathname.new(node['stunnel']['output']).dirname.to_s
  action :create
  only_if { node['stunnel']['output'] }
end

file 'stunnel_log_file' do
  path node['stunnel']['output']
  action :create_if_missing
  user node['stunnel']['user']
  group node['stunnel']['group']
  only_if { node['stunnel']['output'] }
end
