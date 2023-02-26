# CI / CD
![image](https://github.com/tsv1982/infrastructure_petclinic/blob/main/imges/infra.png "diagram of CI - CD")
# Jenkins 
  + [pipeline for build](https://github.com/tsv1982/infrastructure_petclinic/blob/main/JenkinsFile/Jenkinsfile_build "Jenkinsfile_build") (tools Docker and maven)
  + [pipeline for creating infrastructure](https://github.com/tsv1982/infrastructure_petclinic/blob/main/JenkinsFile/Jenkinsfile_infra "Jenkinsfile_infra") (tools Terrafom and Ansible)
  + [pipeline for updating ECS](https://github.com/tsv1982/infrastructure_petclinic/blob/main/JenkinsFile/Jenkinsfile_update "Jenkinsfile_update") (tool AWS CLI)
# Terraform
+ using Terraform we create the infrastructure of the project
![image](https://github.com/tsv1982/infrastructure_petclinic/blob/main/imges/terraform.png "diagram of terraform")
# Ansible
+ configure Mysql instance using Ansible
![image](https://github.com/tsv1982/infrastructure_petclinic/blob/main/imges/ansible.png "diagram of terraform")
---
# improve the project
1. Implementation GitFlow review in the project
2. reduce the size of the docker image (for example, create based on the alpine:latest image)
3. in pipeline build implement SonarQube
4. includes the ability to select a build version to update the environment
5. make locking tfstate.file
6. use different availability zones for app
7. use load balancer 
8. implement auto scaling for app
9. mysql replication
10. monitoring
11. do code refactoring
