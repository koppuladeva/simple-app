FROM tomcat:8.0
# Take the war and copy to webapps of tomcat
ADD target/*.war /usr/local/tomcat/webapps/sample10.war
