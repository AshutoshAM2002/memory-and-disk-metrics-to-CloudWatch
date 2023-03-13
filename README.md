# memory-and-disk-metrics-to-CloudWatch
Shell script send memory and disk metrics from my Amazon Elastic Compute Cloud (Amazon EC2) instances to Amazon CloudWatch Metrics.

EC2 delivers a set of metrics related to your instance to CloudWatch in the AWS/EC2 namespace. This includes CPUUtilization, a set of disk Read and Write metrics, and a set of NetworkIn and NetworkOut metrics. But, EC2 doesn't provide metrics related to OS-level memory usage or disk usage metrics.

Run the above script to do that.




