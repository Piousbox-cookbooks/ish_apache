
#
# recipe ish_apache::install_apache
#
# OBSOLETE! use apache2::default, apache2::mod_*
# _vp_ 20151226
#

execute 'install stuff' do
  command %{ apt-get install apache2 libapache2-mod-proxy-html libxml2-dev -y }
end

execute "enable proxy" do
  command %{ sudo a2enmod proxy }
end

execute "enable http proxy" do
  command %{ sudo a2enmod proxy_http }
end

execute "enable balancer" do
  command %{
sudo a2enmod proxy_balancer &&
sudo a2enmod rewrite &&
sudo a2enmod ssl &&
sudo a2enmod headers
  }
end

## Not needed, right?
##
# template "/etc/apache2/ports.conf" do
#   source "etc/apache2/ports.conf.erb"
# end

# node.run_list.remove("recipe[ish_apache::install_apache]")

