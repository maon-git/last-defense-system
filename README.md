# last-defense-system

This repository contains User-Agent lists and IPv4 addresses to block unwanted crawlers, bat robots, suspicious spiders, junk scraper, malicious spammers, and unauthorized access including DDoS attack. 

—This makes your arsenal iron-wall and protected, like a magical mithril-shield that bounces back monsters with ease.

However, this is not the final network security tool used by web professionals, nor is it special fantasy. It's just a first choice.

An ordinary suit that anyone can easily equip will become the armor of legend. Let's overcome our daily battles against threats and also get safety and peace together...

## Introduction

It is intended for use in Japan, but since it is a classic method that everyone is familiar with, it may be freely modified and adapted to suit each user's desired environment.

Tested under Apache 2.4 environment on StarServer, assuming web hosting service can run cron, handle shell scripts, php, and htaccess.

By executing cron, the block list prepared in advance and the Japanese domestic IP list obtained from APNIC are combined, formatted, and output as htaccess.

It is capable of blocking access to most bots and spammers, except for Google.

Because of its very simple and straightforward mechanism, this long README is clearly the starring actor compared to the main files.

Note: In the future, Google aims to replace existing user-agents in browsers with a completely different specification, and other companies seem to have agreed to do so, but for the time being, UA restrictions will continue to function effectively.

## How to use

Upload the following files to the server. In this example, place them in the directory /home/hogehoge/hogehoge.domain/public_html/cron/.

* block_ua.txt - Define the UA to be blocked here.
* block_ip.txt - Define remote hosts and IPs to be blocked here.
* get_ip.php - combines the above two lists with the domestic IP list obtained from APNIC.
* jpip_get.sh - when executed, calls the above php and outputs as htaccess

By running jpip_get.sh by cron, it is possible to update the block list periodically.

Note that the file paths and other information in each file should be rewritten to suit your environment.

At the very least, even with only the block_ua and block_ip lists, or only the domestic IP list, it is possible to sufficiently block unwanted access.

NOTE: So in other words, a block list generated from 3 lists by php is like wearing ADAMANTITE-GOGGLES in an ORICHALCONE-ROOM, waiting for visitors. But it will surely satisfy those who prefer tranquility.

Examples of use in StarServer are described separately below.

## Traditional misconceptions

Here again, we will look back at the UAs block list that has been used in the past.

### Misconceptions about carets

Many UAs block lists using SetEnvIf use caret, dot, asterisk, backslash, dollar sign, etc. as regular expressions for keywords.

However, at least for the purpose of blocking robots, and in the definition of variables in htaccess files, most of them do not need to be used.

For example, if you set the keyword for the UA to be rejected as "Google" enclosed in double quotation marks, all bots that contain the string 'Google' in their UA as a partial match will be blocked.

If you use a caret and set it to "^Google", it will only match if the UA has 'Google' at the beginning of the line.

What this means is that you can block "Googlebot/2.1 (+http://`www.google.com/bot.html`)" as an example of a real UA.

However, in the case of "Mozilla/5.0 (compatible; Googlebot/2.1; +http://`www.google.com/bot.html`)", the string 'Google' is not at the beginning of the line, so it cannot be blocked.

In other words, the definition of a caret is only to indicate the 'beginning of a line', and it is a misnomer to blindly add a caret to indicate the beginning of an individual bot name, such as 'Googlebot'.

Note: In this list, there are a few lines that are deliberately marked with a caret in order to prevent necessary services from being blocked, and conversely, to ensure that they are blocked.

### About Regular Expressions

As mentioned above, the SetEnvIf UA specification in htaccess is recognized as a partial match keyword from the beginning without any action. In other words, there is almost no need to use regular expressions to match various bots.

Also, there is no need to use backslash escaping for strings containing meta characters such as "/2.1; +http:" as long as the keyword is enclosed in double quotation marks.

Spaces do not need to be represented as \s either.

However, if the string contains round brackets, such as "/5.0 (compatible;", not escaping it will cause a status 500 server error.

However, there is little need to set such keywords that are treated as meta characters in regular expressions in the first place, and you can simply set only the alphanumeric characters of the UA you want to block.

