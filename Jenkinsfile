@Library('my-shared-library') _
def failedStage = "Unknown"

pipeline {
    agent { label 'linux-agent' }

    environment {
        SLACK_WEBHOOK = credentials('slack-webhook')
        AWS_ACCOUNT_ID = '461073513531'
        AWS_REGION = 'us-east-1'
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/assignment-5-app"
        GIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        GIT_BRANCH = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                script { failedStage = 'Checkout' }
                checkout scm
            }
        }

        stage('Container Build') {
            steps {
                script { failedStage = 'Container Build' }
                dir('app') {
                    sh '''
                    # EMERGENCY RAM FIX: Create 2GB swap space if it doesn't exist
                    if [ ! -f /swapfile ]; then
                        sudo fallocate -l 2G /swapfile
                        sudo chmod 600 /swapfile
                        sudo mkswap /swapfile
                        sudo swapon /swapfile
                    fi

                    # EMERGENCY DISK FIX: Delete old, unused Docker images to free up space
                    echo "Taking out the Docker trash..."
                    docker system prune -af --volumes

                    echo "Building and Tagging Docker image..."
                    docker build -t ${ECR_REPO}:${GIT_SHA} -t ${ECR_REPO}:${GIT_BRANCH} .
                    '''
                }
            }
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        script { failedStage = 'Unit Tests' }
                        dir('app') {
                            sh 'npm install'
                            sh 'npm run test:unit -- --coverage'
                            junit 'junit-unit.xml'
                        }
                    }
                }
                stage('Integration Tests') {
                    steps {
                        script { failedStage = 'Integration Tests' }
                        dir('app') {
                            sh 'npm install'
                            sh 'npm run test:integration'
                            junit 'junit-integration.xml'
                        }
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                script { failedStage = 'Security Scan' }
                dir('app') {
                    sh '''
                    echo "Using committed .trivyignore file..."
                    cp ../.trivyignore .

                    echo "Generating Trivy Report Artifact..."
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workspace -w /workspace aquasec/trivy image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --format table \
                        --output trivy-report.txt \
                        ${ECR_REPO}:${GIT_SHA}
                        
                    cat trivy-report.txt

                    echo "Enforcing Quality Gate..."
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workspace -w /workspace aquasec/trivy image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --exit-code 1 \
                        ${ECR_REPO}:${GIT_SHA}
                    '''
                }
            }
            post {
                always {
                    dir('app') {
                        archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script { failedStage = 'Push to ECR' }
                dir('app') {
                    sh '''
                    echo "Authenticating to AWS ECR..."
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    
                    echo "Pushing images to ECR..."
                    docker push ${ECR_REPO}:${GIT_SHA}
                    docker push ${ECR_REPO}:${GIT_BRANCH}
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                script { failedStage = 'Deploy' }
                echo 'Deploying...'
            }
        }
    }

    post {
        always {
            notifySlack(message: "Build ${currentBuild.fullDisplayName} finished with status: ${currentBuild.currentResult}")
        }
    }
}
