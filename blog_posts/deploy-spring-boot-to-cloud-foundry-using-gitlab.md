Deploy A Spring Boot Application To Cloud Foundry Using Gitlab
2017-11-06

In this post I will demonstrate how to deploy a [Spring Boot](https://projects.spring.io/spring-boot/) application to [Cloud Foundry](https://www.cloudfoundry.org/) using the popular Git hosting and Continuous Delivery platform [Gitlab](https://about.gitlab.com/).

All the code for this project can be found in [the Gitlab repo](https://gitlab.com/DylanGriffith/spring-gitlab-cf-deploy-demo).

## Install CF CLI And Login

The latest installation instructions for your system can be found at https://github.com/cloudfoundry/cli

You can login to CF like so:

```
$ cf login -a api.run.pivotal.io
```

The above url assumes you are deploying to [PWS](http://run.pivotal.io/) which is a multi-tenant Cloud Foundry instance you can use with a trial account to get started with CF.

NOTE: You will want to replace the api.run.pivotal.io to the API url of your CF instance if you're not planning on deploying to PWS.

## Create Your Project

To start your Spring Boot application you can go to the [Spring Initializr](https://start.spring.io/) and select the components you want. For the purposes of simplicity we're going to just create a simple web app with a "Hello, world!" route in it so we need only select "Web" from dependencies. You can pick any other things you may need and choose the build tools you like but I've chosen the options below:

![Spring Initializr settings](http://cdn.dylangriffith.net/8bf58b8d-564e-4d64-a0a7-886515a14bf1.png)

After you unzip the application and `cd` into the directory you can start the app with:

```sh
./gradlew bootRun
```

Now we want to add a route to our application so we create a new controller:

```java
// src/main/java/net/dylangriffith/gitlabcfdeploy/helloworld/HelloController.java
package net.dylangriffith.gitlabcfdeploy.helloworld;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/")
    public String hello() {
        return "Hello, world!";
    }
}
```

Now after restarting the application you should be able to visit http://localhost:8080/ and see the message "Hello, world!".

## Configure Your Cloud Foundry Deployment

In order to ensure the JAR path is consistent you can update the `build.gradle` file and add the following to the bottom of the file:

```
jar{
    archiveName 'helloworld.jar'
}
```

First compile the JAR for your spring boot application like so:

```bash
./gradlew assemble
```

In order to deploy to cloud foundry all we need to do is add a `manifest.yml`. You should create this in the root directory of your project with the following content:

```yaml
---
applications:
- name: gitlab-hello-world
  random-route: true
  memory: 1G
  path: ./build/libs/helloworld.jar
```

NOTE: If you're not using gradle you may have to build your JAR differently but you can find the path by executing `find . -name *.jar`.

Now that you have your `manifest.yml` and assuming you've installed and logged into CF locally you can now test your deployment by running:

```bash
cf push
```

Once the app is finished deploying it will display the route for your application:

```
requested state: started
instances: 1/1
usage: 1G x 1 instances
urls: gitlab-hello-world-undissembling-hotchpot.cfapps.io
last uploaded: Mon Nov 6 10:02:25 UTC 2017
stack: cflinuxfs2
buildpack: client-certificate-mapper=1.2.0_RELEASE container-security-provider=1.8.0_RELEASE java-buildpack=v4.5-offline-https://github.com/cloudfoundry/java-buildpack.git#ffeefb9 java-main java-opts jvmkill-agent=1.10.0_RELEASE open-jdk-like-jre=1.8.0_1...

     state     since                    cpu      memory         disk           details
#0   running   2017-11-06 09:03:22 PM   120.4%   291.9M of 1G   137.6M of 1G
```

You can then visit your deployed application (mine was https://gitlab-hello-world-undissembling-hotchpot.cfapps.io/) and you should see the "Hello, world!" message.

## Create And Push To The Gitlab Repo

Create your gitlab repo (eg. https://gitlab.com/MyUsername/my-repo.git ) then push to it locally:

```bash
git init
git remote add origin git@gitlab.com:MyUsername/my-repo.git
git add .
git commit -m "Initial commit"
git push -u origin master
```

## Configure Gitlab CI To Deploy Your Application

The first thing you are going to need to do is add your CF credentials as environment variables on Gitlab CI. Depending on your team setup it may be best to create a separate deploy user just for deploying your applications and add their credentials to Gitlab. If you are using PWS you can just register a new user otherwise in PCF you will probably need a PCF administrator to create a new account for you.

Now you have credentials you can add them to Gitlab by navigating from your project page > Settings > CI/CD. From there you want to add "Secret Variables". Name the variables `CF_USERNAME` and `CF_PASSWORD` and set them to the correct values. We will use these in a moment in our deploy script.

![Secret Variable Settings in Gitlab](http://cdn.dylangriffith.net/5d23d9f6-51f2-4885-b834-abd00d780322.png)

Now you need to add the `.gitlab-ci.yml` to your project. Add it to the root and Gitlab will pick it up automatically and run the builds for you:

```yaml
image: java:8

production:
  type: deploy
  script:
  - ./gradlew assemble
  - curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
  - ./cf login -u $CF_USERNAME -p $CF_PASSWORD -a api.run.pivotal.io
  - ./cf push
  only:
  - master
```

NOTE: Again you will need to be sure the url (above is api.run.pivotal.io) is the correct url for your CF installation.

Now when you push your code you should see the build running on Gitlab (under CI/CD > Pipelines) and it should deploy to CF for you.

## Conclusion

This guide demonstrates how little setup is needed to take a Spring Boot application and deploy it to Cloud Foundry in an automated way using Gitlab CI/CD.

Gitlab and Cloud Foundry have both become popular on premise solutions used by many large enterprises. The simplicity of Gitlab CI/CD along with the simplicity of deploying to Cloud Foundry make this a really good option for organisations that want to reduce their time to production and automate some of the repetetive deployment tasks developers may often be doing manually.
