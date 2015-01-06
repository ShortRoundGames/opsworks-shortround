# Create script that pushes custom metrics into Cloudwatch
# 
template "/usr/local/bin/cloudwatch-custom.sh" do
  source "cloudwatch-custom.sh.erb"
  mode "0550"
  owner "root"
  group "root"
end

# Cron it so that it runs every 5 minutes
#
cron "cloudwatch-custom" do
  hour "*"
  minute "*/5"
  weekday "*"
  command "/usr/local/bin/cloudwatch-custom.sh"
end
