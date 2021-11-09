pipeline{
    agent any
    environment {
        PATH = "$PATH:/opt/apache-maven-3.8.3/bin"
//        def DOCKER_USR = "/vars/${username}"
//        def DOCKER_PASSWD = "/vars/${Passwd}"
//        EXAMPLE_CREDS = credentials('DockerHub_passwd')
        def registry = "devenderpatelqa/sample-pro" 
        def registryCredential = "DockerHub_passwd"
        dockerImage = ''
        
        
    }
    
    stages{
       stage('GetCode'){
            steps{
                git 'https://github.com/koppuladeva/simple-app.git'
            }
         }        
       stage('Build'){
            steps{
                sh 'mvn clean package'
            }
         }
        stage('SonarQube analysis') {
//    def scannerHome = tool 'SonarScanner 4.0';
        steps{
        withSonarQubeEnv('sonarqube-8.9.3') { 
        // If you have configured more than one global server connection, you can specify its name
//      sh "${scannerHome}/bin/sonar-scanner"
        sh "mvn sonar:sonar"
    }
        }
        }
      stage('Uploadartiacttonexus'){
            steps{
			  script{
			      
			   def mavenPom = readMavenPom file: 'pom.xml'
			   def NexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "DHS-snapshort" : "DHS-release"
                nexusArtifactUploader artifacts: [
                    [artifactId: "${mavenPom.artifactId}", 
                    classifier: '', 
                    file: "target/${mavenPom.artifactId}-${mavenPom.version}.war", 
                    type: 'war']
                    ], 
                    credentialsId: 'nexus3_cred', 
                    groupId: 'org.springframework.samples', 
                    nexusUrl: '54.89.161.147:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: "${NexusRepoName}", 
                    version: "${mavenPom.version}"
				
					}
            }
         }
        stage('Docker Build'){
            steps{
                script { 
//                    dockerImage = docker.build("${registry} + :${env.BUILD_NUMBER}")
//                   app = docker.build("devenderpatelqa/sample-pro:1.0.1")
                    sh "docker build . -t devenderpatelqa/sample-pro:1.0.1"
                }
                
            }
        }
        
         stage('DockerHub Push'){
            steps{
                script {
//                    docker.withRegistry( 'https://registry.hub.docker.com', 'DockerHub_passwd' ) { 
//                       app.push() 
//                withCredentials([usernameColonPassword(credentialsId: 'DockerHub_passwd', variable: 'DockerHub_Passwd')]) {
//                    sh "docker login --username ${DOCKER_USR}:${DockerHub_Passwd}"
//                }
//                sh ("docker login -u ${EXAMPLE_CREDS_USR} -p ${EXAMPLE_CREDS_PSW} https://registry.hub.docker.com")
//                   docker.withRegistry( 'https://registry.hub.docker.com/', 'DockerHub_passwd' ) {
                    withCredentials([usernamePassword(credentialsId: 'DockerHub_passwd', passwordVariable: 'Docker_passw', usernameVariable: 'Docker_user')]) {
                        sh "docker login --username ${Docker_user} -p ${Docker_passw}"
                    }
                        sh "docker push devenderpatelqa/sample-pro:1.0.1"
                        
                   }
                
                }
                
            }
        
        
        stage('Docker Deploy'){
            steps{
              ansiblePlaybook credentialsId: 'Docker_cred', disableHostKeyChecking: true, installation: 'Ansible2', inventory: 'dev.inv', playbook: 'deployadockerapp.yml'
            }
        }
    }
    }
