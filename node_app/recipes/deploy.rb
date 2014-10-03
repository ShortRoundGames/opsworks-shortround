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

	# Create bluepill script to run the server
    cd /mnt/server/current
	echo "#!/usr/local/bin/ruby" > bluepill
    echo "" >> bluepill
    echo "require 'rubygems'" >> bluepill
    echo "" >> bluepill
    echo "version = \">= 0\"" >> bluepill
    echo "" >> bluepill
    echo "if ARGV.first" >> bluepill
    echo "  str = ARGV.first" >> bluepill
    echo "  str = str.dup.force_encoding(\"BINARY\") if str.respond_to? :force_encoding" >> bluepill
    echo "  if str =~ /\A_(.*)_\z/ and Gem::Version.correct?($1) then" >> bluepill
    echo "    version = $1" >> bluepill
    echo "    ARGV.shift" >> bluepill
    echo "  end" >> bluepill
    echo "end" >> bluepill
    chmod 0755 bluepill
  EOS
end
