# Add AWS library, so we can pull files off S3
include_recipe "aws"

# Add the 10gen repo, to get the latest packages
include_recipe "mongodb-tanks::10gen_repo"

# Install Mongo package
package node[:mongodb][:package_name] do
  action :install
  version node[:mongodb][:package_version]
end

##KIMTODO: only do this if there's a mongod running!

# Stop all current mongo daemons
bash "kill mongod" do
  user "root"
  cwd "/"
  code <<-EOS
     /bin/bash -c '/usr/bin/killall -q mongod; exit 0'
  EOS
end


## Setup Static Data server

# create config file
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
    "replicaset_name" => "tanks",
	"smallfiles" => "true"
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

# Pull static data dumps from S3
for filename in ["bytecities.bson", "bytecities.metadata.json", "geocities.bson", "geocities.metadata.json", "geocountries.bson", "geocountries.metadata.json", "georegions.bson", "georegions.metadata.json", "leaderboards.bson", "leaderboards.metadata.json", "revgeodata.bson", "revgeodata.metadata.json", "revgeodatas.bson", "revgeodatas.metadata.json", "system.indexes.bson"]
  aws_s3_file "/tmp/" + filename do
    bucket node[:s3][:static_data_bucket]
    remote_path node[:s3][:static_data_path] + filename
    aws_access_key_id node[:s3][:access_key]
    aws_secret_access_key node[:s3][:secret_key]
    owner "root"
    group "root"
    mode "0644"
  end
end




#KIMTODO
#- download static data from s3
#- import static data into mongod
#- delete temp downloaded data
#- rs.initiate()


# Setup Config Servers
#KIMTODO
#- write 3 config files
#- create 3 dbpaths
#- start 3 mongod's


# Setup UserData shard
#KIMTODO
#- write config file
#- create dbpath
#- start mongod instance
#- rs.initiate()
