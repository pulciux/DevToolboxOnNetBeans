
# Portable and consistent Dev Toolbox based on NetBeans

##### v1.2.2

https://hub.docker.com/r/blys/devtoolboxnb8.2/

A specific variety of tools is the trusted companion of a software developer.

To gather together a set of tools, which will become your favorite set of tools (at least for a while), costs time, and it can't be done effortlessly.
You want them ready to go in any circumstance, and this is the reason they will become like the toolbox a plumber always have with him, or her, for instance.
You love your laptop; you personalize it with stickers reflecting all the care you gave it making that unique toolbox you settled up.
But life is unfair. One day your beloved friend will leave you and there will be just tragedy and suffering.
Luckily we learned that machines are soulless and do not deserve our love or loyalty. When you lost one, you must be ready to start another in no time.
Moreover, if you want to be with one or another, you don't have to be concerned about their feelings, and mostly, you want to find exactly the tools you are used to, precisely in the same order you left them for the last time, even if it was on a different machine.
So, why don't put all your favorite tools in a container you always feel free to delete without the fear of losing a friend?

This is the idea: separate your tools from settings, separate development environment settings from your standard user configurations, make the whole toolbox replaceable in no time, keep your settings in sync using a cloud service and you'll live your life with a thoughtless smile on your face.

**This is what it is:** *a Dockerfile to build your (mine) complete toolbox and have it always ready to go as you want.*

## The content of the box:
Because I'm a PHP developer, but not just that, and I think Oracle NetBeans is an excellent IDE, even if not perfect, this one is the primary tool in the box.

Here a complete list of the content of the box:

 - [Oracle NetBeans 8.2](https://netbeans.org/downloads/)
 - [OpenJdk 8](http://openjdk.java.net/)  (of course)
 - [PHP 7.2](http://php.net/ChangeLog-7.php) with extensions (`php -m` for the complete list)
	 - [Xdebug](https://xdebug.org/)
	 - [PHP Composer 1.6.3](https://getcomposer.org/)
	 - [PHPUnit 7.0](https://phpunit.de/)
- [Node JS 6.12](https://nodejs.org/en/)
	- [npm](https://www.npmjs.com/)
        - [UglifyJS2](https://github.com/mishoo/UglifyJS2)
- [Ruby 2.3](https://www.ruby-lang.org/)
	- [CSS Sass 3.4](https://sass-lang.com/)
	- [CSS Compass 1.0.3](compass-style.org)
- [GIT 2,11](https://git-scm.com/)
- [Mozilla Firefox 58](https://www.mozilla.org/en-US/firefox/)
- [Google Chrome 64](https://www.google.com/chrome/)
- [Flamerobin](http://www.flamerobin.org/)


## How does it work
Mount the directory where you keep your development projects as container volume. Pass your system's user info (as provided by passwd file) and be sure that user is the one who can access your projects' directory.
Give the container your email address.
The projects' directory, inside the newly created container, will become the home directory of an unprivileged user whit equal username, UID and group and full name of your actual system's user.
Your git identity will be there ready for you.
If you keep your directory in sync, e.g., using Dropbox or something else (allowing the sync of hidden files and directories), you can quickly move from a machine to another just running the same command.

 - Let's say `~/Develops` is where you keep your dev projects.
 - Pass your user's info by the envinronment variable USERCFG:  ``-e "USERCFG=`getent passwd $USER`"``
 - Set your email: ``-e "USEREMAIL=my.email@example.org"``
 - You can name the new container (e.g. `devtools`) to speed up future calls.
 - To run graphical UI you need to pass `$DISPLAY` envinronment variable, and mount `/tmp/.X11-unix`.
 - If you want Google Chrome to run, you need `--cap-add=SYS_ADMIN` and `--device=/dev/dri`

#### First run:
```bash
docker run --name=mytbox -it --net=host --memory=2g --oom-kill-disable -e "USEREMAIL=my.email@example.org" -e "USERCFG=`getent passwd $USER`" --cap-add=SYS_ADMIN --device=/dev/dri  -e DISPLAY -v $HOME:/netbeans blys/devtoolboxnb8.2:1.2.2
```

After a short while, NetBeans will appear.
#### Stop your toolbox:
    docker stop devtools
#### Start your toolbox:
    docker start devtools
#### Destroy your toolbox (but not settings):
    docker rm devtools
#### Run a tool (e.g. nodejs):
    docker exec -it devtools nodejs /netbeans/path-to-your-js/your.js
