# VS Code Server on Openshift

## Intro

This repository takes the existing work found @ https://github.com/cdr/code-server and
adapts it to run on OpenShift.

## Docker / Podman Usage

```
# os w/ selinux
docker run -d \
  --name custom-code-server \
  -p 1337:1337 \
  -p 8080:8080 \
  -e PASSWORD="thisisnice" \
  -v ${PWD}:/home/coder:z \
  quay.io/codekow/code-server:latest
```
URL: http://localhost:1337

## Quick Start
Deploy a Custom Code Server (w/ custom build)

`Add to Project` => `Import YAML / JSON`

* [deploy-code-server-no-webdav-template.yml](openshift/deploy-code-server-no-webdav-template.yml)
* [deploy-code-server-template.yml](openshift/deploy-code-server-template.yml)


### Demo Route

A demo route is configured to test any app on 0.0.0.0 and port 8080.
This is the default for most [source-to-image (s2i)](https://github.com/sclorg/s2i-python-container) builds.

Run the following in the terminal of code server:

```sh
# basic python example
python -m http.server 8080
```

### WebDav

TODO
- Username: **coder**
- Password: **[password]**


## How to Build and Deploy on OpenShift

### Quickstarts

```
# Docker / Podman
. setup/local_docker_build.sh
code_server_build codercom
code_server_build ubi8

# OpenShift
setup/local_ocp_build_ubi8.sh
setup/local_ocp_build_codercom.sh
```

This repo contains Dockerfiles to build this code server image. 
You'll also find an openshift directory which contains a build file and templates to deploy an instance of Code Server on OpenShift.

### Prerequisits

In order to deploy a Code Server instance to OpenShift you will need to have an OpenShift project configured and a basic understanding of how to work with OpenShift.

### Build and Deploy Using the Web Console

1. In your project click on `Add to Project` > `Import YAML / JSON` in the top right hand corner.

2. The `Import YAML / JSON` window will appear.  Copy the contents of the appropriate template and paste it into the `Import YAML / JSON` window.  Click `Create`.

3. An option will appear to `Add a template`.  By default the option will be selected to `Process the template`.  Keep the defaults selected and press `Continue`.

    * `Process the template` allows you to immediatly deploy an image.  This is the recommended option.

    * `Save template` allows others that have access to your project to use the template from the catalog to deploy their own copies of the image.

4. The Code Server template will appear.  Update the `APPLICATION_NAME` to uniquely identify it within your project.  Enter a password in the `CODE_SERVER_PASSWORD`.  This password will be used to sign into the web interface.  Click `Create`.

A deployment should begin and will create a new pod with a Route attached to the Code Server.
Use the Route to access the web interface. The web interface will prompt you for the password you previously set in the template.

## Using Code Server

### Accessing Your Environment

The template will create several routes for you.  The primary route mapped to port 1337 will take you to the Code Server web interface. Use the password you created in the template to access the environemnt.

### Using the Demo Route

The template will also create a "Demo" route for you which is mapped to port 8080.  This demo route is intended to be used for web development similar to how you would use localhost on your local machine.

In order to use the Demo route you can start your Web Application using port 8080 using the IP address 0.0.0.0 from your Code Server environment and you should be able to access it from the Demo route.

>The More You Know:
>
>0.0.0.0 is not a valid IP address but it is a meta-address that generally works like a wildcard.  When you start a webserver with 0.0.0.0 it will run on whatever IP address is available on the machine.

Code Server also has additional un-used ports that you can configure additional routes to if you require them.

### Mounting Code Server as a Drive in Windows with WebDav

If you configured your Code Server enviornment with the optional WebDav sidecar you will be able to mount the environment as a drive on your Windows machine.

1. From the `Windows File Explorer` navigate to `This Computer` and under the `Computer` ribbon choose `Map a network drive`.

2. In the `Folder` field paste the WebDav route created by the template and check the box for `Connect using differente credentials` and click `Finish`.

3. For the username, use `coder` and the password is the password you configured when completing the template.


### Look Ma` No Chrome!

Code Server is a progressive web app which means that it can appear like a local app running on your Windows machine even though it is still running in the browser.

To run Code Server as a progressive web app click on the `+` icon to the left of the favorite icon in the URL bar in Chrome.

Code Server should now appear as a seperate icon in your Task Bar which you can Pin for easy access later.
