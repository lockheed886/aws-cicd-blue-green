@Library('my-shared-library') _
def failedStage = "Unknown"

pipeline {
    agent { label 'linux-agent' }

    environment {
        SLACK_WEBHOOK = credentials('slack-webhook')
    }

    stages {
        stage('Checkout') {
            steps {
                script { failedStage = 'Checkout' }
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script { failedStage = 'Build' }
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

                    # Now run the heavy Docker build
                    docker build -t my-app-image .
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

        // stage('Static Analysis') {
        //     steps {
        //         script { failedStage = 'Static Analysis' }
        //         // The name 'SonarQube' must match exactly what you typed in Manage Jenkins > System
        //         withSonarQubeEnv('SonarQube') {
        //             dir('app') { // Adjust this if your code is not in an 'app' folder
        //                 sh '''
        //                 # Example using a temporary dockerized scanner if sonar-scanner isn't installed natively
        //                 # Replace this with your specific scanner command (e.g., mvn sonar:sonar, npm run sonar, etc.)
        //                 
        //                 docker run --rm \
        //                     -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
        //                     -e SONAR_TOKEN="${SONAR_AUTH_TOKEN}" \
        //                     -v "${PWD}:/usr/src" \
        //                     sonarsource/sonar-scanner-cli \
        //                     -Dsonar.projectKey=Assignment-4-App \
        //                     -Dsonar.sources=. \
        //                     -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info # Update based on your language
        //                 '''
        //             }
        //         }
        //     }
        // }

        // stage('Quality Gate Check') {
        //     steps {
        //         script { failedStage = 'Quality Gate Check' }
        //         // This step listens for the Webhook from SonarQube
        //         timeout(time: 10, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

        stage('Package') {
            steps {
                script { failedStage = 'Package' }
                dir('app') {
                    sh 'docker tag my-app-image my-app-image:latest'
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
