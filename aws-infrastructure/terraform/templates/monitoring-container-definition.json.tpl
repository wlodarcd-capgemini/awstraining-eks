[
  {
    "name": "prometheus",
    "image": "${ecr_url}:prometheus",
    "memoryReservation": 256,
    "memory": 512,
    "cpu": 256,
    "essential": true,
    "portMappings": [
        {
        "containerPort": 9090,
        "hostPort": 9090,
        "protocol": "tcp"
        }
    ],
    "environment": [
        {
           "name": "DISCOVERY_FILTER",
           "value": "application=backend"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "DockerLabels": {
        "application": "prometheus"
    }
  },
  {
    "name": "elasticsearch",
    "image": "${ecr_url}:elasticsearch",
    "memoryReservation": 512,
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "portMappings": [
        {
        "containerPort": 9200,
        "hostPort": 9200,
        "protocol": "tcp"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "DockerLabels": {
        "application": "elasticsearch"
    }
  },
  {
    "name": "filebeat",
    "image": "${ecr_url}:filebeat",
    "memoryReservation": 256,
    "memory": 512,
    "cpu": 256,
    "essential": true,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "DockerLabels": {
        "application": "filebeat"
    }
  },
  {
    "name": "kibana",
    "image": "${ecr_url}:kibana",
    "memoryReservation": 512,
    "memory": 1024,
    "cpu": 256,
    "essential": true,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": [
        {
          "name": "SERVER",
          "value": "kibana"
        },
        {
          "name": "ELASTICSEARCH_HOSTS",
          "value": "http://localhost:9200"
        },
        {
           "name": "ELASTICSEARCH_USERNAME",
           "value": "kibana_system"
        },
        {
           "name": "ELASTICSEARCH_PASSWORD",
           "value": "changeme"
        }
    ],
    "portMappings": [
        {
        "containerPort": 5601,
        "hostPort": 5601,
        "protocol": "tcp"
        }
    ],
    "DockerLabels": {
        "application": "kibana"
    }
  },
{
    "name": "grafana",
    "image": "${ecr_url}:grafana",
    "memoryReservation": 256,
    "memory": 512,
    "cpu": 256,
    "essential": true,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
        {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp"
        }
    ],
    "DockerLabels": {
        "application": "grafana"
    }
  }
]