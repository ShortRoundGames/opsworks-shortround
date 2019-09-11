include_recipe "aws"

layer_id = ""

instance = search("aws_opsworks_instance", "self:true").first
for lid in instance['layer_ids']
  layer_id = lid
end

attribs = ""

search("aws_opsworks_layer").each do |layer|
  layer_name = layer['shortname']
  if (node[:app][layer_name])
    if layer['layer_id'] == layer_id
      attribs = node[:app][layer_name]
      Chef::Log.info("********** '#{attribs}' **********")
    end
  end
end

# Install GCC 5.x (required to build some Node modules under Node 6)
bash "install gcc 5.x" do
  user "root"
  cwd "/tmp"

  code <<-EOS
    add-apt-repository -y ppa:ubuntu-toolchain-r/test
    apt-get update
    apt-get -y install gcc-5 g++-5
    rm /usr/bin/g++
    ln -s /usr/bin/g++-5 /usr/bin/g++
  EOS
end

# Install node
include_recipe "nodejs"

# Use bluepill or pm2?
if attribs[:pill]

	Chef::Log.info("********** 'Deploy Using Bluepill' **********")
	
	# DEPRECATED: install npm and forever package
	# include_recipe "nodejs::npm"
	# nodejs_npm "forever"

	package 'ruby2.3' do
	  action :install
	end

	gem_package "activesupport" do
	  version "4.2.1"
	  action :install
	end

	gem_package "bluepill" do
	  version "0.1.1"
	  action :install
	end
else
	Chef::Log.info("********** 'Deploy Using PM2' **********")
	
	bash "install pm2" do
	  user "root"
	  cwd "/tmp"

	  code <<-EOS
		npm install -g pm2
	  EOS
	end
	
end

