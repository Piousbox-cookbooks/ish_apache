
#
# Cookbook   ish_apache
# Recipe     balanced_site_angular
#

include_recipe "apache2::default"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_rewrite"

site                  = data_bag_item('load_balancers', 'default_balanced_site')
site['name']          = node['balanced_site']['name']        || site['name']
site['user']          = node['balanced_site']['user']        || site['user']
site['domains']       = node['balanced_site']['domains']     || site['domains']
site['listen_port']   = node['balanced_site']['listen_port'] || site['listen_port']

template "/etc/apache2/sites-available/#{site['name']}.conf" do
  source "etc/apache2/sites-available/balanced_site.conf.erb"
  owner site['user']
  group site['user']
  mode "0664"
  variables(
    :server_names => site['domains'],
    :cloud_ip => node.ipaddress,
    :listen_port => site['listen_port']
  )
end

## you precisely don't need this!
##
#execute "open this port" do
#  command %{ echo "\nListen #{site['port']}" >> /etc/apache2/ports.conf }
#  not_if { ::File.read("/etc/apache2/ports.conf").include?("Listen #{site['port']}") }
#end
#execute "open this port 2" do
#  command %{ echo "\nNameVirtualHost *:#{site['port']}" >> /etc/apache2/ports.conf }
#  not_if { ::File.read("/etc/apache2/ports.conf").include?("NameVirtualHost *:#{site['port']}") }
#end

apache_site site['name']

service 'apache2' do
  action :reload
end

