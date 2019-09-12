# Find the attributes for this layer
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
if attribs[:pill]
	Chef::Log.info("********** 'Shutdown Using Bluepill' **********")
	
	# Find the app name
	app_name = attribs[:app_name];
	if (!app_name)
		app_name = ""
	end

	# Send the stop to the pill 
	bash "stop bluepill" do
		user "root"
		cwd "/tmp"
		code <<-EOS
		  bluepill #{app_name} stop
		EOS
	end
else
	Chef::Log.info("********** 'Shutdown Using PM2' **********")

	# Send the stop to the pill 
	bash "stop pm2" do
		user "root"
		cwd "/tmp"
		code <<-EOS
		  pm2 stop all
		EOS
	end

end

log "That's all folks!"