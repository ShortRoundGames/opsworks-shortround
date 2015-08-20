# Add the 10gen repo, to get the latest packages
include_recipe "10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end
