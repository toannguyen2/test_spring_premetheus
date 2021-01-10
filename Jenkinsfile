pipeline {
    agent any
    stages {
    	stage('Build') {
    		steps {
    			sh 'echo "[ $BRANCH_NAME ] Start building..."'
    			sh 'docker build -t test_spring_premetheus-$BRANCH_NAME-build .'
    		}
    	}
    	stage('Test') {
            steps {
            	sh '''
					docker run $HOSTS \
						--name test_spring_premetheus-$BRANCH_NAME-test-container \
						--volume=/data/jenkins/.m2:/root/.m2 \
						test_spring_premetheus-$BRANCH_NAME-build -Dmaven.test.skip=false
				'''
            }
            post {
                always {
                	sh 'del reports'
                	sh 'docker cp test_spring_premetheus-$BRANCH_NAME-test-container:/deploy/application/target/surefire-reports reports'
                	junit 'reports/*.xml'
                }
				cleanup {
					sh 'docker rm --force test_spring_premetheus-$BRANCH_NAME-test-container || exit 0'
					sh 'docker system prune -f'
				}
            }
        }
        stage('Dist') {
            steps {
                echo 'Dist...'
            }
        }
        stage('Deploy: Development') {
            when {
                branch 'dev'
                beforeAgent true
            }
	        stages {
		        stage('Node_94_34') {
                    agent {
                        node {
                            label 'Node_94_34'
                                customWorkspace '/data/test/jenkins/workspace/test_spring_premetheus-dev'
                            }
                        }
                        environment {
                            REPO_PATH = '/data/jenkins/.m2'
                            DATA_PATH = '/data/jenkins/test_spring_premetheus-dev'
                            NODE_NAME = 'Node_94_34'
                            VERSION   = 'test_spring_premetheus-dev'
                        }
                        steps {
                            deploy()
                        }
                    }
	            }
            }
        }
        stage('Deploy: Production') {
            when {
                branch 'main'
                beforeAgent true
            }
            stages {
            stage('Node_94_34') {
                agent {
            		node {
            		    label 'Node_94_34'
            		    customWorkspace '/data1/test/jenkins/workspace/test_spring_premetheus-prod'
            		    }
            		}
            	    environment {
            			REPO_PATH = '/data1/jenkins/.m2'
            			DATA_PATH = '/data1/jenkins/test_spring_premetheus-prod'
            			NODE_NAME = 'Node_94_34'
            			VERSION   = 'test_spring_premetheus-prod'
            		}
            		steps {
            			deploy()
            		}
            	}
            }
        }
    }
}

void deploy() {
    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
	    sh 'docker network create --driver=bridge --subnet=172.29.1.0/24 test_spring_premetheus || exit 0'
	    sh 'docker-compose up --build builder && docker-compose up --build -d --force-recreate app'

		sh 'docker system prune -f'
		sh 'sleep 10s'
	}
}
