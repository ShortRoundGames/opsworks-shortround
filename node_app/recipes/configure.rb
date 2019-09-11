# Find the attributes for this layer
attribs = ""
layer_name = ""

search("aws_opsworks_layer").each do |layer|  
  layer_name = layer['shortname']  
  
  Chef::Log.info("********** found '#{layer_name}' **********")
  
  if (node[:app][layer_name])
	Chef::Log.info("********** using '#{layer_name}' **********")
    attribs = node[:app][layer_name]
  end  
end

instance = search("aws_opsworks_instance", "self:true").first
public_ip = instance['public_ip']
public_dns = instance['public_dns']

# Chef::Log.info("********** For instance '#{instance['instance_id']}', the instance's ip is '#{instance['public_ip']}' **********")

Chef::Application.fatal!("Couldnt find layer attribs " << layer_name, 42) if (!attribs || attribs == "")

install_path = attribs[:install_path] + "/current"

# Create opsworks.js
#redis_servers = [];
#if (node[:redisio])
#	redis_servers = node[:redisio][:servers]
#end

template "#{install_path}/opsworks.js" do
	source 'opsworks.js.erb'
	mode '0660'
	user 'root'
	group 'root'
	variables(:layer_name => layer_name, :public_ip => public_ip, :public_dns => public_dns)
end

# The server can be managed by either bluepill or pm2.
# If the stack settings contains a 'pill' filename it will use bluepill.
# If the stack settings contains a 'pm2' file name it will use pm2.
# If it contains neither, it will fall on it's arse.

if attribs[:pill]
	Chef::Log.info("********** using Bluepill **********")
	
	# Switch pill name based on the instance's layer
	pill_name = attribs[:pill];

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
		  bluepill load #{install_path}/#{pill_name}
		EOS
	  end

	end
else
	Chef::Log.info("********** using PM2 **********")



end


