include_recipe "aws"


# Pull tarball from S3
aws_s3_file "/tmp/bi.tar.bz2" do
  bucket "jtw-cdn"
  remote_path "/elk/bi.tar.bz2"
  aws_access_key_id node[:s3][:access_key]
  aws_secret_access_key node[:s3][:secret_key]
  owner "root"
  group "root"
  mode "0644"
end


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
    mkdir -p /mnt/server/#{new_folder}/logs

    # Update link to current logs
    ln -snf /mnt/server/#{new_folder}/logs /mnt/logs

	# Make bluepill script executable
    chmod 0755 bluepill
  EOS
end
