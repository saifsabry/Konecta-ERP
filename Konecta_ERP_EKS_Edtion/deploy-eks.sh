#!/bin/bash
####################################################################
# deploy-eks.sh
# Script to deploy and configure EKS cluster
####################################################################

set -e

REGION1="eu-central-1"
REGION2="eu-west-1"
CLUSTER_NAME="konecta-erp-cluster"

echo "====================================="
echo "EKS Cluster Deployment Script"
echo "====================================="

# Step 1: Deploy Terraform infrastructure
deploy_terraform() {
    echo "Step 1: Deploying Terraform infrastructure..."
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
    echo "✓ Terraform infrastructure deployed"
}

# Step 2: Configure kubectl for Region 1
configure_kubectl_region1() {
    echo "Step 2: Configuring kubectl for Region 1 (${REGION1})..."
    aws eks update-kubeconfig \
        --region ${REGION1} \
        --name ${CLUSTER_NAME} \
        --alias ${CLUSTER_NAME}-region1
    echo "✓ kubectl configured for Region 1"
}

# Step 3: Configure kubectl for Region 2
configure_kubectl_region2() {
    echo "Step 3: Configuring kubectl for Region 2 (${REGION2})..."
    aws eks update-kubeconfig \
        --region ${REGION2} \
        --name ${CLUSTER_NAME} \
        --alias ${CLUSTER_NAME}-region2
    echo "✓ kubectl configured for Region 2"
}

# Step 4: Install AWS Load Balancer Controller (Region 1)
install_alb_controller_region1() {
    echo "Step 4: Installing AWS Load Balancer Controller in Region 1..."
    
    # Switch context to Region 1
    kubectl config use-context ${CLUSTER_NAME}-region1
    
    # Add EKS Helm repo
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    # Get cluster info
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    VPC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION1} --query "cluster.resourcesVpcConfig.vpcId" --output text)
    
    # Install the controller
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=${CLUSTER_NAME} \
        --set serviceAccount.create=true \
        --set serviceAccount.name=aws-load-balancer-controller \
        --set region=${REGION1} \
        --set vpcId=${VPC_ID}
    
    echo "✓ AWS Load Balancer Controller installed in Region 1"
}

# Step 5: Install AWS Load Balancer Controller (Region 2)
install_alb_controller_region2() {
    echo "Step 5: Installing AWS Load Balancer Controller in Region 2..."
    
    # Switch context to Region 2
    kubectl config use-context ${CLUSTER_NAME}-region2
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    VPC_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION2} --query "cluster.resourcesVpcConfig.vpcId" --output text)
    
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=${CLUSTER_NAME} \
        --set serviceAccount.create=true \
        --set serviceAccount.name=aws-load-balancer-controller \
        --set region=${REGION2} \
        --set vpcId=${VPC_ID}
    
    echo "✓ AWS Load Balancer Controller installed in Region 2"
}

# Step 6: Install Metrics Server (for HPA)
install_metrics_server() {
    echo "Step 6: Installing Metrics Server for autoscaling..."
    
    for CONTEXT in "${CLUSTER_NAME}-region1" "${CLUSTER_NAME}-region2"; do
        kubectl config use-context ${CONTEXT}
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
        echo "✓ Metrics Server installed in ${CONTEXT}"
    done
}

# Step 7: Deploy applications to Region 1
deploy_apps_region1() {
    echo "Step 7: Deploying applications to Region 1..."
    kubectl config use-context ${CLUSTER_NAME}-region1
    kubectl apply -f kubernetes-manifests/
    echo "✓ Applications deployed to Region 1"
}

# Step 8: Deploy applications to Region 2
deploy_apps_region2() {
    echo "Step 8: Deploying applications to Region 2..."
    kubectl config use-context ${CLUSTER_NAME}-region2
    kubectl apply -f kubernetes-manifests/
    echo "✓ Applications deployed to Region 2"
}

# Step 9: Verify deployments
verify_deployments() {
    echo "Step 9: Verifying deployments..."
    
    for CONTEXT in "${CLUSTER_NAME}-region1" "${CLUSTER_NAME}-region2"; do
        echo "Checking ${CONTEXT}..."
        kubectl config use-context ${CONTEXT}
        
        echo "Pods status:"
        kubectl get pods -n erp-apps
        
        echo "Services status:"
        kubectl get services -n erp-apps
        
        echo "Ingress status:"
        kubectl get ingress -n erp-apps
        
        echo "---"
    done
}

# Main execution
main() {
    deploy_terraform
    configure_kubectl_region1
    configure_kubectl_region2
    install_alb_controller_region1
    install_alb_controller_region2
    install_metrics_server
    deploy_apps_region1
    deploy_apps_region2
    verify_deployments
    
    echo "====================================="
    echo "✓ EKS Deployment Complete!"
    echo "====================================="
    echo ""
    echo "To get ALB DNS names, run:"
    echo "  kubectl get ingress -n erp-apps --context=${CLUSTER_NAME}-region1"
    echo "  kubectl get ingress -n erp-apps --context=${CLUSTER_NAME}-region2"
}

# Run main function
main


####################################################################
# push-images.sh
# Script to build and push Docker images to ECR
####################################################################
#!/bin/bash

REGION="eu-central-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Login to ECR
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Array of app names
APPS=("app1" "app2" "app3" "app4" "app5" "app6" "app7" "app8" "app9" "app10" "app11")

for APP in "${APPS[@]}"; do
    echo "Building and pushing ${APP}..."
    
    # Build Docker image
    docker build -t ${APP}_repo:latest ./apps/${APP}/
    
    # Tag image
    docker tag ${APP}_repo:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${APP}_repo:latest
    
    # Push to ECR
    docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${APP}_repo:latest
    
    echo "✓ ${APP} pushed successfully"
done

echo "All images pushed to ECR!"


####################################################################
# scale-app.sh
# Script to scale specific application
####################################################################
#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Usage: $0 <app-name> <replicas> <region>"
    echo "Example: $0 app1 5 region1"
    exit 1
fi

APP_NAME=$1
REPLICAS=$2
REGION=$3
CLUSTER_CONTEXT="konecta-erp-cluster-${REGION}"

kubectl config use-context ${CLUSTER_CONTEXT}
kubectl scale deployment ${APP_NAME}-deployment --replicas=${REPLICAS} -n erp-apps

echo "✓ Scaled ${APP_NAME} to ${REPLICAS} replicas in ${REGION}"