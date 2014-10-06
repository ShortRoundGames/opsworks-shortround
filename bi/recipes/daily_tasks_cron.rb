cron "daily_bi_tasks" do
	minute "10" 
	hour "*" 
	month "*"
	weekday "*"
	command "node /mnt/server/current/snapshots/dailyTasks >> /tmp/cron.log 2>&1"
end