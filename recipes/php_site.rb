
#
# Recipe ish_apache::php_site
#
# For wiki, wordpress, ...
#

include_recipe "ish_apache::install_apache"
include_recipe "php::default"

site           = data_bag_item('apps', node['apache2']['php_site'])
site['port']   = site['listen_port'][node.chef_environment]

template "/etc/apache2/sites-available/#{site['id']}.conf" do
  source "etc/apache2/sites-available/php_site.conf.erb"
  owner  site['user'][node.chef_environment]
  group  site['user'][node.chef_environment]
  mode   "0664"
  
  variables({
    :server_names   => site['domains'][node.chef_environment],
    :cloud_ip       => nil, # (site['app_ip'] || node.ipaddress),
    :cloud_port     => nil, # site['port'],
    :listen_port    => site['listen_port'][node.chef_environment] || "80",
    :document_root  => site['document_root'][node.chef_environment]
  })
end

execute "open this port" do
  command %{ echo "\nListen #{site['port']}" >> /etc/apache2/ports.conf }
  not_if { ::File.read("/etc/apache2/ports.conf").include?("Listen #{site['port']}") }
  not_if { [ 80, '80' ].include? site['port'] }
end
execute "open this port 2" do
  command %{ echo "\nNameVirtualHost *:#{site['port']}" >> /etc/apache2/ports.conf }
  not_if { ::File.read("/etc/apache2/ports.conf").include?("NameVirtualHost *:#{site['port']}") }
  not_if { [ 80, '80' ].include? site['port'] }
end

apache_site site['id'] do
  enable :true
  notifies :reload, "service[apache2]", :immediately
end



