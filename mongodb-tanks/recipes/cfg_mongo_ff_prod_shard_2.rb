### This recipe sets up mongo components on the secondary shard server ###


# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

# Write config file for Secondary Shard
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

# dbpath dir for Secondary Shard [make sure it exists]
directory "/ebs/mongo_shard" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end
