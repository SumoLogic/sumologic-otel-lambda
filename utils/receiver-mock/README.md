# Receiver Mock

Terraform deployment template of [receiver-mock] from [Sumo Logic Kubernetes Tools].

## Requirements

- [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [terraform](https://www.terraform.io/)

## Deployment

[receiver-mock] is deployed as a single container in AWS ECS Service. Terrafom will create objects like:

- ECS Cluster
- ECS Task definition
- ECS Cluster Service
- network (vpc, subnets, security groups, eip, nat gw)

### Terraform execution

Before execution of the commands below make sure you have configured [AWS Credentials].
To deploy [receiver-mock] go to `deploy` directory and run `terraform init` to initialize working directory.
After that execute `terraform apply` command.

After successful deployment an IP address of [receiver-mock] will be printed to the console.

[receiver-mock] accepts incoming traffic on port `3000`.

### Environment cleanup

To remove all created objects execute `terraform destroy`.

[Sumo Logic Kubernetes Tools]: https://github.com/SumoLogic/sumologic-kubernetes-tools
[receiver-mock]: https://github.com/SumoLogic/sumologic-kubernetes-tools/tree/main/src/rust/receiver-mock
