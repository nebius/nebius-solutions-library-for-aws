# Data replication between AWS RDS for PostgreSQL and Nebius MDB for PostgreSQL by Nebius Data Transfer

## Overview and target scenario
We’ve noticed that more and more customers are looking for approaches to help them build hybrid solutions. While the reasons for this include a need to comply with local regulations and meet latency requirements, others use AWS for primary deployment and consolidating data. To help our customers, we tested data replication (sync) between `AWS RDS for PostgreSQL` (version 14) and `Nebius Managed Service for PostgreSQL` (version 14) and prepared detailed step-by-step instructions for the scenario. For the data transfer is used `Nebius Data Transfer` service. The deployment architecture is illustrated below:

<p align="center">
    <img src="db-replication-nebius.png" alt="DB Replication with Nebius Data Transfer diagram" width="600"/>
</p>

## Documentation
* [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/)
* [Nebius Managed Service for PostgreSQL](https://nebius.com/il/docs/managed-postgresql/)
* [Nebius Data Transfer](https://nebius.com/il/docs/data-transfer/)


## Prerequisites

- Accounts in AWS and Nebius
- Bash
- Terraform 1.1.5
- jq
- [PostgreSQL Client (psql)](https://www.compose.com/articles/postgresql-tips-installing-the-postgresql-client/)

To configure AWS site:
- Configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

To configure Nebius site:
- Configure [CLI](https://nebius.com/il/docs/cli/quickstart) 
- Export Nebius Credentials to the Terraform Provider

```bash
# Nebius Environment
yc config profile activate default
export CIL_CLOUD_ID=$(yc config get cloud-id)
export CIL_FOLDER_ID=$(yc config get folder-id)
export CIL_TOKEN=$(yc iam create-token)
export TF_VAR_cloud_id=$CIL_CLOUD_ID
export TF_VAR_folder_id=$CIL_FOLDER_ID
export TF_VAR_token=$CIL_TOKEN
# AWS Environment (if required)
export AWS_PROFILE=aws
```

## Quick start

### Initiate example playbook

This playbook will create PostgreSQL instances on AWS and Nebius sides.

Please wait for about 10 minutes when tasks have been finished.
```bash
cd example
terraform init
terraform apply 
```

### Prepare an environment
```bash
DB_USER=$(terraform output -raw db_user)
DB_PORT=$(terraform output -raw db_port)
DB_NAME=$(terraform output -raw db_name)
DB_PASS=$(terraform output -raw db_passwd)

CIL_DB_ID=$(terraform output -raw cil_db_cluster_id)
CIL_DB_HOST=$(terraform output -raw cil_db_host_fqdn)

AWS_DB_HOST=$(terraform output -raw aws_db_host_fqdn)
```

### Create table with the sample of data in Origin DB (AWS side)
```bash
psql "postgresql://$DB_USER:$DB_PASS@$AWS_DB_HOST:$DB_PORT/$DB_NAME" -c "CREATE TABLE phone (phone VARCHAR(32) PRIMARY KEY, firstname VARCHAR(32), lastname VARCHAR(32)); INSERT INTO phone (phone, firstname, lastname) VALUES('12313213','Jack','Jackinson');"
```

### Create Nebius Data Transfer for the data replication
Create the Nebius `Data Transfer` for replicate data from the AWS RDS to the Nebius MDB.
```bash
terraform apply -var=dt_enable=true
```
Please wait about 10 minutes when tasks have been finished.

### Check data replication results on Nebius side
```bash
psql "postgresql://$DB_USER:$DB_PASS@$CIL_DB_HOST:$DB_PORT/$DB_NAME" -c "SELECT * FROM phone;"
```

### Add more data to the Origin DB (AWS side)
```bash
psql "postgresql://$DB_USER:$DB_PASS@$AWS_DB_HOST:$DB_PORT/$DB_NAME" -c "INSERT INTO phone(phone, firstname, lastname) VALUES ('444444','Alex','Trump');"
```
Data transfer can take a few minutes!

### Check data replication results again on Nebius side
```bash
psql "postgresql://$DB_USER:$DB_PASS@$CIL_DB_HOST:$DB_PORT/$DB_NAME" -c "SELECT * FROM phone;"
```

### To destroy everything quickly

Destroy the Data Transfer resource first.
```bash
terraform destroy -target=yandex_datatransfer_transfer.dt_transfer
```

Please wait about 5 minutes before continue and destroy all other Terraform resources.

```bash
terraform destroy
```
