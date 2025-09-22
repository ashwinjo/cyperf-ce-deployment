# Security Guidelines

## 🔒 Before Pushing to GitHub

### ✅ Credentials Masked
All example AWS credentials have been replaced with placeholders:
- `YOUR_AWS_ACCESS_KEY_ID`
- `YOUR_AWS_SECRET_ACCESS_KEY`

### ✅ Files Protected by .gitignore
The following sensitive files are automatically ignored:
- `terraform.tfstate*` - Contains infrastructure state
- `*.pem` - Private key files
- `*.tfvars` - Variable files with credentials
- `.env*` - Environment files
- `credentials.txt` - Any credential files

## 🛡️ Best Practices

### 1. Never Hardcode Credentials
```bash
# ❌ DON'T DO THIS
export AWS_ACCESS_KEY_ID="AKIA..."

# ✅ DO THIS INSTEAD
export AWS_ACCESS_KEY_ID="$YOUR_ACCESS_KEY"
```

### 2. Use Environment Variables
```bash
# Set in your shell, not in code
export AWS_ACCESS_KEY_ID="your-actual-key"
export AWS_SECRET_ACCESS_KEY="your-actual-secret"
```

### 3. Use .env Files (Not Committed)
Create a `.env` file locally (ignored by git):
```bash
# .env file (not committed to git)
AWS_ACCESS_KEY_ID=your-actual-key
AWS_SECRET_ACCESS_KEY=your-actual-secret
```

### 4. Rotate Keys Regularly
- Change AWS access keys every 90 days
- Delete unused keys immediately
- Use temporary credentials when possible

## 🚨 If You Accidentally Commit Credentials

### Immediate Actions:
1. **Rotate the exposed credentials immediately**
2. **Remove from git history:**
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch filename' \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push to overwrite history:**
   ```bash
   git push origin --force --all
   ```

## 🔍 Pre-Commit Checklist

Before pushing to GitHub, run:

```bash
# 1. Check for exposed credentials
grep -r "AKIA" . --exclude-dir=.git
grep -r "aws_secret_access_key.*[A-Za-z0-9/+]" . --exclude-dir=.git

# 2. Verify .gitignore is working
git status

# 3. Check what will be committed
git diff --cached
```

## 📋 Safe Files to Commit

✅ **Safe to commit:**
- `deployment.tf`
- `variables.tf` 
- `outputs.tf`
- `terraform_api.py`
- `terraform-manager.sh`
- `*.md` documentation files
- `requirements.txt`

❌ **Never commit:**
- `terraform.tfstate*`
- `*.pem` files
- `terraform.tfvars` with real values
- Any file with actual AWS credentials

## 🔐 Production Security

For production use:
1. **Use IAM roles** instead of access keys when possible
2. **Enable AWS CloudTrail** for audit logging
3. **Use least-privilege permissions**
4. **Enable MFA** for AWS accounts
5. **Use AWS Secrets Manager** for credential storage
6. **Implement proper authentication** for the Flask API

## 📞 Security Incident Response

If credentials are compromised:
1. **Immediately disable** the compromised credentials
2. **Create new credentials** with different names
3. **Review CloudTrail logs** for unauthorized usage
4. **Update all systems** with new credentials
5. **Document the incident** for future reference
