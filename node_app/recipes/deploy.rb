include_recipe "aws"

# Find the attributes for this layer
attribs = "";
if (node[:opsworks])
  node["opsworks"]["instance"]["layers"].each do |layerName|
    if (node[:app][layerName])
      attribs = node[:app][layerName]
	end
  end
end
    
Chef::Application.fatal!("Couldnt find node_app layer", 42) if (attribs == "")

# Pull tarball from S3
aws_s3_file "/tmp/code.tar.bz2" do
  bucket "jtw-cdn"
  remote_path attribs[:s3_path]
  aws_access_key_id node[:s3][:access_key]
  aws_secret_access_key node[:s3][:secret_key]
  owner "root"
  group "root"
  mode "0644"
end

return

new_folder = Time.now.to_i;

# Extract tarball
bash "extract bi.tar.bz2" do
  user "root"
  cwd "/tmp"

  code <<-EOS
    # Extract BI folder from tar
    tar -xjvf bi.tar.bz2

    # Rename BI folder to new name
    mv www #{new_folder}

    # Rebuild NPM
    cd #{new_folder}
    npm rebuild

    # Ensure server dir exist
    mkdir -p /mnt/server

    # Move into mnt
    cd /tmp
    mv #{new_folder} /mnt/server

    # Update current symlink
    ln -snf /mnt/server/#{new_folder} /mnt/server/current 

    # Ensure logs dir exist
    mkdir -p /mnt/logs

    # Update link to current logs
    ln -snf /mnt/logs /mnt/server/#{new_folder}/logs 

	# Fixup screwed version of bluepill on the instance
    chmod 0755 /mnt/server/current/bluepill.rb
    mv /mnt/server/current/bluepill.rb /usr/local/lib/ruby/gems/2.0.0/gems/bluepill-0.0.68/lib/bluepill.rb
  EOS
end
