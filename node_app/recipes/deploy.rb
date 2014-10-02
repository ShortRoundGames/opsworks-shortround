include_recipe "sk_s3_file"


# Pull tarball from S3
sk_s3_file "/tmp/bi.tar.bz2" do
  remote_path "/elk/bi.tar.bz2"
  bucket "jtw-cdn"
  aws_access_key_id node[:creds][:ec2_access_key]
  aws_secret_access_key node[:creds][:ec2_secret_key]
  owner "root"
  group "root"
  mode "0644"
  action :create
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
  EOS
end
