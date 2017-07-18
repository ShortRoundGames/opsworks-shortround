
# Update ruby
ruby_version = "";
if (node[:ruby])
	if (node[:ruby][:version])
      ruby_version = node[:ruby][:version]	
	end
end

bash "update ruby" do
  user "root"
  cwd "/tmp"

  code <<-EOS
	gem update --system #{ruby_version}
  EOS
end
