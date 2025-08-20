# /bin/bash
cd
rm -rf swu_blog_deploy
git clone https://github.com/dev-library/swu_blog_deploy.git
cp credential-db ./swu_blog_deploy/src/main/resources/application-db.properties
cd swu_blog_deploy
chmod +x ./gradlew
./gradlew clean build -x test
echo "build complete(ci)"
java -jar ./build/libs/blog-0.0.1-SNAPSHOT.war
echo "deploy complete(cd)"