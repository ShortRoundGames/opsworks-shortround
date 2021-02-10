# Find the attributes for this layer
layer_id = ""

instance = search("aws_opsworks_instance", "self:true").first
for lid in instance['layer_ids']
  layer_id = lid
end

attribs = ""
layer_name = ""

search("aws_opsworks_layer").each do |layer|
  name = layer['shortname']
  if (node[:app][name])
    if layer['layer_id'] == layer_id
	  layer_name = name	
      attribs = node[:app][name]
      
    end
  end
end

Chef::Log.info("********** Deleting old builds on layer '#{layer_name}' **********")
Chef::Log.info("********** '#{attribs}' **********")
    
Chef::Application.fatal!("Couldnt find node_app layer", 42) if (attribs == "")

install_path = attribs[:install_path]

# Delete all but 5 most recent builds
bash "delete old builds" do
  user "root"
  cwd "/tmp"

  code <<-EOS
    # Change to builds folder
    cd #{install_path}

	# Find all directory names with the number '1' in it (because the build names are timestamps)
	# -> Remove the last 5 entries from the list
	#    -> Recursively remove the remaining folders
	ls -d *1* | head -n -5 | xargs rm -rf
  EOS
end
