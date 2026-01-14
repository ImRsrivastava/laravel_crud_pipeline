pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rishabh0205/apache-laravel"
        DOCKER_IMAGE_TAG = '1.0'
        DOCKER_HUB_CREDENTIAL_ID = "81a2%^TFD-IKHVH-497d-8053-04ea733ed7ed"        
        PROJECT_CONTAINER_NAME = "laravel_crud_project"
        MYSQL_CONTAINER_NAME = "laravel_crud_mysql"        
        GIT_BRANCH = 'master'
        GIT_CREDENTIAL_ID = "f08df267-9548-NFTHGS"
        GIT_REPO_URL = 'https://github.com/ImRsrivastava/laravel_crud_pipeline.git'
        JENKINS_WORKSPACE = '/var/lib/jenkins/workspace/Apache-Laravel-CICD-Pipeline'
    }
    options {
        skipDefaultCheckout()  // Prevents Jenkins from running default checkout
    }

    stages {
        stage('Prepare Workspace') {
            steps {
                script {
                    sh "sudo chown -R jenkins:jenkins ${JENKINS_WORKSPACE}"
                    sh "sudo chmod -R 775 ${JENKINS_WORKSPACE}"
                    sh "sudo rm -f ${JENKINS_WORKSPACE}/.git/config.lock"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                checkout([$class: 'GitSCM', 
                    branches: [[name: "${GIT_BRANCH}"]],
                    userRemoteConfigs: [[url: "${GIT_REPO_URL}", credentialsId: "${GIT_CREDENTIAL_ID}"]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIAL_ID}", 
                                                     passwordVariable: 'DOCKER_PASSWORD', 
                                                     usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    sh "docker-compose down"
                    sh "docker-compose up --build -d"

                    // Wait for Laravel container to be fully running
                    sh '''
                        echo "Waiting for Laravel container to be up..."
                        while ! docker ps | grep -q ${PROJECT_CONTAINER_NAME}; do
                            sleep 2
                        done
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    sh """
                        docker exec -i ${PROJECT_CONTAINER_NAME} git config --global --add safe.directory /var/www/html
                        docker exec -i ${PROJECT_CONTAINER_NAME} composer install --ignore-platform-reqs --no-dev
                    """
                }
            }
        }

        stage('Run Migrations') {
            steps {
                script {
                    sh '''
                        echo "Waiting for MySQL to be ready..."
                        until docker exec -i ${PROJECT_CONTAINER_NAME} mysqladmin ping -h ${MYSQL_CONTAINER_NAME} --silent; do
                            sleep 3
                        done
                    '''

                    def retryCount = 5
                    def success = false
                    for (int i = 0; i < retryCount; i++) {
                        try {
                            sh "docker exec -i ${PROJECT_CONTAINER_NAME} php artisan migrate --force"
                            sh "docker exec -i ${PROJECT_CONTAINER_NAME} php artisan cache:clear"
                            success = true
                            break
                        } catch (Exception e) {
                            echo "Migration attempt ${i + 1} failed, retrying in 5 seconds..."
                            sleep(5)
                        }
                    }
                    if (!success) {
                        error "Migration failed after ${retryCount} attempts"
                    }
                }
            }
        }
    }

    post {
        success {
            emailext (
                subject: "Pipeline Deployment Successful",
                body: "Deployment of Apache-Laravel-CICD-Pipeline Project was successful!",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                to: 'rishabh.sr@cisinlabs.com'
            )
        }
        failure {
            emailext (
                subject: "Deployment Failed",
                body: "Deployment of Apache-Laravel-CICD-Pipeline Project failed. Check logs in Jenkins.",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                to: 'rishabh.sr@cisinlabs.com'
            )
        }
    }
}
