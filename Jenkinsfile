// Jenkinsfile to push image-recipes repo to github
 
@Library('dst-shared@master') _

pipeline {
    agent {
        kubernetes {
            label "cray-recipes-github-push"
            containerTemplate {
                name "cms-recipes-github-push-cont"
                image "arti.dev.cray.com/dstbuildenv-docker-master-local/cray-alpine3_build_environment:latest"
                ttyEnabled true
                command "cat"
            }
        }
    }

    // Configuration options applicable to the entire job
    options {
        // This build should not take long, fail the build if it appears stuck
        timeout(time: 10, unit: 'MINUTES')

        // Don't fill up the build server with unnecessary cruft
        buildDiscarder(logRotator(numToKeepStr: '5'))

        // Add timestamps and color to console output, cuz pretty
        timestamps()
    }

    environment {
        // Set environment variables here
        GIT_TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
    }

    stages {
        stage('Push to github') {
            when { allOf {
                expression { BRANCH_NAME ==~ /(bugfix\/.*|feature\/.*|hotfix\/.*|master|release\/.*)/ }
            }}
            steps {
                container('cms-recipes-github-push-cont') {
                    sh """
                        apk add --no-cache bash curl jq git openssl
                    """
                    script {
                        pushToGithub(
                            githubRepo: "Cray-HPE/image-recipes",
                            pemSecretId: "githubapp-stash-sync",
                            githubAppId: "91129",
                            githubAppInstallationId: "13313749"
                        )
                    }
                }
            }
        }
    }

    post('Post-build steps') {
        failure {
            emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
                recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
            )
        }

    }
}
