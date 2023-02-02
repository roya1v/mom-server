<p align="center">
  <img src="logo.png" width="160" height="160">
</p>

## MOM - Multifunctional Organization Machine

When I first stated living on my own I thought to myself "Why not keep try of all my stuff at home using an app on my phone?!". That's why I'm creating MOM.

This is the MOM server app, there is also an iOS app which is TBD.

## Usage

So the app itself is written in Swift using Vapor. We use Postgresql as a db and AWS S3 for storing images (actually it's [MinIO](https://min.io) which should be compateble with S3). So the easiest way to spin it up would be to use docker compose.

So just clone the repo and run `docker compose up --detach app` and also run `docker compose run migrate` to create all db tables.

