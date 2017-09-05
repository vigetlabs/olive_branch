# OliveBranch

[![Code Climate](https://codeclimate.com/github/vigetlabs/olive_branch.png)](https://codeclimate.com/github/vigetlabs/olive_branch)
[![Build Status](https://travis-ci.org/vigetlabs/olive_branch.svg?branch=master)](https://travis-ci.org/vigetlabs/olive_branch)

This gem lets your API users pass in and receive camelCased or dash-cased keys, while your Rails app receives and produces snake_cased ones.

## Install

1. Add this to your Gemfile and then `bundle install`:

        gem "olive_branch"

2. Add this to `config/applcation.rb`:

        config.middleware.use OliveBranch::Middleware

## Use

Include a `X-Key-Inflection` header with values of `camel`, `dash`, or `snake` in your JSON API requests.

For more examples, see [our blog post](https://www.viget.com/articles/introducing-olivebranch).


* * *

OliveBranch is released under the [MIT License](http://www.opensource.org/licenses/MIT). See MIT-LICENSE for further details.

* * *

<a href="http://code.viget.com">
  <img src="http://code.viget.com/github-banner.png" alt="Code At Viget">
</a>

Visit [code.viget.com](http://code.viget.com) to see more projects from [Viget.](https://viget.com)
