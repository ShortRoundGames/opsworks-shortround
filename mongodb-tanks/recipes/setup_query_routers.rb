### This recipe sets up a Query Router on an app instance, pointing to our single test server ###


# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

# Stop all current mongo daemons
bash "kill mongos" do
  user "root"
  cwd "/"
  code <<-EOS
     /bin/bash -c '/usr/bin/killall -q mongos; exit 0'
  EOS
end

# Write mongos config file
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
    "configdb" => "ec2-52-0-149-196.compute-1.amazonaws.com:20001,ec2-52-0-149-196.compute-1.amazonaws.com:20002,ec2-52-0-149-196.compute-1.amazonaws.com:20003"
  )
end

# Start mongos
bash "start mongos" do
  user "root"
  cwd "/mnt"
  code <<-EOS
	mongos -f /etc/mongos.conf
  EOS
end

# Give mongos time to start
sleep 15

# Setup the Shard Cluster
bash "start mongod" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    mongo --port 30001 --eval 'sh.addShard("tanks1/ec2-52-0-149-196.compute-1.amazonaws.com:27019"); sh.enableSharding("Tanks");'
  EOS
end
