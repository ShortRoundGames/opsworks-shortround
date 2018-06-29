# Find the attributes for this layer
attribs = ""
layer_name = ""

search("aws_opsworks_layer").each do |layer|  
  layer_name = layer['shortname']  
  attribs = node[:app][layer_name]
  
  if (node[:app][layer_name])
    attribs = node[:app][layer_name]
  end  
end

install_path = attribs[:install_path] + "/current"

# Create opsworks.js
redis_servers = [];
if (node[:redisio])
	redis_servers = node[:redisio][:servers]
end

template "#{install_path}/opsworks.js" do
	source 'opsworks.js.erb'
	mode '0660'
	user 'root'
	group 'root'
	variables(:layer_name => layer_name)
end


# Switch pill name based on the instance's layer
pillName = attribs[:pill];

app_name = attribs[:app_name];
if (!app_name)
	app_name = ""
end
  
# Determine if server is running
status_command = "bluepill " + app_name + " status"
shell = Mixlib::ShellOut.new("#{status_command} 2>&1")
shell.run_command

if shell.exitstatus == 0  
  # Bluepill is running, so we need to restart it
  bash "restart bluepill" do
    user "root"
    cwd "/tmp"
    code <<-EOS
      bluepill #{app_name} restart
    EOS
  end

else

  # Bluepill is not running, so start server running now through bluepill
  bash "start bluepill" do
    user "root"
    cwd "/tmp"
    code <<-EOS
      bluepill load #{install_path}/#{pillName}
    EOS
  end

end
