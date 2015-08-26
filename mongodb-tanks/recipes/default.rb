### This recipe sets up all required mongo servers on a single test server ###


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
bash "kill mongod" do
  user "root"
  cwd "/"
  code <<-EOS
     /bin/bash -c '/usr/bin/killall -q mongod; exit 0'
  EOS
end


## Setup Static Data server

# Write config file
template "/etc/mongo_static_1.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 27017,
    "logpath" => "/mnt/mongo_static_1.log",
    "dbpath" => "/mnt/mongo_static_1",
    "replicaset_name" => "tanks"
  )
end

# dbpath dir [make sure it exists]
directory "/mnt/mongo_static_1" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Start the mongo daemon
bash "start mongod" do
  user "root"
  cwd "/mnt"
  code <<-EOS
	mongod -f /etc/mongo_static_1.conf
  EOS
end


## Import Static Data into Mongo

# Temp data dir [make sure it exists]
directory "/tmp/GeoLiteCity" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Pull static data dumps from S3
for filename in ["bytecities.bson", "bytecities.metadata.json", "geocities.bson", "geocities.metadata.json", "geocountries.bson", "geocountries.metadata.json", "georegions.bson", "georegions.metadata.json", "leaderboards.bson", "leaderboards.metadata.json", "revgeodata.bson", "revgeodata.metadata.json", "revgeodatas.bson", "revgeodatas.metadata.json", "system.indexes.bson"]
  aws_s3_file "/tmp/GeoLiteCity/" + filename do
    bucket node[:s3][:static_data_bucket]
    remote_path node[:s3][:static_data_path] + filename
    aws_access_key_id node[:s3][:access_key]
    aws_secret_access_key node[:s3][:secret_key]
    owner "root"
    group "root"
    mode "0644"
  end
end

# Initiate the Replica Set
bash "start mongod" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    mongo --port 27017 --eval 'rs.initiate(); rs.add("ec2-52-0-149-196.compute-1.amazonaws.com:27017"); while (rs.status().startupStatus || (rs.status().hasOwnProperty("myState") && rs.status().myState != 1)) { printjson(rs.status()); sleep(1000); }; printjson(rs.status());'
  EOS
end

# Import data dumps
bash "import data" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    mongorestore -drop --db GeoLiteCity /tmp/GeoLiteCity
  EOS
end

# Remove temporary dir
bash "delete dumps" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    rm -rf /tmp/GeoLiteCity
  EOS
end


## Setup Config Servers

# Create config file 1
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

# Create config file 2
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

# Create config file 3
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

# dbpath dir 1 [make sure it exists]
directory "/mnt/mongo_confsvr_1" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# dbpath dir 2 [make sure it exists]
directory "/mnt/mongo_confsvr_2" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# dbpath dir 3 [make sure it exists]
directory "/mnt/mongo_confsvr_3" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Start daemons
bash "start confsvr mongod's" do
  user "root"
  cwd "/mnt"
  code <<-EOS
	mongod -f /etc/mongo_confsvr_1.conf
	mongod -f /etc/mongo_confsvr_2.conf
	mongod -f /etc/mongo_confsvr_3.conf
  EOS
end


## Setup UserData shard

# Write config file (NOTE: we should probably put DB on EBS volume for production)
template "/etc/mongo_shard_1.conf" do
  action :create
  cookbook node['mongodb']['template_cookbook']
  source "mongo.conf.erb"
  group node['mongodb']['root_group']
  owner "root"
  mode "0644"
  variables(
    "port" => 27019,
    "logpath" => "/mnt/mongo_shard_1.log",
    "dbpath" => "/mnt/mongo_shard_1",
    "replicaset_name" => "tanks1"
  )
end

# dbpath dir [make sure it exists]
directory "/mnt/mongo_shard_1" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Start the mongo daemon
bash "start mongod" do
  user "root"
  cwd "/mnt"
  code <<-EOS
	mongod -f /etc/mongo_shard_1.conf
  EOS
end

sleep 15

# Initiate the Replica Set
bash "start mongod" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    mongo --port 27019 --eval 'rs.initiate(); rs.add("ec2-52-0-149-196.compute-1.amazonaws.com:27019"); while (rs.status().startupStatus || (rs.status().hasOwnProperty("myState") && rs.status().myState != 1)) { printjson(rs.status()); sleep(1000); }; printjson(rs.status());'
  EOS
end


## Import User Data (bots) into mongo

# Temp data dir [make sure it exists]
directory "/tmp/Tanks" do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
  recursive true
end

# Pull user data dumps from S3
for filename in ["playerdatas.bson", "playerdatas.metadata.json"]
  aws_s3_file "/tmp/Tanks/" + filename do
    bucket node[:s3][:user_data_bucket]
    remote_path node[:s3][:user_data_path] + filename
    aws_access_key_id node[:s3][:access_key]
    aws_secret_access_key node[:s3][:secret_key]
    owner "root"
    group "root"
    mode "0644"
  end
end

# Import data dumps
bash "import user data" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    mongorestore --db Tanks /tmp/Tanks --host localhost --port 27019
  EOS
end

# Remove temporary dir
bash "delete dumps" do
  user "root"
  cwd "/mnt"
  code <<-EOS
    rm -rf /tmp/Tanks
  EOS
end
