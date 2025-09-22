#!/usr/bin/env python3

from flask import Flask, request, jsonify
import subprocess
import os
import json
import threading
import time
from datetime import datetime

app = Flask(__name__)

# Store for tracking operations (in production, use a database)
operations = {}

def run_terraform_operation(operation_id, params):
    """Run terraform operation in background"""
    try:
        # Update operation status
        operations[operation_id]['status'] = 'running'
        operations[operation_id]['started_at'] = datetime.now().isoformat()
        
        # Build command
        cmd = [
            './terraform-manager.sh',
            f'--aws-access-key-id={params["aws_access_key_id"]}',
            f'--aws-secret-access-key={params["aws_secret_access_key"]}',
            f'--primary-region={params["primary_region"]}',
            f'--secondary-region={params["secondary_region"]}',
            f'--instance-type={params["instance_type"]}',
            f'--key-name={params["key_name"]}',
            f'--operation={params["operation"]}'
        ]
        
        # Execute command
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=1800  # 30 minutes timeout
        )
        
        # Update operation with results
        operations[operation_id]['status'] = 'completed' if result.returncode == 0 else 'failed'
        operations[operation_id]['return_code'] = result.returncode
        operations[operation_id]['stdout'] = result.stdout
        operations[operation_id]['stderr'] = result.stderr
        operations[operation_id]['completed_at'] = datetime.now().isoformat()
        
        # If successful apply, try to get terraform outputs
        if result.returncode == 0 and params["operation"] == "apply":
            try:
                output_result = subprocess.run(
                    ['terraform', 'output', '-json'],
                    capture_output=True,
                    text=True,
                    timeout=60
                )
                if output_result.returncode == 0:
                    operations[operation_id]['terraform_outputs'] = json.loads(output_result.stdout)
            except:
                pass  # Ignore if terraform output fails
        
    except subprocess.TimeoutExpired:
        operations[operation_id]['status'] = 'timeout'
        operations[operation_id]['error'] = 'Operation timed out after 30 minutes'
        operations[operation_id]['completed_at'] = datetime.now().isoformat()
    except Exception as e:
        operations[operation_id]['status'] = 'error'
        operations[operation_id]['error'] = str(e)
        operations[operation_id]['completed_at'] = datetime.now().isoformat()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

@app.route('/terraform/plan', methods=['POST'])
def terraform_plan():
    """Plan terraform deployment"""
    return execute_terraform_operation('plan')

@app.route('/terraform/apply', methods=['POST'])
def terraform_apply():
    """Apply terraform deployment"""
    return execute_terraform_operation('apply')

@app.route('/terraform/destroy', methods=['POST'])
def terraform_destroy():
    """Destroy terraform infrastructure"""
    return execute_terraform_operation('destroy')

@app.route('/terraform/init', methods=['POST'])
def terraform_init():
    """Initialize terraform"""
    try:
        # Generate operation ID
        operation_id = f"init_{int(time.time())}"
        
        # Store operation info
        operations[operation_id] = {
            'operation': 'init',
            'status': 'running',
            'created_at': datetime.now().isoformat(),
            'started_at': datetime.now().isoformat()
        }
        
        # Run terraform init
        result = subprocess.run(
            ['terraform', 'init'],
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes timeout
        )
        
        # Update operation with results
        operations[operation_id]['status'] = 'completed' if result.returncode == 0 else 'failed'
        operations[operation_id]['return_code'] = result.returncode
        operations[operation_id]['stdout'] = result.stdout
        operations[operation_id]['stderr'] = result.stderr
        operations[operation_id]['completed_at'] = datetime.now().isoformat()
        
        return jsonify({
            'operation_id': operation_id,
            'status': 'completed' if result.returncode == 0 else 'failed',
            'return_code': result.returncode,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'message': 'Terraform init completed successfully' if result.returncode == 0 else 'Terraform init failed'
        }), 200 if result.returncode == 0 else 500
        
    except subprocess.TimeoutExpired:
        operations[operation_id]['status'] = 'timeout'
        operations[operation_id]['error'] = 'Terraform init timed out after 5 minutes'
        operations[operation_id]['completed_at'] = datetime.now().isoformat()
        return jsonify({
            'operation_id': operation_id,
            'status': 'timeout',
            'error': 'Terraform init timed out after 5 minutes'
        }), 500
    except Exception as e:
        operations[operation_id]['status'] = 'error'
        operations[operation_id]['error'] = str(e)
        operations[operation_id]['completed_at'] = datetime.now().isoformat()
        return jsonify({
            'operation_id': operation_id,
            'status': 'error',
            'error': str(e)
        }), 500

