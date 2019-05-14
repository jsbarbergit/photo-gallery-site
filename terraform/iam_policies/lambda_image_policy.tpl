{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
       {
          "Effect": "Allow",
          "Action": [
             "s3:GetObject",
             "s3:PutObject",
             "s3:PutObjectAcl"
          ],
          "Resource": [
             "arn:aws:s3:::jess-photo-albums/*",
             "arn:aws:s3:::jess-photo-albums"
          ]
       }
    ]
 }