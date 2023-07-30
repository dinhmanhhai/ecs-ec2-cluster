#!/bin/bash
cd /etc/ecs
touch ecs.config
echo "ECS_CLUSTER=${name}" > ecs.config