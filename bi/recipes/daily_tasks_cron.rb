cron "daily_bi_tasks" do
	minute "30" 
	hour "5" 
	command "/usr/local/bin/node /mnt/server/current/snapshots/dailyTasks >> /tmp/cron.log 2>&1"
end

cron "daily_retention" do
	minute "0" 
	hour "1" 
	command "/usr/local/bin/node /mnt/server/current/retention/calculateRetention >> /tmp/cron.log 2>&1"
end
