### This recipe sets up mongos daemons on our node app servers ###


# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

# Write config file (NOTE: we should probably put DB on EBS volume for production)
template "/etc/mongos.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 30001,
    "logpath" => "/mnt/mongos.log",
    "chunksize" => 1,
    "configdb" => "ff_prod_mongo_1.shortroundgames.co.uk:20001,ff_prod_mongo_2.shortroundgames.co.uk:20002,ff_prod_mongo_1.shortroundgames.co.uk:20003"
  )
end
