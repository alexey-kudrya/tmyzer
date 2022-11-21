resource "aws_dynamodb_table" "users-dynamodb-table" {
  name           = "TmyzerUsers"
  billing_mode   = var.table_billing_mode
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name    = "tmyzer-users-table"
    Project = "tmyzer"
  }
}

resource "aws_instance" "tmyzer" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.tmyzer.name]
  key_name        = var.key_name

  user_data       = <<-EOF
                   #!/bin/bash
                   python3 -m pip install --upgrade pip
                   python3 -m pip install --upgrade telethon
                   EOF

  iam_instance_profile = aws_iam_instance_profile.tmyzer_ec2_profile.name

  tags = {
    Name        = "tmyzer"
    Project     = "tmyzer"
  }
}

resource "aws_security_group" "tmyzer" {
  name = "tmyzer"

  ingress {
    from_port   = 22
    to_port     = 22
    description = "SSH"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "tmyzer_ec2_role" {
  name = "tmyzer_ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "tmyzer-ec2-dynamodb-policy" {
  name = "tmyzer-ec2-dynamodb-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "${aws_dynamodb_table.users-dynamodb-table.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tmyzer_ec2_dynamodb_attach" {
  role       = aws_iam_role.tmyzer_ec2_role.name
  policy_arn = aws_iam_policy.tmyzer-ec2-dynamodb-policy.arn
}

resource "aws_iam_instance_profile" "tmyzer_ec2_profile" {
  name = "tmazer_ec2_profile"
  role = aws_iam_role.tmyzer_ec2_role.name
}