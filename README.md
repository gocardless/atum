# Atum

Ruby HTTP client generator for JSON APIs represented with JSON schema, forked
from [Heroics](https://github.com/interagent/heroics).

## Installation

Add this line to your application's Gemfile:

    gem 'atum'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install atum

## Usage

### Generating a client

Atum generates an HTTP client from a JSON schema that describes your JSON
API. Look at [prmd](https://github.com/interagent/prmd) for tooling to help
write a JSON schema.  When you have a JSON schema prepared you can generate a
client for your API:

```
$ atum MyApp schema.json https://api.myapp.com
```

This will output a client into a new `my_app` folder, in the current directory,
unless that folder exists.

### Passing custom headers

If your client needs to pass custom headers with each request these can be
specified using `-H`:

```
atum -H "Accept: application/vnd.myapp+json; version=3" MyApp schema.json https://api.myapp.com
```

Pass multiple `-H` options if you need more than one custom header.

### Generating API documentation

The generated client has [Yard](http://yardoc.org/)-compatible docstrings.
You can generate documentation using `yard`:

__not convinced this is actually correct now it's a directory?__
```
yard doc -m markdown my_app
```

This will generate HTML in the `docs` directory.  Note that Yard creates an
`_index.html` page won't be served by Jekyll on GitHub Pages.  Add a
`.nojekyll` file to your project to prevent GitHub from passing the content
through Jekyll.

### Handling failures

The client uses [Faraday](https://github.com/lostisland/faraday) for doing the
HTTP requests, which chooses the most appropriate library for the runtime and
other cool things. As such, you may encounter Faraday errors, which are mostly
subclasses of `Faraday::ClientError`.

```ruby
begin
  client.app.create('name' => 'example')
rescue Faraday::ClientError => error
  puts error
end
```

## Supporting Ruby < 2.0.0
This gem only directly supports Ruby >= 2.0.0 out of the box due to our use of
Enumerable::Lazy for lazy loading of paginated API resources.

However, support for previous ruby versions can be added using a gem such as
[backports](https://github.com/marcandre/backports).

1. Add backports to your Gemfile
   ```gem 'backports'```
2. Require lazy enumerables
   ```require 'backports/2.0.0/enumerable/lazy.rb'```

## Contributing

1. [Fork the repository](https://github.com/isaacseymour/atum/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request
