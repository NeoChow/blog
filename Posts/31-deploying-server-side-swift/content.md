Have you been experimenting with Server-Side Swift? Or perhaps, have you
considered it and want to know what is involved? One of the biggest questions
with a new backend technology is: how easy is it to host? I have deployed a
few websites and services, including this blog, so I would like to share with
with you what has worked best for me.

For the purposes of this post, I will assume you know how to develop and build the
Server-Side Swift. It doesn't matter what framework you use as long as it
produces a binary that can listen to a custom port on the network (more on that later).
I will also assume that you have at least some experience managing a linux server from
the command line.

If those things are still a challenge for you, I recommend you check out my [other posts](/)
and [subscribe to my future posts](/subscribers/new) as I will be writing a lot about how
to develop Server-Side Swift in the future.

The Preperation
-----------------

### Quick Summary of HTTP

Before I get into my configuration, I want to describe quickly how a website or service
communicates with users. If you are already familar with this, feel free to skip
to the next section. The web is built on a protocol called [Hypertext Transfer Protocol](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
or HTTP for short. It provides a framework for how a web client should make a
request to a server and how that server should respond.

If you are developing a server based application, you will almost certainly be
using a framework to handle the nitty-gritty of this protocol. All you really need to
know is that the job of your server is to listen for requests from the outside world
and respond.

Requests are routed to your server from a client through the internet
based on the [IP address](https://en.wikipedia.org/wiki/IP_…) of your server which is
most often looked up based on the [domain name](https://en.wikipedia.org/wiki/Domain_name)
the request is being sent to.

The requests are also sent to a specific <a href="https://en.wikipedia.org/wiki/Port_(computer_networking)">port</a>
which you can think of like a door that traffic can pass through represented by a number.
By default, insecure web requests sent over HTTP are sent to port 80 while secure web requests over HTTPS
are sent to port 443. You will see how these facts are important as I talk about setting up
your server.

So to summarize, the relevant parts of a web request for us are:

- Domain name (or IP Address)
- Port
- Secure or Unsecure known as HTTPS or HTTP

The rest is handled once the request is propertly routed to your service. Ok, now onto the
actual deployment.

### The Server

Before we can even talk about configuration, we first have to discuss the server. If you already have a Linux server, feel
free to jump to the next section.

There are many options for a web server but while Linux is in third place when it comes to desktop operating systems, it
dominates the backbone of the internet. You could try to run your website from your Mac at home or possibly
rent out a Mac online, but there are many more services available to use Linux and driving traffic through your home
internet is not a great idea.

To host Swift I highly recommend renting out a Virtual Private Server or a VPS. Essentially you rent part of a physical
computer hosted and managed by a company that specializes in that. You are given remote access to it and it appears
as if you have a full computer all to yourself. There are many Linux web hosts out there, but the one I recommned
is [Linode](https://www.linode.com/?r=0476a3711847b22a3e5531becd349bddb0e8ed63). I have multiple servers (or
"Linodes") hosted with them and they have been very reliable and the company is very respectful of its customers, including
with the prices they charge. They also have fantastic documenation, especially on properly [securing your server](https://www.linode.com/docs/security/securing-your-server?r=0476a3711847b22a3e5531becd349bddb0e8ed63).

### Installing Swift

Once you have a server setup and secured, you need to install Swift. A great tool for managing different versions of Swift
on Linux is [Swift Version Manager](https://github.com/kylef/swiftenv) otherwise known as Swiftenv. Follow the instructions
on their page about installing via a git clone. Once installed, logout of your SSH session and log back in.

Now you can install Swift by running the following command:

    // bash
    swiftenv install 3.0.2

<div class="note">3.0.2 is the latest version of Swift as of my writing this post. Make sure you are using the latest version by
looking it up at [Swift.org](https://swift.org/download/).</div>

To check if it is installed propertly, you can enter the command `swift`. It should bring up a prompt that you can exit by typing `:q` and hitting enter.

Now, you are ready to transfer code your code to your server and get it built. Building your binary is the same as it is on
macOS except you don't have the option of using Xcode, you must do it from the command line with `swift build`. Once you have
it built, we are ready to discuss how we set up your binary to recieve requests from the internet.

The Easiest Way to Deploy
-------------------------

All swift web binaries attach directly to a port to listen for requests. That means the
simplest way to deploy your service would be to run it on port 80 for HTTP or 443 for HTTPS
and be done with it. There are several reasons I do not like this solution:

- In order for a binary to listen on port 80 or port 443, it must run as a super user. This is a bad idea because that means if you make a mistake or someone comprimises your service, your entire server is at stake.
- This will not allow hosting multiple services on the same server. At the very least I want to be able to host a staging service as well as the production one.
- There is no way to gracefully handle your web service crashing and being down; the server will simply stop responding to requests.
- It is much harder to configure the various Swift frameworks for secure communication over HTTPS and I prefer to leave the secure aspect of the communication to technologies that have stood the test of time.

I solve all of these problems with my solution.


Allow Multiple Services
-----------------------

The most important part of my solution is that I route all web requests through [Apache](https://httpd.apache.org). It is a
prolific piece of software for hosting web content.

<div class="note">If you are not familiar with installing and setting up Apache, I recommend you follow [Lindode's tutorial on it](https://www.linode.com/docs/websites/lamp/install-lamp-on-ubuntu-16-04).
However, don't bother with the installation of MYSQL in that tutorial, I recommend a different type of database which I will discuss in a future post.</div>

Apache has a feature called [Virtual Hosts](https://en.wikipedia.org/wiki/Virtual_hosting). It allows you to direct requests to different
places based on the domain name specified by the request. This is exactly what we need if we want to run multiple services from a single server.

To make this work, Apache will be listening to our public HTTP port (port 80). We will then run our own services on other ports and have
Apache redirect traffic, based on the domain name, to the appropriate internal port .

<div class="note">
Moving forward my examples will be based on this blog. I also prefer to use [vim](http://www.vim.org) as my text
editor but I will use [nano](https://www.nano-editor.org) in my examples as it is easier for new developers. Lastly,
my commands assume you are a user with root level access through [sudo](https://en.wikipedia.org/wiki/Sudo).
</div>

For the purposes of this post, I will be setting up a production version of my blog at *drewag.me* and a development version of it at *dev.drewag.me*
(no, this subdomain does not actually exist). To do this, I will create two different Apache configuration files. They should both be created in
`/etc/apache2/sites-available/`. Having two seperate files allows us to start and stop each site independently. I like to name my configuration files after
the domain name they are intented for so let's start with the development one.

    // bash
    sudo nano /etc/apache2/sites-available/dev.drewag.me.conf

In this file we want to setup a virtual host at *dev.drewag.me* that will [proxy]() all of the requests to our local port. I am going to use port 8081 for the
development service.

    // bash
    # /etc/apache2/sites-available/dev.drewag.me
    &#60;VirtualHost *:80>
        ServerName dev.drewag.me
        ProxyPreserveHost On
        ProxyPass / http://localhost:8081
        ProxyPassReverse / http://localhost:8081
    &#60;/VirtualHost>

Let's go through this line by line. Apache configuration files use an XML style system to specify sections. Here we are defining a virtual host that will listen
for requests from any IP address (that is what the `*` means) on port 80. On the next line, we specify that the domain name we want for this virtual host is
dev.drewag.me. The rest of the configurations are for the proxying.

First we turn on `ProxyPreserveHost`. This ensures that the request seen by our service appear as if they are coming directly from its original source instead of
Apache. Next, we are specifying that we want to pass all requests made to the root level and below, back to this server at port 8080. That is the most critical line
for our purposes. However, on the next line we also set `ProxyPassReverse`. This ensures that once our service responds, Apache will update the response to look
like it is coming from our domain instead of the *localhost* address. Finally our last line closes that virtual host configuration section.

Before you enable this configuration we must first ensure that [mod_proxy](https://httpd.apache.org/docs/current/mod/mod_proxy.html), the component of Apache responsible
for the proxy commands, is enabled. You can do so with the following command:

    // bash
    sudo a2enmod proxy

Now you can enable your virtual host site:

    // bash
    sudo a2ensite dev.drewag.me

To make sure both of those commands take effect, you need to restart apache:

    // bash
    sudo service apache2 restart

Now, as long as you have your domain name pointing at your server, you can start up your service to listen on port 8081 and send requests to it at your domain name! Then
you can create as many additional site configuration files with the appropriate `ServerName` and a different internal port. With this setup, they will all work simultaneously.

<div class="note">If you are not familiar with setting up a domain name, your registrar should have instructions. If you don't know what registrar you like,
I love [hover.com](https://hover.com/U4ODK26R). Like Linode, Hover is a great company that respects their customers. I use them for all of my domain names.</div>

Note that if you secured your server properly, port 8081 should not be open to the public (it should be blocked by your firewall). The only reason traffic is able
to get there through this configuration is that it is being passed from port 80 by Apache.

Securing Your Services with SSL
-----------------------

I choose to run my site over HTTPS to ensure security for my visitors. I am not dealing with any real secure information, other than my [donate page](/donate), but I still
feel "better safe than sorry" is appropriate here. To do this, we need to make a small adjustment to our configuration file. This time, I will show you my configuration file for the production
version of *drewag.me*. First, we are going to setup a virtual host on port 80, the HTTP port, that will redirect all traffic to the HTTPS version of our site:

    // bash
    # /etc/apache2/sites-available/dev.drewag.me
    &#60;VirtualHost *:80>
        ServerName drewag.me
        Redirect permanent / https://drewag.me/
    &#60;/VirtualHost>

That is pretty simple. All I am specifying is that all traffic to the root path should be permanently redirected to the HTTPS domain. **Warning:** pay careful attention
that you include the forward slash (`/`) at the end of the domain name.

Next, in the same file, we are going to add a virtual host definition for handling the HTTPS requests. This time it will be on port 443:

    // bash
    # /etc/apache2/sites-available/dev.drewag.me
    &#60;VirtualHost *:443>
        ServerName drewag.me

        ProxyPreserveHost On
        ProxyPass / http://localhost:8080
        ProxyPassReverse / http://localhost:8080

        SSLEngine on
        SSLCertificateFile        /etc/ssl/certs/drewag_me.crt
        SSLCertificateKeyFile     /etc/ssl/private/drewag.me.key
        SSLCertificateChainFile   /etc/ssl/certs/drewag_me.ca-bundle
     &#60;/VirtualHost>

This looks similar to our HTTP version but with some extra configurations. The proxy configurations are the same except this time, they are redirecting to port 8080.
The other group of configurations are specific to the secure part of HTTPS, the SSL configuration. SSL is a method of encrypting all communication between two locations
so that only the intended participants can read the contents. This mechanism requres that you buy an SSL certificate from a trusted [Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority).
You can create and sign your own certificates but then browsers will warn visitors to your site that they cannot trust it. I use the site [namecheap](https://www.namecheap.com/?aff=109760)
because they have cheap certificates and, for my purposes, I have not needed incredibly secure certificates. I have only had good experiences with them.

The first SSL configuration `SSLEngine On` is simply turning on the encryption. The remaining configurations specify the necessary files for doing the encryption. Your Certificate Authority
will have instructions on how to generate or download each of the files.

Now you just need to make sure the SSL module is enabled along with this new site config and restart Apache:

    // bash
    sudo a2enmod proxy
    sudo a2ensite drewag.me
    sudo service apache2 restart

You should now be able to securely communicate with your web service if it is running on port 8080.

One great part of this configuration is that all SSL encryption and decryption is being handled by Apache and you don't have to rely on the implementation inside whatever
Swift framework you are using.

Running Your Binary as a Service
---------------------------------

We have a great setup so far, but at this point you still need to be logged in and manually running your program for it to handle the requests. We want our binaries to run automatically
without us having to be logged in. Even more than that, if they happen to crash, we want them to restart automatically. To do this, we will run them as a service.

On Ubuntu 16.04 I use the service manager called [systemd](https://wiki.archlinux.org/index.php/Systemd). This allows me to
configure a service defined by an arbitrary command. It also allows the automatically automatic boot start and restart we are looking for.

To create a new service you need to create a new service file inside */etc/systemd/system*.

I like to name my services after the domain they are intented for so I created a file called *drewag.me.service*:

    // bash
    sudo nano /etc/systemd/system/drewag.me.service

For our purpose, there are three parts to this file. First we have the "Unit" section:

    // bash
    # /etc/systemd/system/drewag.me.service
    [Unit]
    Description=Drewag.me Blog
    After=network.target

Here we set a human readable description of the service, in this case I have it set as "Drewag.me Blog". Next, with
the `After` variable, we indicate that we don't want this service to start until after the network interfaces are
ready.

The following section is the "Service" section that defines the most critical configurations:

    // bash
    # /etc/systemd/system/drewag.me.service
    [Service]
    User=www-data
    Restart=on-failure
    RestartSec=90
    WorkingDirectory=/var/www/drewag.me
    Environment=LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/var/www/drewag.me/.build/release/
    ExecStart=/var/www/drewag.me/.build/release/drewag.me server 8080

With the first variable I indicate that I want the service to run as the "www-data" user. This addresses the concern of what permissions the program will have.
I lock down the permissions of *www-data* as much as I can. Next, I ask that the service automatically restart when it fails and specify it should restart after 90
seconds. The `WorkingDirectory` variable defines where the program is run from. I like to have my web services run from the */var/www/* directory as that is a
conventional place to put websites and web services. It is important that my program is run from that directory because there are assets in that directory that
the program needs access to. I have also found that some of the third party packages I use need a properly defined *LD_LIBRARY_PATH* variable, presumably because
they have dynamic libraries they are linking to. That is what the `Environment` variable is setting. Finally, I use the `ExecStart` variable to define the command
I want executed to start the service. I specify the full path to where the binary is compiled and pass any relevant arguments. My example command starts up a server
on port 8080, but these arguments are specific to how I developed my program; yours will almost certainly differ.

The final section we need is the "Install" section.

    // bash
    # /etc/systemd/system/drewag.me.service
    [Install]
    WantedBy=multi-user.target

This specifies when we want our service installed. To be honest, I only have `multi-user.target` because I have seen it used in lots of examples and it has
worked for me.

Once that is setup, you can start your service by running:

    // bash
    sudo service drewag.me start

Now your service will run in the background and automatically restart if necessary.

Gracefully Handling Downtime
----------------------------

Last is the part of my configuration that I am most proud of. Our services may restart automatically but there will still be 90 seconds there will it will be down
and it is possible that it will fail to start back up. During those down times, I want a better response for users than the default "503 Service Unavailable"
that apache will return. Instead, I have Apache serve up a static page telling my users that the site is down and should be up shortly.

To do this, I will use a feature of Apache called [balancers](https://httpd.apache.org/docs/2.4/mod/mod_proxy_balancer.html). They are primarily intended for larger websites that have so much traffic that they need multiple servers
to handle the load. Those sites put a balancer in front of all their servers in order to distrubute traffic evenly, which minimizing the possiblity of a single server being overwhelmed. For our purposes, we want to
use a feature of balancers that allows specifying a fallback server in the scenario where the main server does not respond.

For my example, I will show an HTTP configuration but the same applies for the SSL configuration. First thing we want to do is setup our static page. We can do this in Apache:

    // bash
    # /etc/apache2/sites-available/dev.drewag.me
    Listen 8082
    &#60;VirtualHost *:8082>
        AliasMatch "^/.+$" "/var/www/dev.drewag.me/site-down.html"
    &#60;/VirtualHost>

This is a very simple static site that simply serves all traffic from the site-down.html file inside my service's code base. There are definitely more advanced things you can do, but this
serves my purposes well. Keep in mind though, if you are using external css, image, or javascript files, they will not be available. If you still need those, I will
leave it up to you to research configuring Apache to serve them.

Now all we need to do is pass our web requests through a balancer that will use port 8082 as a backup:

    // bash
    # /etc/apache2/sites-available/dev.drewag.me
    &#60;VirtualHost *:80>
        ServerName dev.drewag.me

        &#60;Proxy balancer://hotcluster>
            BalancerMember http://localhost:8081 timeout=15 retry=30
            BalancerMember http://localhost:8082 status=+H
        &#60;/Proxy>

        ProxyPreserveHost On
        ProxyPass / balancer://hotcluster/
        ProxyPassReverse / balancer://hotcluster/
    &#60;/VirtualHost>

Here we have added in a configuration for a balancer called "hotcluster" and we are directing traffic through
the proxy there instead of directly to our service (notice the changes to the `ProxyPass` and `ProxyPassReverse` commands).

In the balancer we specified two members. The first is the real service. It is set to timeout at 15 seconds and if it is detected
down, the balancer will try to use it again after 30 seconds. All traffic in the meantime will fallback to our static site on port
8082. The `status=+H` part of the command specifies that it is a "hot standby" simply meaning that traffic should not be sent to
it unless all the main members are not returning a response.

For this configuration to work, I had to make sure the following Apache mods were enabled:

    // bash
    sudo a2enmod http proxy_http proxy_balancer lbmethod_byrequests

After enabling them, restart apache again:

    // bash
    sudo service apache2 restart

Now you should be able to take down your service and when you visit your domain name, you should see your static page. To stop your service you can
issue the command:

    // bash
    sudo service drewag.me stop

This technique allows us to handle the reality that compiled programs, like those written in Swift, are more likely to crash than traditional web technologies. Swift may
be a very safe language but other web technologies tend to avoid completely crashing at all costs because of this very problem. That leads me to my last piece of advice.

Tracking Your Server's Reliablity
---------------------------------

This is relevant for all web services, but it is especially important when we are on the cutting edge of new technologies. We want to be immediately aware of any problem
with our service before many users experience it. We don't want to be hearing from users that our site is down. There are several services that will monitor the status of
your site but my favorite is called [Pingdom](https://www.pingdom.com). It has other more advanced features, but I use its ability to make a request to my domain every minute
and notify me if it ever recieves an error. I had a bug at one point that was causing my service to crash occasionally, but because the service automatically restarts I was
never seeing the problem. It was Pingdom that showed me that it was occasionally recieving an error and that lead me to look through my logs and figure out what the problem was.
I discussed the problem I ran into on my post about [Filling Holes in Swift on Linux](/posts/2017/01/18/filling-holes-in-swift-on-linux).

Conclusion
-----------

Ultimately, there are a lot of ways you could deploy your services. [Golang](https://golang.org) is another compiled language that has been around longer than Swift and so that
community will also have solutions. This is a very large field with people who dedicate their careers to managing servers for online websites and services. However, this confuguration
is relatively simple, it has served me well in small scale environments, and it definitely has the potential to scale up much larger. I hope you found some value in it!
