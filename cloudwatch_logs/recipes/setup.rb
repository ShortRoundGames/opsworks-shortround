package 'python2.7' do
  action :install
end

#create the config file
layer_ids = []

instance = search("aws_opsworks_instance", "self:true").first
for lid in instance['layer_ids']
  layer_ids.push(lid)
end

layers = []

search("aws_opsworks_layer").each do |layer|  
  layer_id = layer['layer_id']  
  if layer_ids.include?(layer_id)
    layer_name = layer['shortname']  
    layers.push(layer_name)
  end
end

stack = search("aws_opsworks_stack").first
log_group_name = stack[:name].gsub(' ', '_')

Chef::Log.info("********** The stack's name is '#{log_group_name}' **********")

template "/tmp/cwlogs.cfg" do
  cookbook "cloudwatch_logs"
  source "cwlogs.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
	:layers => layers,	
	:log_group_name => log_group_name	
  })
end

#set things going
directory "/opt/aws/cloudwatch" do
  recursive true
end

remote_file "/opt/aws/cloudwatch/awslogs-agent-setup.py" do
  source "https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py"
  mode "0755"
end

execute "Install CloudWatch Logs agent" do
  command "python2.7 /opt/aws/cloudwatch/awslogs-agent-setup.py -n -r us-east-1 -c /tmp/cwlogs.cfg"
  not_if { system "pgrep -f aws-logs-agent-setup" }
end