### Features of SetEnvIf

Another advantage of using double quotation marks is that variables can be set correctly.

For example, if you write 'SetEnvIfNoCase User-Agent "like Gecko" blockua', the string 'like Gecko' with spaces will be set as true in the variable name "blockua".

However, if this is written as 'SetEnvIfNoCase User-Agent like Gecko blockua', the string 'like' will be set as true for both the variable names 'Gecko' and 'blockua'.

This is useful for setting multiple variables at the same time, but it also has the advantage of enclosing the keywords in double quotation marks to prevent unexpected mistakes.

Now, the reason for using SetEnvIfNoCase is, of course, to match case-insensitively.

In other words, there is no need to use regular expressions such as [gG]oogle, and it is possible to block any pattern of UA, whether gOOgle or GooGLE.

There is also a BrowserMatchNoCase (BrowserMatch) directive for setting variables for UA only. In this case, it is written as 'BrowserMatchNoCase "Google" blockua', which is somewhat simpler to specify than SetEnvIf.

Incidentally, there are often cases where block lists are described using 'SetEnv' (not SetEnvIf), which simply sets environment variables.

While it is possible to block bots as a result of SetEnv notation, the Apache 2.4 manual states that it is a directive that is executed late in the request processing stage.

This means that SetEnv is unsuitable for large block lists with many branches of processing, and the faster SetEnvIfNoCase (SetEnvIf) is recommended.

Reference to SetEnv and SetEnvIf:

https://elephantcat.work/2020/01/30/post-279/

## Contents of the block list

The block_ua list is a list of UA strings defined as variables, based on various crawler information available on the Internet, both ancient and modern, and based on the description rules mentioned above.

However, it is expected that there will be many duplicate matches due to partial matching of keywords. Also, there may be old UAs that are no longer in use.

In addition, even if it is a normal web service crawler rather than an annoying bot, most of them are basically blocked. Therefore, it is advisable to customize it individually as needed.

As for the block_ip list, it is intended to block remote hosts and IPs of the archive site, along with the UA set in the variable.

### About the Archive Site

It is well known that the so-called Web-Gyotaku, which is a major archive site in Japan, can be blocked by specifying the UA 'Megalodon' or by using meta tags such as 'noarchive'.

However, the situation has changed when it comes to blocking the world's major Wayback Machine (Internet Archive).

Even now, robots.txt often tries to block UAs such as ia_archiver, ia_archiver-web.archive.org, archive.org_bot, or alexa.

However, these bots are not in operation at this time and could not be blocked even if they were specified in htaccess.

As a result of analyzing the access log, the UA from archive.org was disguised as a very generic one that did not contain any specific string. This means that the only way to block it is to specify the IP address directly.

Currently, IPs at certain hosting companies are being used, but this is expected to change regularly.

Therefore, it would be most efficient to contact the site administrator directly by email and ask them to exclude your site from being crawled.

However, in that case, the archive.org administration team will come to check your site ownership, and you may need to temporarily unblock their IP.

For archive.is (and other affiliated domains), blocking by remote hosts will have little effect. And contacting the site administrator will almost certainly result in no response.

For example, reporting an abuse or alleging a DMCA violation may be successful as a countermeasure in no small measure.

In fact, the only way to block is by IP, but since IPs such as archive.is change quickly, it is difficult to identify them, making it difficult to block them completely.

Note that you should always set the SAMEORIGIN to prevent reprinting using iframe clickjacking. It may be enabled by default on most servers now, but if you need it, use the option below.

`Header always append X-Frame-Options SAMEORIGIN`

NOTES:

If you want your site to be indexed by search engines, but you don't want the cache to be saved, you should not forget the 'noarchive' in the meta tag. Some web capture sites will follow that description.

Other than that, 'noimageindex' is also useful to protect the copyright of your images, and setting 'nopin' for Pinterest is also a good idea.

Incidentally, it is well known that although it is not correct in terms of html syntax, at least Google's bot will read and properly interpret meta robots tag no matter where you write them except in the header.

This is the next best thing for users who use free blogging services and can't touch the header tags.

Also, needless to say, if you block them with the blocklist (.htaccess) you have created, they will no longer be able to read your robots.txt, so you will not need to pollute your txt file with their robot names in the future.

