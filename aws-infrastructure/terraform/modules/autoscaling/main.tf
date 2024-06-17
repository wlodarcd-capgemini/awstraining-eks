resource "aws_appautoscaling_target" "ecs-appautoscaling-target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.service_deployment_min_desired_task_count
  max_capacity       = var.service_deployment_max_desired_task_count
}

resource "aws_appautoscaling_policy" "ecs-appautoscaling-up" {
  name               = "ecs_backend_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 15
      scaling_adjustment          = 3
    }
    step_adjustment {
      metric_interval_lower_bound = 15
      scaling_adjustment          = 6
    }
  }

  depends_on = [aws_appautoscaling_target.ecs-appautoscaling-target]
}

resource "aws_appautoscaling_policy" "ecs-appautoscaling-down" {
  name               = "ecs_backend_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = -5
      scaling_adjustment          = -2
    }
    step_adjustment {
      metric_interval_lower_bound = -5
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs-appautoscaling-target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "ecs_backend_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs-appautoscaling-up.arn]

  tags = merge(
    var.common_tags,
    {
      "Name" = "ecs-backend-cloud-watch-metric-alarm-cpu-high"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "ecs_backend_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs-appautoscaling-down.arn]

  tags = merge(
    var.common_tags,
    {
      "Name" = "ecs-backend-cloud-watch-metric-alarm-cpu-low"
    }
  )
}

resource "aws_cloudwatch_dashboard" "autoscaling" {
  dashboard_name = "autoscaling-${var.region}"
  dashboard_body = <<EOF
{
  "widgets": [
     {
         "type": "metric",
         "x": 0,
         "y": 0,
         "width": 12,
         "height": 6,
         "properties": {
             "metrics": [
                [ "AWS/ECS", "CPUUtilization", "ClusterName", "backend-${var.environment}" ],
                [ "AWS/Usage", "ResourceCount", "Type", "Resource", "Resource", "OnDemand", "Service", "Fargate", "Class", "None" ]
         ],
         "annotations": {
             "horizontal": [
              {
              "visible":true,
              "color":"#FF0000",
              "label":"CPUUtilization => 30 (Scale up)",
              "value":30,
              "yAxis":"left"
              },
              {
              "visible":true,
              "color":"#2ca02c",
              "label":"CPUUtilization <= 20 for 2 datapoints within 2 min",
              "value":20,
              "yAxis":"left"
             }
          ]
          },
         "period": 60,
         "stat": "Average",
         "region": "${var.region}",
         "title": "Autoscaling-${var.region}"
        }
    }
  ]
}
EOF
}