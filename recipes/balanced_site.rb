
#
# Recipe ish_apache::balanced_site
#
# Sends traffic between a load balancer and a virtual site via proxy.
#

include_recipe "ish_apache::install_apache"

site = data_bag_item('load_balancers', 'default_balanced_site')
site['name']     = node['balanced_site']['name']
site['user']     = node['balanced_site']['user'] || site['user']
site['domains']  = node['balanced_site']['domains'] || site['domains']
site['port']     = node['balanced_site']['port']
site['app_ip']   = node['balanced_site']['app_ip']

template "/etc/apache2/sites-available/#{site['name']}.conf" do
  source "etc/apache2/sites-available/balanced_site.conf.erb"
  owner site['user']
  group site['user']
  mode "0664"
  
  variables(
    :server_names => site['domains'],
    :cloud_ip => (site['app_ip'] || node.ipaddress),
    :cloud_port => site['port'],
    :listen_port => site['listen_port'] || "80"
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

apache_site site['name'] do
  enable :true
  notifies :reload, "service[apache2]", :immediately
end