Reference to the IP information used in archive.is:

https://`blog.wolfs.jp/contents/archiveis-ipaddress/` (already closed)

## List of IPs used in the country

In view of the above, restrictions by UA or IP are not sufficient, at least to prevent malicious bots and access.

Therefore, the most effective and efficient method would be to allow only domestic IPs.
When used in conjunction with the aforementioned UA and IP blocking, it will bring peace at best and silence at worst to your site.

In the past, the method of limiting access IPs to domestic IPs was a bottleneck in terms of maintenance, as it is well known that the domestic IP list changes at irregular intervals.

Nowadays, however, it is possible for individuals to rent inexpensive, high-speed, and highly functional servers, making it possible to automate the process and almost eliminate the disadvantages.

I would like to take this opportunity to thank the following two sites for their usefulness and clarity in automating the process of obtaining a domestic IP and converting it to htaccess.

Reference for automatic IP acquisition and htaccess generation:

https://nodoame.net/archives/550 (origin)

https://zuntan02.hateblo.jp/entry/20140523/1400837726 (modified)

### Allowed Remote Hosts

As mentioned in the reference site above, restricting access to only domestic users used to be done by remote hosts.

However, for example, the blacklist method of rejecting certain countries often did not work well in reverse lookups, so the white list method of allowing .jp was adopted.

At the same time, there was a trend to allow bbtec.net and il24.net, which are not jp domains, but we have not added them to the list because they are almost obsolete now that domestic IPs can be accurately and easily obtained automatically.

In addition, I think most website operators want to use Google services even if their IP is overseas, so I have allowed google.com, googlebot.com, and Let's Encrypt as an exception.

## IP acquisition and file generation

The basic flow of the program is as shown in the reference site, but this time I modified the original get_ip.php to merge the pre-prepared UA and other blacklists into htaccess.

As a matter of fact, if access is restricted to domestic IPs only, blocking using UAs and the like may be unnecessary in most cases. However, because it is a very versatile program, I use it to achieve ultimate peace of mind for my website.
If it works this time, the cron on the server will run the jpip_get.sh shell script->php will get the IP from APNIC and generate the string from the UA and IP block list->automatically place the integrated .htaccess.

## Example on StarServer

When applying the above to a hosting service, the biggest obstacle is the difference in the specifications of each company's service, the difference in the UI part that users can tweak, and the difference in information.

For example, if it is an X server, which has many examples of use in various aspects, there is an abundance of information on the Internet.

However, unfortunately, the absolute amount of information available on StarServer is overwhelmingly insufficient in comparison.

Personally, I'm quite satisfied with the way it works for my normal use, but for the few StarServer users who also love it, I'd like to mention a few points that may cause you to get stuck.

Also, this works not only on the paid plans of StarServers, but also on the free servers that come with StarDomains.

Before setting up cron, the first thing that is missing in the reference site's php is the '#! /bin/php' at the beginning of the file line. Without this SHEBANG, also known as a 'spell', it will not work.

And the biggest problem with StarServer is the notation of the command part when setting up cron. If you can overcome this problem, 90% of the work is done.

### Run cron

Enter the execution date and time using asterisks, etc., as appropriate, and enter '/usr/bin/sh /home/hogehoge/hogehoge.domain/public_html/cron/jpip_get.sh' in the command part.

Of course, hogehoge is the 'server ID' in the UI of the server management tool, and the domain is the com, net, etc. that you have subscribed to.

And the most important part is the '/usr/bin/sh ' (including half-width spaces) before the sh file path. Without this, cron will not work.

Now, cron will run successfully, and if there is any error, an email will be sent to the address you set as the notification destination. 
(If it finishes successfully, you will not receive any notification, so please make sure that the htaccess file is ready.)

The content of the email at this time will help you deal with each situation.

1. If you see 'No permission', it means you do not have permission to execute the file. Please set the permission to 755 or something similar.

2. If you get 'Wrong interpreter: no such file or directory', it's a problem with the newline code, reopen the file with LF and save it.

