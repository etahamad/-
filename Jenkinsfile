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
}