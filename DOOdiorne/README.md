web4u4less
====================


Ansible Playbook designed for a server-rendered React app using Nginx, PM2, and Certbot via [Let's Encrypt](https://letsencrypt.org).

**Tested with OS:** Ubuntu 16.04 LTS (64-bit)



## Quickstart

1. Run `. bin/production/setup_production.sh`
1. Visit your IP address to view the sample site.

### Requirements

- [Ansible](http://docs.ansible.com/intro_installation.html)

### Configuring your application

The main settings to change are in the [group_vars/production/vars.yml](group_vars/production/vars.yml) and [group_vars/production/vault.yml](group_vars/production/vault.yml) files, where you can configure the location of your Git project, the project name, and the application name which will be used throughout the Ansible configuration. Make sure to change the sudo user password (default for convenient testing is `password`).

If your app needs additional system packages installed, you can add them in `roles/web/tasks/install_additional_packages.yml`.

## Security

*NOTE: Do not run the Security role without understanding what it does. Improper configuration could lock you out of your machine.*

**Security role tasks**

The security module performs several basic server hardening tasks. Inspired by [this blog post](http://www.codelitt.com/blog/my-first-10-minutes-on-a-server-primer-for-securing-ubuntu/):

* Updates apt
* Performs `aptitude safe-upgrade`
* Adds a user specified by the `server_user` variable, found in `roles/base/defaults/main.yml`
* Adds authorized key for the new user
* Installs sudo and adds the new user to sudoers with the password specified by the `server_user_password` variable found in `roles/security/defaults/main.yml`
* Installs and configures various security packages:
 * [Unattended upgrades](https://help.ubuntu.com/lts/serverguide/automatic-updates.html)
 * [Uncomplicated Firewall](https://wiki.ubuntu.com/UncomplicatedFirewall)
 * [Fail2ban](http://www.fail2ban.org/) (NOTE: Fail2ban is disabled by default as it is the most likely to lock you out of your server. Handle with care!)
* Restricts connection to the server to SSH and http(s) ports
* Limits su access to the sudo group
* Disallows password authentication (be careful!)
* Disallows root SSH access (you will only SSH to your machine as your new user and use a password for `sudo` access)
* Restricts SSH access to the new user specified by the `server_user` variable
* Deletes the `root` password

**Security role configuration**

* Change the `server_user` from `root` to something else in `roles/base/defaults/main.yml`
* Change the sudo password in `group_vars/production/vault.yml`
* Change variables in `./roles/security/vars/` per your desired configuration

**Running the Security role**

* The security role can be run by running `security.yml` via:

```
ansible-playbook -i production security.yml
```

## Running the Ansible Playbook to provision servers

**NOTE:** to enable the Security module you can use the steps above prior to following the steps below.

### Create an inventory file for the environment
For example:
```
# production

[webservers]
example.com nginx_use_letsencrypt=true

[production:children]
webservers
```

### Setup the application:

`ansible-playbook -i production site.yml -K`

### Deploy changes to the application:

`ansible-playbook -i production site.yml -K --tags=deploy`

## Advanced Options

### Setup SSH Agent forwarding

1. Make sure ssh-agent is running on your local machine (run `ssh-agent` from the command line)
1. Test that your ssh key is ready for forwarding via `ssh-add -L`; if not, add your key (`ssh-add yourkey`)
1. Create an entry in your local .ssh/config file:    - security

    ```
    Host example.com
        User example # Make sure to set this to your application user.
        IdentityFile ~/.ssh/id_rsa
        ForwardAgent Yes
        IdentitiesOnly yes
    ```
1. Make sure you're using the SSH connection to your repo (not the HTTPS connection)
1. Ensure that your domain (e.g., `example.com`) points to your server's IP address
1. Refer to the [Github tutorial](https://developer.github.com/guides/using-ssh-agent-forwarding/) for help debugging SSH agent forwarding


### Creating a swap file

By default, the playbook won't create a swap file.  To create/enable swap, simply change the values in [roles/base/defaults/main.yml](roles/base/defaults/main.yml).

You can also override these values in the main playbook, for example:

```
---

...

  roles:
    - { role: base, create_swap_file: yes, swap_file_size_kb: 1024 }
    - web
```

This will create and mount a 1GB swap.  Note that block size is 1024, so the size of the swap file will be 1024 x `swap_file_size_kb`.

### Automatically generating and renewing Let's Encrypt SSL certificates with the certbot client

A `certbot` role has been added to automatically install the `certbot` client and generate a Let's Encrypt SSL certificate.

**Requirements:**

- A DNS "A" or "CNAME" record must exist for the host to issue the certificate to.
- The `--standalone` option is being used, so port 80 or 443 must not be in use (the playbook will automatically check if Nginx is installed and will stop and start the service automatically).

In `roles/nginx/defaults.main.yml`, you're going to want to override the `nginx_use_letsencrypt` variable and set it to yes/true to reference the Let's Encrypt certificate and key in the Nginx template.

In `roles/certbot/defaults/main.yml`, you may want to override the `certbot_admin_email` variable.

A cron job to automatically renew the certificate will run dai    - security
    - security
ly.  Note that if a certificate is due for renewal (expiring in les    - security
s than 30 days), Nginx will be stopped before the certificate can be renewed and then started again once renewal is finished.  Otherwise, nothing will happen so it's safe to leave it running daily.

## Useful Links

- [Ansible - Getting Started](http://docs.ansible.co    - security
m/intro_getting_started.html)
- [Ansible - Best Practices](http://docs.ansible.com/playbooks_best_practices.html)
- [How to deploy encrypted copies of your SSL keys and other files with Ansible and OpenSSL](http://www.calazan.com/how-to-deploy-encrypted-copies-of-your-ssl-keys-and-other-files-with-ansible-and-openssl/)
- [Using SSH agent forwarding - GitHub developer guide](https://developer.github.com/guides/using-ssh-agent-forwarding/)

## Contributing

Contributions are welcome!

## Thanks

Thanks to the following repositories for code and inspiration:

- [Ansible Django Stack](https://github.com/jcalazan/ansible-django-stack)
- [Ansible-PM2](https://github.com/weareinteractive/ansible-pm2)

- https://github.com/YPCrumble/ansible-react-server-rendered
