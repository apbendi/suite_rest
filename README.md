# SuiteRest

A gem to simplify interaction with NetSuite RESTlets. You will find SuiteRest useful if:

 1. You have already created (or are developing) a RESTlet in NetSuite
 2. You want to interact with that RESTlet in a Ruby environment
 
SuiteRest makes it easy to configure NetSuite authentication, define the RESTlet you want to interact with, call that RESTlet, and receive return values. It reduces the boilerplate and allows for cleaner code.

## Installation

SuiteRest is available on RubyGems and can be installed as such:

    $ gem install suite_rest

Or add this line to your application's Gemfile:

    gem 'suite_rest'

 
## Usage

### Configuration

Configure SuiteRest with your account information. The configuration block is global and needs only be done once per session.

```Ruby
	SuiteRest.configure do |config|
    	config.account    = 123456
    	config.email      = "email@mail.com"
    	config.role       = 1010
    	config.signature  = "password"
	end
```


### Example

Let's assume you have a NetSuite RESTlet deployed with the following function bound to `GET`:

```JavaScript
	function getTest(datain) {
		if(datain.worldDescription) {
			return("Hello " + datain.worldDescription + " World");
		} else {
			return("Hello World");
		}
	}
```

Each RESTlet is defined by an **instance** of a `SuiteRest::RestService` object. Initialize the instance with the definition of the service.

```Ruby
	get_world = SuiteRest::RestService.new( :type => :get,
      										:script_id => 27,
      										:deploy_id => 1,
      										:args_def => [:world_description])
```
      
Now simply `call` this service and get back a response:

```Ruby
	get_world.call(:world_description => "Big") # "Hello Big World"
```

Valid values for `:type` are the REST-ful services supported by NetSuite RESTlets: `:get`, `:put`, `:post`, `:delete`. Values for `:script_id` and `:deploy_id` are defined on your Script Deployment record in NetSuite.

An array of all argument names you will send to your RESTlet should be included in `:args_def`. Note that SuiteRest automatically camelizes your parameter names so you can write idiomatic JavaScript in your RESTlet and idiomatic Ruby in your Ruby app. SuiteRest assumes this convention and could break if you use non-idiomatic names.

SuiteRest **only** manages case of parameters defined in `:args_def`. Keys in hashes, for example, will be converted to JSON and sent as-is to your RESTlet. For example the following Ruby hash…

```Ruby
	some_data = {
					:a => "Hello",
					:b_key => "World",
					"string_key" => :symbol_val
				}
```

…if passed in a argument to a RESTlet would appear as such in your JavaScript:

```JavaScript
	// datain.someData
	{
		"a": "Hello",
		"b_key": "World",
		"string_key": "symbol_val"
	}
```

To call the service with other args you should define a new service:

```Ruby
	get_world_no_args = SuiteRest::RestService.new( :type => :get,
      										:script_id => 27,
      										:deploy_id => 1)
    get_world_no_args.call # "Hello World"
```

## Contributing

SuiteRest is a simple Gem, but it is version 0.1.0 software so be sure to test extensively before deploying. If you find a bug, please submit an issue or pull request and I'll happily fix the issue.
