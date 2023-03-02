# Init variables
export REGION="${1}"
export CLUSTERNAME="${2}"

# Install dependencies
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set syncSecret.enabled=true
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# Create the secet
aws --region "$REGION" secretsmanager create-secret --name PostgresUser --secret-string "${3}"
aws --region "$REGION" secretsmanager create-secret --name PostgresPassword --secret-string "${4}"

# Define the Policy
POLICY_ARN=$(aws --region "$REGION" --query Policy.Arn --output text iam create-policy --policy-name my-deployment-policy --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["arn:*:secretsmanager:*:*:secret:PostgresUser-??????", "arn:*:secretsmanager:*:*:secret:PostgresPassword-??????"]
    }]
}')

# We need to install eksctl
eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTERNAME" --approve # Only run this once
eksctl create iamserviceaccount --name my-deployment-sa --region="$REGION" --cluster "$CLUSTERNAME" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts