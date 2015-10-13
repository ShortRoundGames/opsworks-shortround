### This recipe sets up mongo components on the primary static server ###


# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

# Write config file for Static Data Server (primary)
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

# Write config file for Config Server 1
template "/etc/mongo_confsvr_1.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 20001,
    "logpath" => "/mnt/mongo_confsvr_1.log",
    "dbpath" => "/mnt/mongo_confsvr_1",
    "configsvr" => "true"
  )
end

# dbpath dir for Config Server 1 [make sure it exists]
directory "/mnt/mongo_confsvr_1" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Write config file for Config Server 3
template "/etc/mongo_confsvr_3.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 20003,
    "logpath" => "/mnt/mongo_confsvr_3.log",
    "dbpath" => "/mnt/mongo_confsvr_3",
    "configsvr" => "true"
  )
end

# dbpath dir for Config Server 3 [make sure it exists]
directory "/mnt/mongo_confsvr_3" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Stop all current mongo daemons (we'll run them manually in the right order)
bash "kill mongod" do
  user "root"
  cwd "/"
  code <<-EOS
     /bin/bash -c '/usr/bin/killall -q mongod; exit 0'
  EOS
end
