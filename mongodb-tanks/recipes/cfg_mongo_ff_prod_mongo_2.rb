### This recipe sets up mongo components on the secondary static server ###


# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

# Write config file for Static Data Server (secondary)
template "/etc/mongo_static.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 27017,
    "logpath" => "/mnt/mongo_static.log",
    "dbpath" => "/mnt/mongo_static",
    "replicaset_name" => "tanks"
  )
end

# dbpath dir for static server [make sure it exists]
directory "/mnt/mongo_static" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Write config file for Config Server 2
template "/etc/mongo_confsvr_2.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 20002,
    "logpath" => "/mnt/mongo_confsvr_2.log",
    "dbpath" => "/mnt/mongo_confsvr_2",
    "configsvr" => "true"
  )
end

# dbpath dir for Config Server 2 [make sure it exists]
directory "/mnt/mongo_confsvr_2" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Write config file for Shard Arb
template "/etc/mongo_shard_arb.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 27020,
    "logpath" => "/mnt/mongo_shard_arb.log",
    "dbpath" => "/mnt/mongo_shard_arb",
    "replicaset_name" => "tanks1",
    "nojournal" => "true",
    "smallfiles" => "true"
  )
end

# dbpath dir for Shard Arb [make sure it exists]
directory "/mnt/mongo_shard_arb" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end
