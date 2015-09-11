### This recipe sets up mongo components on the primary shard server ###


# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

# Write config file for Primary Shard
template "/etc/mongo_shard.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 27019,
    "logpath" => "/mnt/mongo_shard.log",
    "dbpath" => "/ebs/mongo_shard",
    "replicaset_name" => "tanks1"
  )
end

# dbpath dir for Primary Shard [make sure it exists]
directory "/ebs/mongo_shard" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Write config file for Static Arb
template "/etc/mongo_static_arb.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 27018,
    "logpath" => "/mnt/mongo_static_arb.log",
    "dbpath" => "/mnt/mongo_static_arb",
    "replicaset_name" => "tanks",
    "nojournal" => "true",
    "smallfiles" => "true"
  )
end

# dbpath dir for Static Arb [make sure it exists]
directory "/mnt/mongo_static_arb" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end
