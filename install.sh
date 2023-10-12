touch requirements.txt;
python3 -m venv venv;
source venv/bin/activate;
pip install -r requirements.txt;
zip -r my_lambda_function.zip exception_handler.py venv/lib/python3.8/site-packages/
mvn clean install;
docker build --build-arg JAR_FILE=target/demo-0.0.1-SNAPSHOT.jar -t demo:latest .;
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<region>.amazonaws.com;
docker tag demo:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/demo:latest;
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/demo:latest;
kubectl apply demo-k8s.yaml