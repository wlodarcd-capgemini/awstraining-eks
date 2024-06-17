[
  {
    "name": "${name}",
    "image": "${image}",
    "memoryReservation": 512,
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "command": ["-r", "${load_test_result_bucket_name}"],
    "environment": [
        {
          "name": "loadUrl",
          "value": "${load_test_url}"
        },
        {
          "name": "loadDurationRampUpSeconds",
          "value": "1200"
        },
        {
          "name": "loadDurationSeconds",
          "value": "3600"
        },
        {
          "name": "loadProxyHost",
          "value": ""
        },
        {
          "name": "loadProxyPort",
          "value": ""
        },
        {
          "name": "loadProxyUser",
          "value": ""
        },
        {
          "name": "loadProxyPassword",
          "value": ""
        },
        {
          "name": "loadbackendHappyPathTestPerSecond",
          "value": "1"
        },
        {
          "name": "loadbackendReplayAfterOneSecondTestPerSecond",
          "value": "1"
        },
        {
          "name": "loadbackendNoReplayTestPerSecond",
          "value": "1"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${log_group}",
            "awslogs-region": "eu-central-1",
            "awslogs-stream-prefix": "ecs"
        }
    }
  }
]


