# Atum

Ruby HTTP client generator for JSON APIs represented with JSON schema, forked
from [Heroics](https://github.com/interagent/heroics).

**WARNING: Atum is currently in early Alpha development. You have been warned.**

## Installation

    $ gem install atum

## Usage

### Generating Clients

Atum generates an HTTP client from a JSON schema that describes your JSON
API. Look at [prmd](https://github.com/interagent/prmd) for tooling to help
write a JSON schema.  When you have a JSON schema prepared you can generate a
client for your API.

To see a simple example, you can look at the [Fruity API json
schema](https://github.com/gocardless/atum/blob/master/spec/fixtures/fruity_schema.json)
in Atum's spec fixtures

#### 1. Create a New Gem

To generate a new rubygem client, you can run:

```
$ atum new fruity-api
```

This will does several things:

- Createa a new gem called fruity-api in a `fruity-api` folder in the current
   directory

   ```
> atum new fruity-api
      create  fruity-api/Gemfile
      create  fruity-api/Rakefile
      create  fruity-api/LICENSE.txt
      create  fruity-api/README.md
      create  fruity-api/.gitignore
      create  fruity-api/fruity-api.gemspec
      create  fruity-api/lib/fruity/api.rb
      create  fruity-api/lib/fruity/api/version.rb
Initializing git repo in /Users/petehamilton/projects/atum/fruity-api
    ```
- Creates a `.atum.yml` file in the root of the gem and populate it with:
   ```
   gem_name: fruity-api
   constant_name: FruityApi
   ```
   You can add more configuration options to this file to prevent having to add
   lots of command line arguments later. See below.

#### 2. Generate the client files

Now you have a gem, you need to populate the lib directory. To do this, navigate
to the root of your gem and run:

```
$ atum generate --file PATH_TO_SCHEMA --url API_URL
```

*Note: You can store the file and url config in your .atum.yml file for
convenience*


### Passing custom headers

If your client needs to pass custom headers with each request these can be
specified using `--default-headers or -H`:

```
atum generate -H 'Accept: application/vnd.myapp+json; version=3'
```

To pass multiple headers, just give multiple strings:

```
atum generate -H 'header1' 'header2' 'header3'
```

You can also define a default\_headers section in your .atum.yml file.

```
default_headers:
  - Accept: application/vnd.myapp+json; version=3
  - Accept-Language: Fr
```

### Generating API documentation

The generated client has [Yard](http://yardoc.org/)-compatible docstrings. You can therefore generate documentation using `yard`:

```
yard doc -m markdown .
```

This will generate HTML in the `docs` directory.  Note that Yard creates an
`_index.html` page won't be served by Jekyll on GitHub Pages.  Add a
`.nojekyll` file to your project to prevent GitHub from passing the content
through Jekyll.

### Handling failures

When an API returns an error, Atum will return an `ApiError`.

Assuming the error response form the server is in JSON format, like:

```
{
  "error": {
    "documentation_url": "https://developer.gocardless.com/enterprise#validation_failed",
    "message": "Validation failed",
    "type": "validation_failed",
    "code": 422,
    "request_id": "dd50eaaf-8213-48fe-90d6-5466872efbc4",
    "errors": [
      {
        "message": "must be a number",
        "field": "sort_code"
      }, {
        "message": "is the wrong length (should be 8 characters)",
        "field": "sort_code"
      }
    ]
  }
}
```

Atum will return an Atum::Core::ApiError error. You can access the raw hash (unenveloped) via a `.errors` method, otherwise the error message will contain the error's message and a link to the documentation if it exists.



## Supporting Ruby < 2.0.0
Atum only supports Ruby >= 2.0.0 out of the box due to our use of
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
