pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Unit Tests , JUnit and Jacoco') {
            steps {
              sh "mvn test"   
            }
            post{
              always{
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }

      stage('Mutation Test - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage" 
            }
            post{
              always{
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
      }
      
      stage('SonarQube Analysis') {
        steps{
          def mvn = tool 'mvn';
          withSonarQubeEnv() {
            sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=devsecops -Dsonar.projectName='devsecops'"
          }

        }
       
      }


      // stage('Docker Build and Push') {
      //   steps {
      //     withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
      //       sh 'printenv'
      //       sh 'sudo docker build -t kalhalabi/numeric-app:""$GIT_COMMIT"" .'
      //       sh 'sudo docker push kalhalabi/numeric-app:""$GIT_COMMIT""'
      //     }
      //   }
      // }
      // stage('Kubernetes Deployment - DEV') {
      //   steps {
      //     withKubeConfig([credentialsId: 'kubeconfig']) {
      //       sh "sed -i 's#replace#kalhalabi/numeric-app:$GIT_COMMIT#g' k8s_deployment_service.yaml"
      //       sh "kubectl apply -f k8s_deployment_service.yaml"
      //     }
      //   }
      // }
}
}