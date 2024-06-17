{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${bucket_name}",
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "${vpce_backend}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${bucket_name}/*",
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "${vpce_backend}"
        }
      }
    },
    {
       "Sid": "AllowSSLRequestsOnly",
       "Action": "s3:*",
       "Effect": "Deny",
       "Resource": [
         "arn:aws:s3:::${bucket_name}",
         "arn:aws:s3:::${bucket_name}/*"
       ],
       "Condition": {
         "Bool": {
           "aws:SecureTransport": "false"
         }
       },
       "Principal": "*"
     }
  ]
}