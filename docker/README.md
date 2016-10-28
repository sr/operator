# Pardot Docker Base Images

This repository houses the `Dockerfile`s for all of Pardot's **base images**.

The documentation over at [Docker Registry Conventions](https://confluence.dev.pardot.com/display/PTechops/Docker+Registry+Conventions) is a good place to learn all about base images and build images.

Periodically, and also on any commit pushed to master for this repository, Bamboo builds and pushes all of the base images defined here.

## HOWTOs

### Adding a new base image

1. Create a `Dockerfile`. Follow the directory structure of the existing images in the repository.
1. Add the images to the `BUILDS` array in `Rakefile`. The key is the tag name and the value is a `Build` object whose first argument is the first to build from. Additional options can be specified if needed.
1. Make a pull request and get a +1.
1. Merge away! Bamboo will build the base image once it lands in the master branch.

### Editing an existing base image

1. Find the `Dockerfile` for the base image.
1. Make a pull request and get a +1.
1. Merge away! Bamboo will build the base image once it lands in the master branch.
