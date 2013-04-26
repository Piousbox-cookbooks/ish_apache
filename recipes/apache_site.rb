
include_recipe "ish::base_apache"

##
## Below, is covered by default
##
#execute "enable proxy" do
#  command %{ sudo a2enmod proxy }
#end
#
#execute "enable http proxy" do
#  command %{ sudo a2enmod proxy_http }
#end
#
#template "/etc/apache2/ports.conf" do
#  source "ports.conf"
#end
#
#template "/etc/apache2/sites-available/default" do
#  source "sites-available/default"
#end

sites = data_bag_item('utils', 'sites')["sites"]

sites.each do |site|
  app = site

  template "/etc/apache2/sites-available/#{app['id']}" do
    source "site_simple.erb"
    owner "ubuntu"
    group "ubuntu"
    mode "0664"

    variables(
      :server_name => app["domain"],
      :server_names => app["domains"] || [],
      :cloud_ip => (app['ip_address'] || node.ipaddress),
      :cloud_port => app["port"],
      :listen_port => app["listen_port"] || "80"
    )
  end

  execute "enable site" do
    command %{ a2ensite #{app['id']} }
  end
end

