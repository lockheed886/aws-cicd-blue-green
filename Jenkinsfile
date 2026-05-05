pipeline {
    agent { label 'linux-agent' } // Uses your existing EC2 agent

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to perform')
        booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'Skip manual approval?')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Fmt & Validate') {
            steps {
                echo "Initializing Terraform modules..."
                sh 'terraform init -backend=false' 
                
                echo "Checking Formatting and Validation..."
                sh 'terraform fmt -check'
                sh 'terraform validate'
            }
        }

        stage('Security Scan') {
            steps {
                echo "Running tfsec Security Scan..."
                // Runs tfsec via Docker so you don't have to install it. 
                // Pipes output to file and fails build if HIGH/CRITICAL found.
                sh '''
                docker run --rm -v $(pwd):/src -w /src aquasec/tfsec . --minimum-severity HIGH | tee tfsec-report.txt
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'tfsec-report.txt', allowEmptyArchive: true
                }
            }
        }

        stage('Plan') {
            steps {
                echo "Initializing AWS Backend..."
                sh 'terraform init'
                
                script {
                    if (params.ACTION == 'destroy') {
                        sh 'terraform plan -destroy -out=tfplan'
                    } else {
                        sh 'terraform plan -out=tfplan'
                    }
                }
                
                // Archive the binary plan file
                archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
            }
        }

        stage('Manual Approval') {
            when {
                expression {
                    // Only ask for approval if AUTO_APPROVE is false AND we are applying/destroying
                    return params.AUTO_APPROVE == false && (params.ACTION == 'apply' || params.ACTION == 'destroy')
                }
            }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    // 📸 Take your screenshot of this prompt when it pops up!
                    input message: "Approve Terraform ${params.ACTION}?", ok: "Approve"
                }
            }
        }

        stage('Apply/Destroy') {
            when {
                expression {
                    return params.ACTION == 'apply' || params.ACTION == 'destroy'
                }
            }
            steps {
                echo "Executing Plan..."
                // Apply the exact binary plan we generated earlier
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
