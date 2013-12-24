
#
# recipe ish_apache::install_apache
#

include_recipe "ish_apache::base_apache"

execute 'install stuff' do
  command %{ apt-get install libapache2-mod-proxy-html libxml2-dev -y }
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

template "/etc/apache2/ports.conf" do
  source "ports.conf"
end

node.run_list.remove("recipe[ish_apache::install_apache]")

