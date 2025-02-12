pipeline {
    agent any

    environment {
        DEPLOY_FOLDER="/var/www/html/laravel_crud/"
        GIT_BRANCH="master"
        TEST_SERVER_IP="15.207.71.152"
    }

    stages {
        stage ('Deploy to Remote server') {
            steps {
                sh '${WORKSPACE}/* root@${TEST_SERVER_IP}:/var/www/html/laravel_crud/'
            }
        }
    }
}

// https://www.youtube.com/watch?v=5GtH-nDEEK8