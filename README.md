# Portable and consistent Dev Toolbox based on NetBeans
A specific variety of tools are the trusted companions of a software developer.

Gather together a set of tools, which will become your favorite set of tools (at least for a while), costs time, and it can not be done effortlessly.
You want them ready to go in any circumstance, and this is the reason a laptop becomes like the toolbox a plumber always have with him, or her. You personalize it with stickers outside and all the care you can give it inside.
But life is unfair. One day your beloved friend will leave you and what will be there will be called tragedy and pain.
Luckily we learned that machines are soulless and do not deserve our love and loyalty. When you lost one, you must have been ready to start another in no time.
Moreover, if you want to be with one or another, you don't have to be concerned about its feelings, and mostly, you want to find exactly the tools you are used to, precisely in the same order you left them the last time.
So, why do not you put all your favorite tools in a container you always feel free to delete without the fear of losing a friend?

This is the idea: separate your tools from settings, separate development environment settings from your standard user configurations, make the whole toolbox replaceable in no time, keep your settings in sync with a cloud service and you'll live your life with that smile on your mouth that just the thoughtless can have.

**This is what it is:** *a Dockerfile to build your (mine) complete toolbox and have it always ready to go as you want.*

## The content of the box:
Because I'm a PHP developer, but not just that, and think Oracle NetBeans is excellent even if not perfect, this one is the primary tool in the box.

Hera a complete list of the content of the box:

 - [Oracle NetBeans 8.2](https://netbeans.org/downloads/) 
 - [OpenJdk 8](http://openjdk.java.net/)  (of course)
 - [PHP 7.2](http://php.net/ChangeLog-7.php) with extensions (`php -m` for the complete list)
	 - [Xdebug](https://xdebug.org/)
	 - [PHP Composer 1.6.3](https://getcomposer.org/)
	 - [PHPUnit 7.0](https://phpunit.de/)
- [Node JS 6.12](https://nodejs.org/en/)
	- [npm](https://www.npmjs.com/)
- [Ruby 2.3](https://www.ruby-lang.org/)
	- [CSS Sass 3.4](https://sass-lang.com/)
	- [CSS Compass 1.0.3](compass-style.org)
- [GIT](https://git-scm.com/)
- [Mozilla Firefox 58](https://www.mozilla.org/en-US/firefox/)
- [Google Chrome 64](https://www.google.com/chrome/)

## How does it work
Mount the directory where you keep your development projects as container volume. It will become the home directory of an unprivileged user where its UID and GID are 1000.
If you keep this directory in sync, e.g., using Dropbox or something else, you can quickly change from a machine to another just always running the same command.

 - Let's say `~/Develops` is where you keep your dev projects.
 - You can name the new container `devtools` to speed up future calls.
 - To run graphical UI you need to pass `$DISPLAY` envinronment variable, and mount `/tmp/.X11-unix`.
 - If you want Google Chrome running you need `--cap-add=SYS_ADMIN` and `--device=/dev/dri`

#### First run:

    docker run --name=devtools -it --cap-add=SYS_ADMIN --device=/dev/dri  -e DISPLAY -v ~/Develops:/netbeans -v /tmp/.X11-unix:/tmp/.X11-unix:rw blys/DevToolboxNB8.2

After a while, NetBeans will appear.
#### Stop your toolbox:
    docker stop devtools
#### Start your toolbox:
    docker start devtools
#### Destroy your toolbox (but not settings):
    docker rm devtools
#### Run a tool (e.g. nodejs): 
    docker exec -it devtools nodejs /netbeans/path-to-your-js/your.js
