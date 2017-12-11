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

log "That's all folks!"