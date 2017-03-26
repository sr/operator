# Purple

A UI kit for Heroku's web interfaces. To get started, check out https://purple.herokuapp.com!

## Quickstart

### Developing

### Dependencies

1. node 0.10 (`node-sass` requires Node v.0.10~ and won't work with higher versions.)
2. npm
3. ruby >= 2.0.0

### New Releases

Please follow the instructions in the HIT repo when making a new release.

https://github.com/heroku/hit/blob/master/purple-deployment-instructions.md

### Spinning it up locally

```sh
npm install -g bower gulp harp
npm install
bower install
bundle install
foreman start
```

Now open [localhost:5000](http://localhost:5000) in your browser.

See the *Private Repo Resolution* section below.

#### Live development in bower package consumer

With this package installed locally, you can make changes to the source and have them reflected on the fly in a bower-based consumer. There is no need to manage and push to remote branches to test.

1. in your purple directory run `bower link`
2. then run `gulp watch` to automatically compile changes
3. `cd` into your other bower-based project
4. run `bower link purple`
5. ensure that any task runner you have (grunt, gulp, etc.) is watching for changes to your bower_components directory and recompiling that projects own assets. In grunt this would look like:

  ```
  watch: {
      purpleScripts: {
          files: ['bower_components/purple/dist/js/*.js'],
          tasks: ['concat:bower']
      },
      styles: {
          files: ['assets/styles/**/*.scss', 'bower_components/purple/dist/css/*.css'],
          tasks: ['sass']
      }
  }
  ```
6. To revert back to that project's `bower.json` specified version of purple, run `bower uninstall purple` and then `bower install`

Now you should be all set.

----------------------------

### Private Repo Resolution

As long as this is a private repo, we must take a few steps in order to be able to smoothly deploy this on the Heroku platform

#### Local setup

Make sure you have [GitHub password caching setup](https://help.github.com/articles/caching-your-github-password-in-git).

If you have enabled 2-Factor Auth on GitHub (and you should!) your GitHub password will not authenticate `https` remotes. You must get an OAuth token to do so. Follow these steps:

* On GitHub, open your [Account settings](https://github.com/settings).
* Go to the Applications tab.
* Generate a new Personal Access Token. Name it appropriately.
* Copy the generated token and paste it into some secure password manager like 1Password or LastPass.
* When you try to clone a `https` repo, paste in your token rather than typing your GitHub password.
* The git `credential.manager` configured above will store your OAuth token for all future HTTPS interaction with GitHub.

#### Production Setup

In order to access this repo via bower in production, do the following (assuming you already have a buildpack set):

1. `heroku buildpacks:add https://github.com/timshadel/heroku-buildpack-github-netrc`
2. ask Jack to generate a new read-only token for you from the heroku github *read-only* team Alternatively, create a new github user, add them to the *read-only* github team and then generate a personal access token for them.
3. run `heroku config:set GITHUB_AUTH_TOKEN=<my-read-only-token>` for the production app

-----------------------------------------

### Rails setup

#### Using Sprockets

Ruby projects can include purple from our internal gem server. Be sure to specify the correct source.

```ruby
gem 'purple'
```

Run `bundle install` and add the following line to your `application.scss` or equivalent file:

```scss
@import 'purple/rails';
```

Also add the following line to your `application.js` or equivalent file:

```javascript
//= require purple/rails
```

That's all!

Notice: you'll still need to configure Github password caching.

#### Deploying

1. run `heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git` to setup multi buildpacks
2. create a `.buildpacks` file and add:

  ```
  https://github.com/timshadel/heroku-buildpack-github-netrc.git
  https://github.com/heroku/heroku-buildpack-ruby.git
  ```
3. Follow the [directions here](https://github.com/heroku/purple#private-repo-resolution) to allow bower to download from the private purple repo.

-------------------------------------

### CDN

The fastest way to get started is to use [our CDN](/heroku/cdn):

```html
<link rel="stylesheet" href="//www.herokucdn.com/purple/1.0.0/purple.min.css">
<script src="//www.herokucdn.com/purple/1.0.0/purple.min.js"></script>
```

For a list of available purple versions, see [herokucdn.com/purple/](http://www.herokucdn.com/purple/).

### Bower

You can install Purple with Bower to vendor it in:

```
bower install git@github.com:heroku/purple.git
```
