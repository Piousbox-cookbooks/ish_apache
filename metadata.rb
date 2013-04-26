maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures ish_apache"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w{ ish }.each do |cb|
  depends cb
end

# 0.1.0 - Working on deploying a python app as a virtual host.
