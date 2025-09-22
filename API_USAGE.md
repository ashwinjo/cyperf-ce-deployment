# Terraform API Usage Guide

## Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Make Scripts Executable
```bash
chmod +x terraform-manager.sh
chmod +x terraform_api.py
```

### 3. Start the API Server
```bash
python3 terraform_api.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### Health Check
```bash
curl -X GET http://localhost:5000/health
```

### Plan Deployment (Safe - No Changes)
```bash
curl -X POST http://localhost:5000/terraform/plan \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "us-east-1",
    "secondary_region": "us-west-2",
    "instance_type": "c5n.2xlarge",
    "key_name": "vibecode"
  }'
```

### Apply Deployment (Creates Infrastructure)
```bash
curl -X POST http://localhost:5000/terraform/apply \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "us-east-1",
    "secondary_region": "us-west-2",
    "instance_type": "c5n.2xlarge",
    "key_name": "vibecode"
  }'
```

### Destroy Infrastructure
```bash
curl -X POST http://localhost:5000/terraform/destroy \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "us-east-1",
    "secondary_region": "us-west-2",
    "instance_type": "c5n.2xlarge",
    "key_name": "vibecode"
  }'
```

### Check Operation Status
```bash
# Replace {operation_id} with the ID returned from plan/apply/destroy
curl -X GET http://localhost:5000/terraform/status/{operation_id}
```

### List All Operations
```bash
curl -X GET http://localhost:5000/terraform/operations
```

### Get Terraform Outputs (After Apply)
```bash
curl -X GET http://localhost:5000/terraform/outputs
```

## Example Workflow

### 1. Start API Server
```bash
python3 terraform_api.py
```

### 2. Plan Deployment
```bash
curl -X POST http://localhost:5000/terraform/plan \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "us-east-1",
    "secondary_region": "us-west-2",
    "instance_type": "c5n.2xlarge",
    "key_name": "vibecode"
  }'
```

**Response:**
```json
{
  "operation_id": "plan_1703123456",
  "status": "queued",
  "message": "Terraform plan operation started",
  "check_status_url": "/terraform/status/plan_1703123456"
}
```

### 3. Check Status
```bash
curl -X GET http://localhost:5000/terraform/status/plan_1703123456
```

**Response:**
```json
{
  "operation": "plan",
  "status": "completed",
  "created_at": "2023-12-21T10:30:45",
  "started_at": "2023-12-21T10:30:46",
  "completed_at": "2023-12-21T10:32:15",
  "return_code": 0,
  "stdout": "Terraform plan output...",
  "parameters": {
    "primary_region": "us-east-1",
    "secondary_region": "us-west-2",
    "instance_type": "c5n.2xlarge",
    "key_name": "vibecode",
    "operation": "plan"
  }
}
```

### 4. Apply Deployment
```bash
curl -X POST http://localhost:5000/terraform/apply \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "us-east-1",
    "secondary_region": "us-west-2",
    "instance_type": "c5n.2xlarge",
    "key_name": "vibecode"
  }'
```

### 5. Get Infrastructure Details
```bash
curl -X GET http://localhost:5000/terraform/outputs
```

**Response:**
```json
{
  "success": true,
  "outputs": {
    "CYPERF_SERVER_IP": {
      "sensitive": false,
      "type": "string", 
      "value": "3.87.123.45"
    },
    "CYPERF_CLIENT_IP": {
      "sensitive": false,
      "type": "string",
      "value": "54.123.45.67"
    },
    "ssh_commands": {
      "sensitive": false,
      "type": "object",
      "value": {
        "server": "ssh -i vibecode ubuntu@3.87.123.45",
        "client": "ssh -i vibecode ubuntu@54.123.45.67"
      }
    }
  }
}
```

## Different Region Examples

### European Deployment
```bash
curl -X POST http://localhost:5000/terraform/apply \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "eu-west-1",
    "secondary_region": "eu-central-1",
    "instance_type": "c5n.xlarge",
    "key_name": "eu-key"
  }'
```

### Asia Pacific Deployment
```bash
curl -X POST http://localhost:5000/terraform/apply \
  -H "Content-Type: application/json" \
  -d '{
    "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    "primary_region": "ap-southeast-1",
    "secondary_region": "ap-northeast-1",
    "instance_type": "c5n.2xlarge",
    "key_name": "apac-key"
  }'
```

## Operation Status Values

| Status | Description |
|--------|-------------|
| `queued` | Operation is queued but not started |
| `running` | Operation is currently executing |
| `completed` | Operation finished successfully |
| `failed` | Operation failed with errors |
| `timeout` | Operation timed out (30 min limit) |
| `error` | Unexpected error occurred |

## Error Responses

### Missing Parameters
```json
{
  "error": "Missing required parameters",
  "missing_parameters": ["aws_access_key_id", "primary_region"]
}
```

### Operation Not Found
```json
{
  "error": "Operation not found"
}
```

### Internal Server Error
```json
{
  "error": "Internal server error"
}
```

## Security Notes

- ✅ AWS credentials are not stored in operation history
- ✅ Credentials are masked in API responses
- ✅ Operations run with 30-minute timeout
- ⚠️  This is a development server - use proper authentication in production
- ⚠️  Consider using environment variables for sensitive data in production
