mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name       = "example-network"
  cidr_block = "10.20.0.0/16"
  subnets    = { us-east-1a = { public_cidr = "10.20.0.0/24", private_cidr = "10.20.10.0/24" }, us-east-1b = { public_cidr = "10.20.1.0/24", private_cidr = "10.20.11.0/24" } }
}

run "isolated_defaults" {
  command = plan
  assert {
    condition     = length(aws_nat_gateway.this) == 0 && length(aws_route.nat) == 0
    error_message = "NAT must be opt-in."
  }
  assert {
    condition     = alltrue([for subnet in aws_subnet.public : !subnet.map_public_ip_on_launch])
    error_message = "Subnets must not assign public IPs automatically."
  }
  assert {
    condition     = aws_vpc.this.enable_dns_support && aws_vpc.this.enable_dns_hostnames && length(output.private_subnet_ids) == 2
    error_message = "Provide DNS support and private subnets in each zone."
  }
}

run "per_zone_nat" {
  command = plan
  variables {
    enable_nat_gateway = true
  }
  override_resource {
    target          = aws_nat_gateway.this["us-east-1a"]
    override_during = plan
    values          = { id = "nat-00000000000000001" }
  }
  override_resource {
    target          = aws_nat_gateway.this["us-east-1b"]
    override_during = plan
    values          = { id = "nat-00000000000000002" }
  }
  assert {
    condition     = length(aws_nat_gateway.this) == 2 && alltrue([for availability_zone, route in aws_route.nat : route.nat_gateway_id == aws_nat_gateway.this[availability_zone].id])
    error_message = "Each private route must use its own availability-zone NAT gateway."
  }
}

run "invalid_vpc_cidr" {
  command = plan
  variables {
    cidr_block = "invalid"
  }
  expect_failures = [var.cidr_block]
}

run "single_zone_rejected" {
  command = plan
  variables {
    subnets = { us-east-1a = { public_cidr = "10.20.0.0/24", private_cidr = "10.20.10.0/24" } }
  }
  expect_failures = [var.subnets]
}

run "duplicate_subnet_cidr_rejected" {
  command = plan
  variables {
    subnets = { us-east-1a = { public_cidr = "10.20.0.0/24", private_cidr = "10.20.10.0/24" }, us-east-1b = { public_cidr = "10.20.0.0/24", private_cidr = "10.20.11.0/24" } }
  }
  expect_failures = [var.subnets]
}
