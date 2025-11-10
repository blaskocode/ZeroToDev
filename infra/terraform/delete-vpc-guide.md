# How to Delete a VPC in AWS

## Step 1: Check VPC Resources

Before deleting a VPC, you must remove all resources in it. Use the provided script:

```bash
cd infra/terraform
./check-vpc-resources.sh <vpc-id>
```

Or manually check:
```bash
# Replace VPC_ID with the VPC you want to check
VPC_ID="vpc-024b70e550cf81f27"

# Check subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"

# Check Internet Gateways
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID"

# Check NAT Gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID"

# Check Security Groups (excluding default)
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=!default"
```

## Step 2: Delete Resources in Order

**IMPORTANT:** Delete resources in this specific order:

### 1. Delete NAT Gateways
```bash
# List NAT Gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID"

# Delete each NAT Gateway (replace NAT_GW_ID)
aws ec2 delete-nat-gateway --nat-gateway-id <NAT_GW_ID>

# Wait for deletion to complete (can take a few minutes)
aws ec2 wait nat-gateway-deleted --nat-gateway-ids <NAT_GW_ID>
```

### 2. Delete VPC Endpoints
```bash
# List VPC Endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID"

# Delete each endpoint
aws ec2 delete-vpc-endpoint --vpc-endpoint-id <ENDPOINT_ID>
```

### 3. Detach and Delete Internet Gateways
```bash
# List Internet Gateways
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID"

# Detach first, then delete
aws ec2 detach-internet-gateway --internet-gateway-id <IGW_ID> --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id <IGW_ID>
```

### 4. Delete Route Tables (except main)
```bash
# List Route Tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=false"

# Delete route table associations first
aws ec2 disassociate-route-table --association-id <ASSOCIATION_ID>

# Then delete the route table
aws ec2 delete-route-table --route-table-id <RT_ID>
```

### 5. Delete Subnets
```bash
# List Subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"

# Delete each subnet
aws ec2 delete-subnet --subnet-id <SUBNET_ID>
```

### 6. Delete Security Groups (except default)
```bash
# List Security Groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=!default"

# Delete each security group
aws ec2 delete-security-group --group-id <SG_ID>
```

### 7. Delete Network ACLs (except default)
```bash
# List Network ACLs
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$VPC_ID" "Name=is-default,Values=false"

# Delete each network ACL
aws ec2 delete-network-acl --network-acl-id <ACL_ID>
```

### 8. Release Elastic IPs (if any)
```bash
# List Elastic IPs
aws ec2 describe-addresses --filters "Name=domain,Values=vpc"

# Release Elastic IPs (only if not in use)
aws ec2 release-address --allocation-id <ALLOCATION_ID>
```

## Step 3: Delete the VPC

Once all resources are deleted:

```bash
aws ec2 delete-vpc --vpc-id $VPC_ID
```

## Quick Delete Script (Use with Caution!)

For a VPC managed by Terraform, it's safer to use Terraform to delete it:

```bash
# If the VPC is in Terraform state
terraform destroy -target=module.networking.aws_vpc.main
```

## Common Issues

### "DependencyViolation" Error
- Some resource is still attached to the VPC
- Check all resources again using the check script
- Make sure NAT Gateways are fully deleted (can take 5-10 minutes)

### Default VPC
- Default VPCs (CIDR 172.31.0.0/16) can be deleted but require extra steps
- AWS will recreate a default VPC if you delete it and don't have one

### VPC with Active Resources
- If the VPC has EC2 instances, RDS, ECS tasks, etc., you must delete those first
- Check for any running resources before attempting deletion

## Safety Checklist

Before deleting a VPC, verify:
- [ ] No EC2 instances running
- [ ] No RDS instances
- [ ] No ECS services/tasks
- [ ] No Elastic Load Balancers
- [ ] No NAT Gateways
- [ ] No VPC Endpoints
- [ ] Internet Gateways detached
- [ ] All subnets deleted
- [ ] All custom security groups deleted
- [ ] All custom route tables deleted

