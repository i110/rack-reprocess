# Rack::Reprocess
A rack middleware for reprocessing (i.e. internal redirect) the request. This is similar to Rack::Recursive and Rack::ForwardRequest, but doesn't use any Exceptions to hook.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-reprocess'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-reprocess

## Usage

```ruby
  Rack::Builder.new {
    use Rack::Reprocessable
    map '/foo' do
      run Rack::Reprocess.new {|env| "/bar#{env['PATH_INFO']}" }
    end

    map '/bar' do
      run lambda {|env| [200, {}, ['reprocessed!']] }
    end
  }.to_app
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-reprocess. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::Reprocess project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-reprocess/blob/master/CODE_OF_CONDUCT.md).