3. If it is 'Warning: fopen(xxx.txt): failed to open stream: No such file or directory' and 'Warning: fclose() expects parameter 1 to be resource, boolean given', then the file path of the block list you prepared in advance is wrong.

The absolute path of the file on the StarServer is "/home/hogehoge/hogehoge.domain/public_html/cron/xxx.txt" (when placed in the cron folder directly under your domain).

4. if it is 'Notice: Undefined variable: jp_ip4', it literally means that the variable has not been defined. Before using a variable in a function, either initialize the variable with a space such as " " or define it with the required string.

5. If you get 'Parse error: syntax error, unexpected '$jp_ip4' (T_VARIABLE)', there is a full-width space somewhere, you forgot to comment it out, there is no semicolon at the end of the line, or some other formatting error. 
Please review it. This can also happen if you use php's auto-formatting tool.

Most of the errors are as described above, but needless to say, 4 and 5 are problems that rarely occur if the copy and paste php is running almost in its entirety.

If you don't receive any email notification when the date and time set in cron arrives, your .htaccess should be a blocklist with the contents of three files integrated into it. 
When the time to enjoy your coffee is over, check the contents of your file.

### Supplement: htaccess notation

Since we are using Apache version 2.4, we comply with it and describe RequireAll, RequireAny, (RequireNone).

In this case, anything that satisfies all of the following criteria will be allowed: 'Not a block UA, Remote Host & IP' and 'Either a domestic IP (or exception google host etc.)'.

The conventional 'order allow,deny' used up to Apache 2.2 can be used together. At least on the StarServer, we have confirmed that the blocking works without any problems.

However, there is a caveat. Basically, the contents of .htaccess files are interpreted in order from the top.

For example, if you specify some IP as 'deny from x.x.x.x' before the Require directive, then it will be denied, no matter how much it is allowed in the Require.

On the other hand, if you write 'allow from x.x.x.x' in a later line for something that was denied in Require, it will no longer be accessible because it is already denied.

In other words, when using conventional deny and allow together with Require, it seems to be absolutely true that deny, which is kicked and rejected when the condition is met, has stronger priority.

However, if you use multiple Require directives with conflicting content, you will see a variety of behavior.
For example, suppose you close a Require directive, and then write another one.

Then, if you try to deny an IP that was first allowed through RequireAll and None, but is later denied by RequireAll (ip not), the earlier permission will take precedence.

On the other hand, if you try to allow an IP that was initially denied with (None) with RequireAll(ip), the later permission will take precedence this time.

Note that if you try to allow or deny the backward directives with RequireAny instead of RequireAll, you will get a 500 error.

Therefore, in order to avoid unexpected behavior, it is necessary to have a rule that 2.2 system notations should not be mixed, and that Require directives should not be listed backwards again after they have been closed.

### Examples of application

By adding to get_ip.php as needed, it is also possible to centralize and generate various settings such as redirects, Header set X-Robots-Tag, ErrorDocument, etc. that you normally use.

However, it is easy to forget that redirects RewriteCond and RewriteRule have the effect of overriding redirects in higher level directories.

To prevent this from happening, use 'RewriteOptions Inherit' or similar. This option is also available for StarServer.

Care should be taken in each description, as access to a different directory may cause unintended redirects, or the assumed redirects may not be reflected.

Incidentally, variables set in SetEnvIF in the upper-level htaccess directory can be reused in the lower-level directory without having to be declared again. This was also confirmed on the StarServer.

Taking advantage of this property, it may be possible to distribute the blacklist management by .htaccess to each file to reduce the file size.

However, the presence of htaccess in multiple directories will cause requests to check each of them at the same time, which may result in performance degradation.

NOTE: If you are currently using Basic authentication, then the existing code must be inserted into the Require directive in the blocklist, as shown below.

example:
```
<RequireAll>
    AuthUserFile /var/www/html/.htpasswd
    AuthGroupFile /dev/null
    AuthName "Input ID and Password"
    AuthType Basic
    Require valid-user
［...]
</RequireAll>
```

Reference for taking over the SetEnvIf variable:

http://web.tvbok.com/web/server/htaccesssetenvifor.html

## Licence

Author: maon-git

This repository is licensed under the MIT license.

https://opensource.org/licenses/mit-license.php
