--stack settings--
"app": {
	"game_server": {
		"s3_bucket": "sr-deployment",
		"s3_path": "/rivalgears/rivalgears.tar.bz2",            
		"pill": "rivalgears.pill",
		"install_path" : "/mnt/rivalgears",
		"app_name" : "rivalgears"
	},
	"staging_server": {
		"s3_bucket": "sr-deployment",
		"s3_path": "/rivalgears/rivalgears_staging.tar.bz2",            
		"pill": "rivalgears.pill",
		"install_path" : "/mnt/rivalgears",
		"app_name" : "rivalgears"
	},
	"chat_server": {
		"s3_bucket": "sr-deployment",
		"s3_path": "/rivalgears/rivalgears.tar.bz2",            
		"pm2": "chat.json",
		"install_path" : "/mnt/chat",
		"app_name" : "chat"
	}
},


log_path - defaults to <install_path>/logs. So in the above example "/mnt/rivalgears/logs".

The server can be managed by either bluepill or pm2.
If the stack settings contains a 'pill' filename it will use bluepill.
If the stack settings contains a 'pm2' file name it will use pm2.
If it contains neither, it will fall on it's arse.

//----------Bluepill------------------

pill     - must live in the install_path.

to update ruby, use the update_ruby recipe. 

--update_ruby stack settings--
"ruby": {
	"version" : "2.6.3"
},

//----------PM2------------------
pm2 config file must live in the install path