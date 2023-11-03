# Website and Ecommerce application

![Beautiful Art Piece by Artist](https://github.com/AngelLozan/aoj/blob/master/app/assets/images/photo1.jpeg?raw=true)

This is an application to showcase the work of an artist and help them manage their online store by removing the need to utilize third parties to sell their work.

View development app at: http://209.97.136.205/

## Account administration

In this case, I'm using simple account administration restricted to one user. This is populated via the rails console in production or test. This allows for the visiting and purchase of art while restricting the login and administration of the site to one user. The user, once created, can change their password and email address.

## GHA workflows
- Currently not used as unable to simulate reliably a cloudinary connection. Tests pass and display images locally, but not in GHA. Move worflows from ./test to ./github/ to enable.

## Artwork
All artwork is some of the original mockups used by the artist to give them more of a feeling of what the site will look like.

## Testing
Due to the nature of the active storage of the paintings in the test, you will need to run `rails db:test:purge` before running `rails test` to ensure that the tests run properly.

## Deployment to Digital Ocean:
- Create a droplet with rails marketplace app
- SSH into droplet
- Optional: touch config in .ssh local machine with the below so you can `ssh <app name>`
```
Host <name>
  User root
  HostName <ip of droplet>
  IdentityFile ~/.ssh/<name>
```
- Change default rails project folder:

`nano /etc/nginx/sites-available/rails`

- change `root /home/rails/rails_app/public;` to `root /home/<app name>/public;`

Change working dir similarly:
`nano /etc/systemd/system/rails.service`

- change `WorkingDirectory=/home/rails/rails_app` to `WorkingDirectory=/home/<app name>`

- Give priviledges to rails user: `gpasswd -a rails sudo`
- Change into user in drop cli: `sudo -i -u rails`

- GO to home directory `cd ..`
- Clone your repo: `git clone <repo url>`
- `sudo chmod 777 -R app`
- `cd app`
- Use rvm or ensure ruby installed
- `bundle install`
- yarn
TG continued

