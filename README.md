# Website and Ecommerce application

![Beautiful Art Piece by Artist](https://github.com/AngelLozan/aoj/blob/master/app/assets/images/photo1.jpeg?raw=true)

This is an application to showcase the work of an artist and help them manage their online store by removing the need to utilize third parties to sell their work.

## Account administration

In this case, I'm using simple account administration restricted to one user. This is populated via the rails console in production or test. This allows for the visiting and purchase of art while restricting the login and administration of the site to one user. The user, once created, can change their password and email address.

## GHA workflows
- Currently not used as unable to simulate reliably a cloudinary connection. Tests pass and display images locally, but not in GHA. Move worflows from ./test to ./github/ to enable.
