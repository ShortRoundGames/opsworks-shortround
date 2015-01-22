# Find the attributes for this layer
attribs = "";
if (node[:opsworks])
  node["opsworks"]["instance"]["layers"].each do |layerName|
    if (node[:app][layerName])
      attribs = node[:app][layerName]
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