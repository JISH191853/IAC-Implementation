import pulumi
import pulumi_aws as aws

# Security Group
app_sg = aws.ec2.SecurityGroup(
    "app_server_sg",
    ingress=[
        {"protocol": "tcp", "from_port": 80, "to_port": 80, "cidr_blocks": ["0.0.0.0/0"]},
        {"protocol": "tcp", "from_port": 22, "to_port": 22, "cidr_blocks": ["0.0.0.0/0"]},
    ],
    egress=[
        {"protocol": "-1", "from_port": 0, "to_port": 0, "cidr_blocks": ["0.0.0.0/0"]},
    ],
)

# EC2 Instance
app_server = aws.ec2.Instance(
    "app_server",
    instance_type="t2.micro",
    ami="ami-0c55b159cbfafe1f0",  # Replace with your preferred AMI ID
    security_groups=[app_sg.name],
    tags={"Name": "AppServer"},
)

# S3 Bucket
static_assets = aws.s3.Bucket(
    "static_assets_bucket",
    acl="public-read",
)

s3_bucket_policy = aws.s3.BucketPolicy(
    "static_assets_policy",
    bucket=static_assets.id,
    policy=static_assets.id.apply(
        lambda bucket_id: f"""
        {{
            "Version": "2012-10-17",
            "Statement": [
                {{
                    "Sid": "PublicReadGetObject",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::{bucket_id}/*"
                }}
            ]
        }}
        """
    ),
)
