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
  bucket attribs[:s3_bucket]
  remote_path attribs[:s3_path]
  aws_access_key_id node[:s3][:access_key]
  aws_secret_access_key node[:s3][:secret_key]
  owner "root"
  group "root"
  mode "0644"
end

new_folder = Time.now.to_i;
install_path = attribs[:install_path]

log_path = attribs[:log_path]
if (!log_path)
    log_path = install_path + "/logs"
end

# Extract tarball
bash "extract code.tar.bz2" do
  user "root"
  cwd "/tmp"

  code <<-EOS
    # Extract BI folder from tar
    tar -xjvf code.tar.bz2

    # Grant RW permissions to the node_modules dir for all users
    chmod -R a+rw www/node_modules

    # Rename BI folder to new name
    mv www #{new_folder}

    # Rebuild NPM
    cd #{new_folder}
    npm rebuild

    # Ensure server dir exist
    mkdir -p #{install_path}

    # Move into the install directory
    cd /tmp
    mv #{new_folder} #{install_path}

    # Update current symlink
    ln -snf #{install_path}/#{new_folder} #{install_path}/current 

    # Ensure logs dir exist
    mkdir -p #{log_path}

    # Delete the current logs folder from the apps directory
    rm -rf #{install_path}/#{new_folder}/logs

    # Update link to current logs
    ln -snf #{log_path} #{install_path}/#{new_folder}/logs 

    # Fixup screwed version of bluepill on the instance
    #chmod 0755 #{install_path}/current/bluepill.rb
    #mv #{install_path}/current/bluepill.rb /usr/local/lib/ruby/gems/2.0.0/gems/bluepill-0.0.68/lib/bluepill.rb
  EOS
end
