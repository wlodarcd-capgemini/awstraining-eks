[
  {
    "name": "backend",
    "image": "${image}",
    "memoryReservation": 1024,
    "memory": 2048,
    "cpu": 1024,
    "essential": true,
    "portMappings": [
        {
        "containerPort": 8081,
        "hostPort": 8081,
        "protocol": "tcp"
        }
    ],
    "secrets": [
        {
           "valueFrom": "${secrets_arn}",
           "name": "SPRING_APPLICATION_JSON"
        }
    ],
    "environment": [
        {
          "name": "INITIAL_START",
          "value": "true"
        },
        {
          "name": "HUB",
          "value": "${upper(hub)}"
        },
        {
          "name": "STAGE",
          "value": "${upper(environment)}"
        },
        {
          "name": "REGION",
          "value": "${region}"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "DockerLabels": {
        "application": "backend",
        "PROMETHEUS_EXPORTER_JOB_NAME": "backend",
        "PROMETHEUS_EXPORTER_PATH": "/actuator/prometheus",
        "PROMETHEUS_EXPORTER_PORT": "8081"
    }

  }
]