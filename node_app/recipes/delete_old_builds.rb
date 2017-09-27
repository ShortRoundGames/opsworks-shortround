# Find the attributes for this layer
attribs = "";

search("aws_opsworks_layer").each do |layer|  
  layer_name = layer['shortname']  
  attribs = node[:app][layer_name]
  
  if (node[:app][layer_name])
    attribs = node[:app][layer_name]
  end  
end
    
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
