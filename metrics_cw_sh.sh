#!/bin/bash

#To get the account_id
echo $(aws sts get-caller-identity --query "Account" --output text)

#Variables
account_id=$(aws sts get-caller-identity --query "Account" --output text)
existing_ec2_iam_role=aws-elasticbeanstalk-ec2-role #Name of role that is attached to EC2 instance
cwagent_policy_name=CloudWatchAgentServerPolicy #AWS managed CloudWatch agent server policy
retention_policy_name=CloudWatchAgentRetainPolicy #Any Name for CloudWatch Agent retention policy
retention_policy_path=./policy.json 
cwagent_config_path=/opt/aws/amazon-cloudwatch-agent/bin/config.json

#IAM Policy for CloudWatch agent
cat > $retention_policy_path<<EOL
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:PutRetentionPolicy",
            "Resource": "*"
        }
    ]
}
EOL

#Create Policy for CloudWatch age
aws iam create-policy --policy-name $retention_policy_name --policy-document file://$retention_policy_path

#Attach retention policy to beanstalk role which is attached to EC2 instance
aws iam attach-role-policy --policy-arn arn:aws:iam::$account_id:policy/$retention_policy_name --role-name $existing_ec2_iam_role

#Attch AWS managed CWAgent policy to beanstalk role which is attached to EC2 instance
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/$cwagent_policy_name --role-name $existing_ec2_iam_role

#CloudWatch Agent configuration Script Which sends Memory and Disk usage to CloudWatch Metrics
JSON='{
        "agent": {
                "metrics_collection_interval": 30,
                "run_as_user": "cwagent"
        },
        "metrics": {
                "metrics_collected": {
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ]
                        },
                        "disk": {
                                "measurement": [
                                        "used_percent"
                                ],
                                "resources": [
                                        "*"
                                ]
                        }
                },
                "append_dimensions": {
                        "InstanceId": "${aws:InstanceId}"
                }
        }
}'

sudo touch $cwagent_config_path

sudo chmod 647 $cwagent_config_path

sudo echo '$JSON' > $cwagent_config_path

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start