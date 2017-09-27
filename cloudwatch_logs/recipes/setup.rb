#create the config file
layers = []

search("aws_opsworks_layer").each do |layer|  
  layer_name = layer['shortname']  
  layers.push(layer_name)
end

#stack = search("aws_opsworks_stack").first 
#log_group_name = stack[:name].gsub(' ', '_')

template "/tmp/cwlogs.cfg" do
  cookbook "cloudwatch_logs"
  source "cwlogs.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
	:layers => layers
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
  command "python3 /opt/aws/cloudwatch/awslogs-agent-setup.py -n -r us-east-1 -c /tmp/cwlogs.cfg"
  not_if { system "pgrep -f aws-logs-agent-setup" }
end

