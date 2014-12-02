include_recipe "git"

# Find the attributes for this layer
attribs = "";
if (node[:opsworks])
  node["opsworks"]["instance"]["layers"].each do |layerName|
    if (node[:git_deploy][layerName])
      attribs = node[:git_deploy][layerName]
	end
  end
end

# get the data from the layers attributes
repo = attribs[:repo];
dest = attribs[:dest];

git "#{dest}" do
  repository "#{repo}"
  reference "master"
  if Dir.exist? "#{dest}"
    action :sync
  else
	action :checkout    
  end
  user root
end
