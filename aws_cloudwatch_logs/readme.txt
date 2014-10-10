--- custom json ---
List log files to be sent to cloudwatch

cloudwatch_logs : 
{
	<layer_name> : {
		<stream_name> : <file_path>,
		...
	}
}

--- Follow the guide for adding the IAM role ---
http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/QuickStartChef.html