# Upgrade_ISE_in_Hybrid_Cloud/notifications

I use three different notification methods throughout this repository:
- [sSMTP](#ssmtp)
- [Swaks - Swiss Army Knife for SMTP](#swaks---swiss-army-knife-for-smtp)
- [NTFY](#ntfy)

## sSMTP
Using sSMTP in my local linux install from which I run my Ansible Playbooks, I can send email from the command line. This is a pretty simple install and is easy to use.

## Configuration

Of course, update the APT repositories

```sh
apt-get update -y
```

By default, the sSMTP package is included in the Ubuntu 20.04 and 22.04 default repository. You can install it by just running the following command

```sh
apt-get install ssmtp -y
```

Once installed, all you need to do is configure the `ssmtp.conf` file found in  `/etc/ssmtp/`

```sh
sudo nano /etc/ssmtp/ssmtp.conf
```

Add the sent From email address at the `root` entry.  The SMTP Server details will need to be entered, including any authentication information.  If your SMTP server does not use port 25 to send mail, then be sure to enable `UseSTARTTLS`

```ssmtp.conf
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=email@address.com

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
mailhub=mail.domain.com
AuthUser=email@address.com
AuthPass=<password>
# Where will the mail seem to come from?
#rewriteDomain=

# The full hostname
hostname=Computer.hostname

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=YES
UseSTARTTLS=YES
```

That's it.  It's configured!  If you're using Gmail, the settings you need are:

```sh
AuthMethod=LOGIN
UseTLS=YES
UseSTARTTLS=YES
mailhub=smtp.gmail.com:587
```

## Using sSMTP

How to test you have configured ssmtp properly
Once you’ve configured sSMTP it’s time to try and send an email. The simplest way to do this is to run sSMTP in a terminal with a recipient email address. So:

```sh
ssmtp recipient_email@example.com
```

sSMTP will then wait for you to type your message, which needs to be formatted like this:

```sh
To: recipient_email@example.com
From: myemailaddress@gmail.com
Subject: test email

Hello World!
```

Note the blank like after the subject field. Everything you type from the Hello World! onwards is the body of the email. Once you have finished composing your email hit `Ctrl-D`. After a few seconds sSMTP will send the message.

Obviously you don’t want to be doing stuff from the Command Line each time you want to send an email so it’s better to write a little text file containing the email contents. These are the `.txt.` files that you see in this folder.  Format the text files the same way you would for the terminal command

```vba
To: recipient@isedemolab.com
From: sender@isedemolab.com
Subject: Your ISE 3.2 Deployment is DESTROYED!

All nodes have been DESTROYED


'     _ ._  _ , _ ._     
'   (_ ` ( `  )_  .__)   
' ( (  (    )   `)  ) _)
'(__ (_   (_ . _) _) ,__)
'    `~~`\ ` . /`~~`     
'         ;   ;          
'________/_ __ \_________
```

Once the email text file is saved, the command to send it is

```sh
ssmtp recipient@isedemolab.com < 32_deployment_destroyed.txt
```

So I use the `ansible.builtin.shell` module to create a task whenever I want a notification sent

```sh
    - name: Send Email Notification
      ansible.builtin.shell:
        cmd: "ssmtp charlie@isedemolab.com < 32_deployment_destroyed.txt"
```

You can even create a standalone playbook to insert into your project.  Take a look at the `.yaml` files in this folder to see how.

## Swaks - Swiss Army Knife for SMTP

Swaks is a featureful, flexible, scriptable, transaction-oriented SMTP test tool written and maintained by John Jetmore. It is free to use and licensed under the GNU GPLv2. Features include:

SMTP extensions including TLS, authentication, pipelining, PROXY, PRDR, and XCLIENT
Protocols including SMTP, ESMTP, and LMTP
Transports including UNIX-domain sockets, internet-domain sockets (IPv4 and IPv6), and pipes to spawned processes
Completely scriptable configuration, with option specification via environment variables, configuration files, and command line
The official project page is https://jetmore.org/john/code/swaks/.

The configuration guide can be found at https://jetmore.org/john/code/swaks/latest/doc/ref.txt

## Why I'm Using Swaks

I wanted to be able to add the .json file from the ISE Upgrade PreChecks as an attachment to an email notifying the user when the checks had all finished and to show the result of the PreChecks.  Since JSON is technically formatted on a single line, this is too much data to add to a taxt-based email body and only the first check is included before the rest is cut off.  I tried so many methods to be able to attach the .json file and this was ultimately the easiest to set up and to use.  I tried:

- sSMTP
- MPACK
- MUTT
- sendmail
- mailx

before I decided that Swaks was the best for what I needed.

## Installation

Swaks can be installed using the following commands

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y swaks
```

## Configuration

First, create a file to set environment variables so that sensitive information is not saved in playbooks.  I put mine in `~/.secrets/email.sh`

```sh
export EMAIL_FROM='ansible@domain.com'	# The email address that Ansible will use to SEND
export EMAIL_SERVER='mail.domain.com'   # The email SMTP server to use
export EMAIL_PROTOCOL='SMTP'            # The email protocol used
export EMAIL_PORT='25'                  # The port used to send email
export EMAIL_USER='ansible@domain.com'	# The username for SMTP authentication
export EMAIL_PASSWORD='password'        # The password for SMTP authentication
```

Load the variables into your environment

```sh
source ~/.secrets/email.sh
```

If you want to verify that the variables loaded, you can check by using this command

```sh
env | grep EMAIL
```

That's it!  Swaks is fully configured.

## Using Swaks

The reason that Swaks is so easy to configure is that you pass the connection information every time you send an email.  Here is the command I use in my `admin_1\01-run_prechecks.yaml` playbook.  Note that the environment variables are called by using `${VARIABLE}`.

To add files for the `--body` and `--attach` options, prepend the file path with `@`.

```sh
    - name: Email the PreCheck Report File
      ansible.builtin.shell:
        cmd: >
          swaks -tlsc 
          --to charlie@isedemolab.com 
          --from ${EMAIL_FROM} 
          --server ${EMAIL_SERVER} 
          --port ${EMAIL_PORT} 
          --auth LOGIN 
          --auth-user ${EMAIL_USER} 
          --auth-password ${EMAIL_PASSWORD} 
          --auth-hide-password 
          --header "Subject: Your ISE 3.2 Upgrade Report Results" 
          --header "Content-Type: text/plain; charset=UTF-8" 
          --body @../notifications/precheck_report.txt 
          --attach @../notifications/precheck_report.json 
          --attach-name precheck_report.json
```

## NTFY

### Push notifications made easy
> ntfy (pronounced notify) is a simple HTTP-based pub-sub notification service. It allows you to send notifications to your phone or desktop via scripts from any computer, and/or using a REST API. It's infinitely flexible, and 100% free software.




```
    - name: Send Push Notification
      ansible.builtin.shell:
        cmd: |
          curl \
            -H "Title: Your 3.2 deployment has successfully been provisioned" \
            -H "Priority: urgent" \
            -H "Tags: bell,loudspeaker" \
            -d "Before anything else, please log in to the WebGUI" \
            ntfy.sh/ise-ansible 
```

![ntfy](https://github.com/ISEDemoLab/Upgrade_ISE_in_Hybrid_Cloud/blob/main/images/ntfy.png){width=516 height=1118}

## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>