resource "aws_iam_role" "k8s_ec2_role" {
    name = "k8s_ec2_role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = {
                    Service = "ec2.amazonaws.com"
                }

            }
        ]
    })
}

resource "aws_iam_policy" "k8s_policy" {
         name = "k8s_policy"
         policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action = [
                        "ec2:*",
                        "ssm:*",
                        "s3:*",
                        "logs:*"
                        "iam:*"
                    ]
                    Effect = "Allow"
                    Resource = "*"
                },
            ]
         })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
         role = aws_iam_role.k8s_ec2_role.name
         policy_arn = aws_iam_policy.k8s_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
         role = aws_iam_role.k8s_ec2_role.name
         policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
         name = "ec2_profile"
         role = aws_iam_role.k8s_ec2_role.name
}