--stack settings--
"app": {
	"game_server": {
		"s3_bucket": "sr-deployment",
		"s3_path": "/tanks/tanks.tar.bz2",            
		"pill": "tanks.pill",
		"install_path" : "/mnt/tanks",
		"app_name" : "tanks"
	},
	"staging_server": {
		"s3_bucket": "sr-deployment",
		"s3_path": "/tanks/tanks_staging.tar.bz2",            
		"pill": "tanks.pill",
		"install_path" : "/mnt/tanks",
		"app_name" : "tanks"
	},
	"chat_server": {
		"s3_bucket": "sr-deployment",
		"s3_path": "/tanks/tanks.tar.bz2",            
		"pill": "chat.pill",
		"install_path" : "/mnt/chat",
		"app_name" : "chat"
	}
},

pill     - must live in the install_path.
log_path - defaults to <install_path>/logs. So in the above example "/mnt/rivalgears/logs".

to update ruby, use the update_ruby recipe. 

--update_ruby stack settings--
"ruby": {
	"version" : "2.6.3"
},