{
    "Command": {
        "CommandId": "28be1dbc-ae11-4387-a38b-76c9f28f416c",
        "DocumentName": "AWS-RunShellScript",
        "DocumentVersion": "$DEFAULT",
        "Comment": "",
        "ExpiresAfter": "2026-01-20T22:12:44.679000+05:30",
        "Parameters": {
            "commands": [
                "docker pull 098412623305.dkr.ecr.us-east-1.amazonaws.com/fastapi-docker-calculator:latest",
                "docker stop app || true",
                "docker rm app || true",
                "docker run -d --restart unless-stopped --name app -p 8000:8000 098412623305.dkr.ecr.us-east-1.amazonaws.com/fastapi-docker-calculator:latest"
            ]
        },
        "InstanceIds": [],
        "Targets": [
            {
                "Key": "tag:Name",
                "Values": [
                    "fastapi-ec2-runtime-ec2"
                ]
            }
        ],
        "RequestedDateTime": "2026-01-20T20:12:44.679000+05:30",
        "Status": "Pending",
        "StatusDetails": "Pending",
        "OutputS3Region": "us-east-1",
        "OutputS3BucketName": "",
        "OutputS3KeyPrefix": "",
        "MaxConcurrency": "50",
        "MaxErrors": "0",
        "TargetCount": 0,
        "CompletedCount": 0,
        "ErrorCount": 0,
        "DeliveryTimedOutCount": 0,
        "ServiceRole": "",
        "NotificationConfig": {
            "NotificationArn": "",
            "NotificationEvents": [],
            "NotificationType": ""
        },
        "CloudWatchOutputConfig": {
            "CloudWatchLogGroupName": "",
            "CloudWatchOutputEnabled": false
        },
        "TimeoutSeconds": 3600,
        "AlarmConfiguration": {
            "IgnorePollAlarmFailure": false,
            "Alarms": []
        },
        "TriggeredAlarms": []
    }
}
