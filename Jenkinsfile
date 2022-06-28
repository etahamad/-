pipeline {
    agent {
        node { label 'main' }
    }
    environment{
        PRODUCT_NAME='lavender'
    }
    stage('Repo Sync') {
        steps {
            sh './scripts/repo-sync.sh'
        }
    }
    stage('user-clean') {
        steps {
            sh './scripts/clean.sh mka'
        }
    }     
    stage('user-system') {
        steps {
            sh './scripts/build-new.sh mka xd $PRODUCT_NAME user'
        }
    }
}