def execute_terraform_operation(operation):
    """Common function to execute terraform operations"""
    try:
        # Validate request
        if not request.is_json:
            return jsonify({'error': 'Content-Type must be application/json'}), 400
        
        data = request.get_json()
        
        # Required parameters
        required_params = [
            'aws_access_key_id',
            'aws_secret_access_key', 
            'primary_region',
            'secondary_region',
            'instance_type',
            'key_name'
        ]
        
        # Check for missing parameters
        missing_params = [param for param in required_params if param not in data]
        if missing_params:
            return jsonify({
                'error': 'Missing required parameters',
                'missing_parameters': missing_params
            }), 400
        
        # Generate operation ID
        operation_id = f"{operation}_{int(time.time())}"
        
        # Store operation info
        operations[operation_id] = {
            'operation': operation,
            'status': 'queued',
            'created_at': datetime.now().isoformat(),
            'parameters': {
                'primary_region': data['primary_region'],
                'secondary_region': data['secondary_region'],
                'instance_type': data['instance_type'],
                'key_name': data['key_name'],
                'operation': operation
            }
        }
        
        # Add AWS credentials to params for execution (don't store them)
        exec_params = data.copy()
        exec_params['operation'] = operation
        
        # Start background operation
        thread = threading.Thread(
            target=run_terraform_operation,
            args=(operation_id, exec_params)
        )
        thread.daemon = True
        thread.start()
        
        return jsonify({
            'operation_id': operation_id,
            'status': 'queued',
            'message': f'Terraform {operation} operation started',
            'check_status_url': f'/terraform/status/{operation_id}'
        }), 202
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/terraform/status/<operation_id>', methods=['GET'])
def get_operation_status(operation_id):
    """Get status of a terraform operation"""
    if operation_id not in operations:
        return jsonify({'error': 'Operation not found'}), 404
    
    operation_info = operations[operation_id].copy()
    
    # Don't return sensitive AWS credentials
    if 'aws_access_key_id' in operation_info.get('parameters', {}):
        operation_info['parameters']['aws_access_key_id'] = '***masked***'
    if 'aws_secret_access_key' in operation_info.get('parameters', {}):
        operation_info['parameters']['aws_secret_access_key'] = '***masked***'
    
    return jsonify(operation_info)

@app.route('/terraform/operations', methods=['GET'])
def list_operations():
    """List all operations"""
    # Return operations without sensitive data
    safe_operations = {}
    for op_id, op_info in operations.items():
        safe_op = op_info.copy()
        if 'parameters' in safe_op and 'aws_access_key_id' in safe_op['parameters']:
            safe_op['parameters']['aws_access_key_id'] = '***masked***'
        if 'parameters' in safe_op and 'aws_secret_access_key' in safe_op['parameters']:
            safe_op['parameters']['aws_secret_access_key'] = '***masked***'
        safe_operations[op_id] = safe_op
    
    return jsonify({
        'operations': safe_operations,
        'count': len(safe_operations)
    })

@app.route('/terraform/outputs', methods=['GET'])
def get_terraform_outputs():
    """Get current terraform outputs"""
    try:
        result = subprocess.run(
            ['terraform', 'output', '-json'],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            outputs = json.loads(result.stdout)
            return jsonify({
                'success': True,
                'outputs': outputs
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Failed to get terraform outputs',
                'stderr': result.stderr
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # Check if terraform-manager.sh exists and is executable
    if not os.path.exists('./terraform-manager.sh'):
        print("ERROR: terraform-manager.sh not found in current directory")
        exit(1)
    
    if not os.access('./terraform-manager.sh', os.X_OK):
        print("ERROR: terraform-manager.sh is not executable. Run: chmod +x terraform-manager.sh")
        exit(1)
    
    print("🚀 Terraform API Server Starting...")
    print("📋 Available endpoints:")
    print("   GET  /health                    - Health check")
    print("   POST /terraform/init            - Initialize terraform")
    print("   POST /terraform/plan            - Plan deployment")
    print("   POST /terraform/apply           - Apply deployment")  
    print("   POST /terraform/destroy         - Destroy infrastructure")
    print("   GET  /terraform/status/<id>     - Get operation status")
    print("   GET  /terraform/operations      - List all operations")
    print("   GET  /terraform/outputs         - Get terraform outputs")
    print("")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
