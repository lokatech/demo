mvn clean install;
docker build --build-arg JAR_FILE=target/demo-0.0.1-SNAPSHOT.jar -t demo:latest .;
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<region>.amazonaws.com;
docker tag demo:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/demo:latest;
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/demo:latest;
kubectl apply demo-k8s.yaml