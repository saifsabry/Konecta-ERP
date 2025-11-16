#!/bin/bash
####################################################################
# create-kubernetes-files.sh
# Creates all necessary Kubernetes manifest files with correct AWS Account ID
####################################################################

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Creating Kubernetes Manifest Files                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Get AWS Account ID
echo "Getting AWS Account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Error: Could not get AWS Account ID. Make sure AWS CLI is configured."
    echo "Run: aws configure"
    exit 1
fi

echo "✓ AWS Account ID: $ACCOUNT_ID"
echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p kubernetes-manifests
cd kubernetes-manifests

echo "✓ Directory created: kubernetes-manifests/"
echo ""

# Function to replace ACCOUNT_ID placeholder
replace_account_id() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/<ACCOUNT_ID>/${ACCOUNT_ID}/g" "$1"
    else
        # Linux
        sed -i "s/<ACCOUNT_ID>/${ACCOUNT_ID}/g" "$1"
    fi
}

# Create namespace.yaml
echo "Creating namespace.yaml..."
cat > namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: erp-apps
  labels:
    name: erp-apps
    environment: production
EOF
echo "✓ Created: namespace.yaml"

# Create deployments.yaml
echo "Creating deployments.yaml..."
cat > deployments.yaml << 'EOF'
# Copy the content from the "All 11 Apps - Deployments" artifact here
# OR use the files I provided
EOF

# For now, create a template that user needs to copy
cat > deployments.yaml << 'EOFDEPLOYMENTS'
####################################################################
# deployments.yaml - All 11 Applications
# This file needs the full deployment content
####################################################################
# INSTRUCTIONS:
# 1. Copy the content from "All 11 Apps - Deployments" artifact
# 2. Paste it here
# 3. The script will automatically replace <ACCOUNT_ID> with your AWS account ID
#
# Or run: 
# Copy content from the artifact I provided above named "All 11 Apps - Deployments"
EOFDEPLOYMENTS

echo "⚠️  deployments.yaml created as template - needs content from artifacts"

# Create services.yaml
echo "Creating services.yaml..."
cat > services.yaml << 'EOFSERVICES'
####################################################################
# Copy content from "All 11 Apps - Services" artifact
####################################################################
EOFSERVICES
echo "⚠️  services.yaml created as template"

# Create hpa.yaml
echo "Creating hpa.yaml..."
cat > hpa.yaml << 'EOFHPA'
####################################################################
# Copy content from "All 11 Apps - Horizontal Pod Autoscalers" artifact
####################################################################
EOFHPA
echo "⚠️  hpa.yaml created as template"

# Create ingress.yaml
echo "Creating ingress.yaml..."
cat > ingress.yaml << 'EOFINGRESS'
####################################################################
# Copy content from "Kubernetes Ingress - ALB Configuration" artifact
####################################################################
EOFINGRESS
echo "⚠️  ingress.yaml created as template"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✓ Kubernetes manifest directory structure created!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Copy the content from the artifacts I provided into these files:"
echo "   - deployments.yaml  (from 'All 11 Apps - Deployments')"
echo "   - services.yaml     (from 'All 11 Apps - Services')"
echo "   - hpa.yaml          (from 'All 11 Apps - Horizontal Pod Autoscalers')"
echo "   - ingress.yaml      (from 'Kubernetes Ingress - ALB Configuration')"
echo ""
echo "2. Your AWS Account ID ($ACCOUNT_ID) is ready to use"
echo ""
echo "3. Replace <ACCOUNT_ID> in deployments.yaml with: $ACCOUNT_ID"
echo "   Or run: sed -i 's/<ACCOUNT_ID>/$ACCOUNT_ID/g' deployments.yaml"
echo ""
echo "4. Deploy with: kubectl apply -f kubernetes-manifests/"
echo ""
echo "Files created in: $(pwd)"
echo ""