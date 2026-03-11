# Website and Ecommerce application

![Beautiful Art Piece by Artist](https://github.com/AngelLozan/aoj/blob/master/app/assets/images/photo1.jpeg?raw=true)

This is an application to showcase the work of an artist and help them manage their online store by removing the need to utilize third parties to sell their work.

App here: https://theartofjaleh.com/

## Account administration

In this case, I'm using simple account administration restricted to one user. This is populated via the rails console in production or test. This allows for the visiting and purchase of art while restricting the login and administration of the site to one user. The user, once created, can change their password and email address.

## GHA workflows
- Currently not used as unable to simulate reliably a cloudinary connection. Tests pass and display images locally, but not in GHA. Move worflows from ./test to ./github/ to enable.

## Artwork
All artwork is some of the original mockups used by the artist to give them more of a feeling of what the site will look like.

## Testing
Due to the nature of the active storage of the paintings in the test, you will need to run `rails db:test:purge` before running `rails test` to ensure that the tests run properly.

- Paypal sandbox cards: Use current month and one year in advance ex: 10/24 for the expiration date.

## Deployment to Digital Ocean (start in terminal):
- Create a droplet with rails marketplace app
- SSH into droplet ` ssh root@<ip of droplet>` or `ssh <short name >` if you have set up a config file in .ssh.
- Optional: touch config in .ssh local machine with the below so you can `ssh <app name>`
```
Host <name>
  User root
  HostName <ip of droplet>
  IdentityFile ~/.ssh/<name>
```
- Save a copy of your rails password and Postgres password in a safe place. You will need them later when you populate the application.yml file. Password is used throughout to clone repos, use sudo as rails user, etc.

- Update packages: `sudo apt-get update`
- Change default rails project folder:

`nano /etc/nginx/sites-available/rails`

- change `root /home/rails/rails_app/public;` to `root /home/<app name>/public;` (named after github repo name)

- Also add the following to your server location / block:

```
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```
- Change server name to your domain name: `server_name <domain name> www.<domain name>;`

- Change working dir similarly:
`nano /etc/systemd/system/rails.service`

- Change `WorkingDirectory=/home/rails/rails_app` to `WorkingDirectory=/home/<app name>` (named after github repo name)
n you have an account available, log in
- Change command to start server to include production environment: `ExecStart= /bin/bash -lc 'bundle exec puma -e production`

## Not in terminal, but in droplet dashboard:
- If you have a domain name, in the droplet console under "Domains" add your domain names as A records TTL 3600 and point it to the droplet IP address. Ensure you set up the name servers in your domain registrar to point to Digital Ocean's name servers:

  ```
  ns1.digitalocean.com
  ns2.digitalocean.com
  ns3.digitalocean.com
  ```
## Back to terminal:

- Give priviledges to rails user: `gpasswd -a rails sudo`
- Change into user in droplet CLI: `sudo -i -u rails` (Rails user is pre-existing on the marketplace image).
- Change directory up one level: `cd ../` to find the home and aoj directories



- GO to home directory `cd ..`
- Clone your repo: `git clone <repo url>`
- `sudo chmod 777 -R <app name>`
- `cd <app name>`
- Use rvm or ensure ruby installed
- `bundle install`
- `yarn install`
- Install figaro and use `bundle exec figaro install` to generate a `config/application.yml` file where you can store ENV variables previously hosted in a .env. This will manage environment variables for you in production. Potential error will show, but check to see if the file was created (usually is).
- Copy contents of .env into application.yml, but format as below:
```
EXAMPLE_ENV_VAR: <value>
```
- May need to remove existing `config/credentials.yml.enc` and re-generate the `master.key`: `EDITOR="nano" rails credentials:edit`
- For production, run below or remove the env assignment for dev.
- `RAILS_ENV=production bundle exec rake assets:precompile`
- `RAILS_ENV=production rails db:create`
-`RAILS_ENV=production rails db:migrate`
- `RAILS_ENV=production rails db:seed`

- Exit rails user and as root enable OpenSSH: `ufw allow OpenSSH`
- Obtain SSL certificate: `sudo certbot --nginx -d <domain name> -d <www.domain name>`
- Restart daemon: `sudo systemctl daemon-reload`
- Restart nginx: `sudo systemctl restart nginx`
- Then restart the server: `sudo systemctl restart rails.service`
- Reminder: always run `bundle`, `yarn`, and `assets:precompile` as the **rails** user (not root) to avoid permissions issues.
- View logs by changing into the rails user `sudo -i -u rails` and then `cd <app name>` and `tail -f log/production.log`

## Clean Redeploy (Recommended)
Use this flow to pull new code safely without breaking credentials.

1) Ensure credentials stay server-only (run once on server):
```
cd /home/<app name>
git update-index --skip-worktree config/credentials.yml.enc
```
If you ever *intend* to update credentials from GitHub, undo it with:
```
git update-index --no-skip-worktree config/credentials.yml.enc
```

2) Pull and deploy (server):
```
cd /home/<app name>
git fetch origin
git pull --ff-only

bundle install
yarn install
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart rails.service
sudo systemctl restart nginx
```

3) Verify:
```
sudo systemctl status rails.service
sudo systemctl status nginx
curl -i http://127.0.0.1/ -H "Host: <your-domain>"
```

## Node Version (for assets)
Some dependencies require **Node >= 20.19.0** (e.g. `chokidar@5`).

### Install NVM (server)
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.nvm/nvm.sh
```

### Install and use Node 20.19.0
```
nvm install 20.19.0
nvm use 20.19.0
nvm alias default 20.19.0
node -v
```

## Troubleshooting
- Permissions errors during assets compile usually mean a root-owned `tmp/` or `node_modules/`.
  - Fix: `sudo chown -R rails:rails /home/<app name>/tmp /home/<app name>/node_modules /home/<app name>/public /home/<app name>/log`
- If Rails won’t boot after deploy, check service logs:
  - `journalctl -u rails.service -b`
- If nginx returns 502, the app likely failed to start. Check:
  - `sudo systemctl status rails.service`
  - `tail -n 200 /home/<app name>/log/production.log`


## A note about Printify:
With a custom (API) store set up, printify does not directly handle the publishing process. Clicking the "publish" button will not initiate any action. However, you can retrieve the data of your created products through an API GET request and manually create and publish your products on your storefront.

Once you have completed this process, you can link the product page on your storefront to the corresponding product in Printify by using the "Set product publish status to succeeded" request mentioned in our Printify API Reference: https://developers.printify.com/#overview

If you encounter any products that are stuck and need to be unlocked, you can use the "Set product publish status to failed" request provided in our Printify API
apiteam[@]printify.com


## Troubleshooting:
- Using `git status` first to ensure you have no unstaged changes then `git fetch` and then `git pull` on the droplet to update the repo with the latest changes from the master branch. `git status` on the droplet will show you if you have any changes that need to be committed on the droplet and pertain primarily to hot-fixes done, `yarn.lock` and similar changes you do not want to commit from the repo to the droplet. 
- Issues with restarting the app: `journalctl -u rails.service -b` will give output of the logs for the service.
- See status of nginx and rails: `sudo systemctl status rails.service` and `sudo systemctl status nginx` to troubleshoot if there is anything wrong with the services.
