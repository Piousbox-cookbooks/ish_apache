
#
# Author: victor pudeyev <admin@piousbox.com>
# Copyright wasya.co 2013
# GPLv2 license
# This note is 20131224
#
# This is only the lb for a static site! The static site app is ish::static_site
# 
#

include_recipe "ish_apache::base_apache"

app = data_bag_item('apps', node[:apache2][:app_server_role])

template "/etc/apache2/sites-available/#{app['id']}" do
  source "sites-available/static_site.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0664"
  
  variables(
            :deploy_to => app['deploy_to'],
            :appserver_port => app["appserver_port"]
            )
end

execute "enable site" do
  command %{ a2ensite #{app['id']} }
end

