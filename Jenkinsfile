pipeline {
    agent any

    environment {
        // Ganti dengan username Docker Hub kamu
        DOCKERHUB_USER   = 'christian78778'
        IMAGE_NAME       = "${DOCKERHUB_USER}/devops-learning-project"
        IMAGE_TAG        = "${env.BUILD_NUMBER}"
        // Kredensial ini dibuat di Jenkins: Manage Jenkins > Credentials
        DOCKERHUB_CREDS  = credentials('dockerhub-credentials')
        KUBECONFIG_CRED  = credentials('kubeconfig-file') // kredensial tipe "Secret file"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install & Unit Test') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r app/requirements.txt
                    pip install -r tests/requirements-test.txt
                    pytest tests/ -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_CRED
                        terraform init -input=false
                        terraform plan -input=false \
                            -var="app_image=${IMAGE_NAME}:${IMAGE_TAG}" \
			    -var="kubeconfig_path=${KUBECONFIG_CRED}" \
                            -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_CRED
                        terraform apply -input=false -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                sh '''
                    export KUBECONFIG=$KUBECONFIG_CRED
                    kubectl rollout status deployment/devops-app -n devops-learning --timeout=90s
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment sukses! Image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline gagal, cek log di atas."
        }
        always {
            sh 'docker logout || true'
        }
    }
}
