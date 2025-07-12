# RSpec::Fuubar

<div align="center">
  <a href="https://rubygems.org/gems/rspec-fuubar" alt="RubyGems Version">
    <img src="https://img.shields.io/gem/v/rspec-fuubar.svg?style=flat-square&label=current-version" alt="RubyGems Version" />
  </a>

  <a href="https://rubygems.org/gems/rspec-fuubar" alt="RubyGems Rank Overall">
    <img src="https://img.shields.io/gem/rt/rspec-fuubar.svg?style=flat-square&label=total-rank" alt="RubyGems Rank Overall" />
  </a>

  <a href="https://rubygems.org/gems/rspec-fuubar" alt="RubyGems Rank Daily">
    <img src="https://img.shields.io/gem/rd/rspec-fuubar.svg?style=flat-square&label=daily-rank" alt="RubyGems Rank Daily" />
  </a>

  <a href="https://rubygems.org/gems/rspec-fuubar" alt="RubyGems Downloads">
    <img src="https://img.shields.io/gem/dt/rspec-fuubar.svg?style=flat-square&label=total-downloads" alt="RubyGems Downloads" />
  </a>

  <a href="https://github.com/mhenrixon/rspec-fuubar/actions/workflows/testing.yml" alt="Build Status">
    <img src="https://img.shields.io/github/actions/workflow/status/mhenrixon/rspec-fuubar/testing.yml?branch=main&label=CI&style=flat-square&logo=github" alt="Build Status" />
  </a>
</div>

<br>

RSpec::Fuubar is an instafailing [RSpec][rspec] formatter that uses a progress bar instead of a string of letters and dots as feedback. It provides immediate feedback when tests fail and displays a progress bar with ETA for your test suite.

![examples][example-gif]

## Features

- **Immediate Failure Output**: See failures as they happen, not at the end
- **Progress Bar with ETA**: Know how long your test suite will take
- **Color-Coded Output**: Green for passing, yellow for pending, red for failing
- **Customizable**: Configure the progress bar format and behavior
- **CI Friendly**: Automatically disables features that don't work well in CI environments

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rspec-fuubar"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rspec-fuubar
```

## Usage

There are several ways to use RSpec::Fuubar:

### Option 1: Command Line

```bash
rspec --format RSpec::Fuubar --color
```

### Option 2: `.rspec` Configuration File

Add to your project's `.rspec` file:

```
--format RSpec::Fuubar
--color
```

### Option 3: `spec_helper.rb`

Add to your `spec/spec_helper.rb`:

```ruby
RSpec.configure do |config|
  config.add_formatter "RSpec::Fuubar"
end
```

### Option 4: Rake Task

```ruby
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format RSpec::Fuubar --color"
end
```

## Configuration

### Customizing the Progress Bar

RSpec::Fuubar uses [ruby-progressbar][rpb-github] under the hood. You can customize the progress bar by setting the `fuubar_progress_bar_options` configuration option:

```ruby
RSpec.configure do |config|
  config.fuubar_progress_bar_options = {
    format: "My Custom Bar: <%B> %p%% %a",
    progress_mark: "■",
    remainder_mark: "□"
  }
end
```

This would produce output like:

```
My Custom Bar: <■■■■■■■■■□□□□□□□□□□□> 45.00% 00:12:31
```

See the [ruby-progressbar documentation][rpb-docs] for all available options.

### Hiding Pending Specs Summary

By default, RSpec::Fuubar displays a summary of pending specs at the end of the test run. You can disable this:

```ruby
RSpec.configure do |config|
  config.fuubar_output_pending_results = false
end
```

### Auto-Refresh

RSpec::Fuubar can automatically refresh the progress bar every second to update the ETA:

```ruby
RSpec.configure do |config|
  config.fuubar_auto_refresh = true
end
```

**Note**: This feature may interfere with debugging tools. See the section below for workarounds.

## Compatibility

- Ruby 3.2+
- RSpec 3.0+

## Debugging

### With Pry

When using auto-refresh with [Pry][pry], you can disable it during debugging sessions:

```ruby
Pry.config.hooks.add_hook(:before_session, :disable_fuubar_auto_refresh) do |_output, _binding, _pry|
  RSpec.configuration.fuubar_auto_refresh = false
end

Pry.config.hooks.add_hook(:after_session, :restore_fuubar_auto_refresh) do |_output, _binding, _pry|
  RSpec.configuration.fuubar_auto_refresh = true
end
```

### With Byebug

[Byebug][byebug] doesn't provide hooks, so disable auto-refresh manually:

```ruby
RSpec.configuration.fuubar_auto_refresh = false
byebug
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhenrixon/rspec-fuubar. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct][code-of-conduct].

> **Note**: We use `MediumSecurity` because RSpec itself isn't signed, preventing us from using `HighSecurity`.

## Credits

Fuubar was originally written by [Jeff Kreeftmeijer][jeffk-profile] and is now maintained by [Jeff Felchner][jefff-profile].

RSpec::Fuubar is maintained and funded by [Mikael Henriksson][mhenrixon-profile]


## License

RSpec::Fuubar is Copyright © 2025 Mikael Henriksson. It is free software, and may be redistributed under the terms specified in the [LICENSE][license] file.

[byebug]: https://github.com/deivid-rodriguez/byebug
[code-of-conduct]: https://github.com/mhenrixon/rspec-fuubar/blob/master/CODE-OF-CONDUCT.md
[example-gif]: https://kompanee-public-assets.s3.amazonaws.com/readmes/fuubar-examples.gif
[jefff-profile]: https://github.com/jfelchner
[jeffk-profile]: https://github.com/jeffkreeftmeijer
[kompanee-logo]: https://kompanee-public-assets.s3.amazonaws.com/readmes/kompanee-horizontal-black.png
[kompanee-site]: http://www.thekompanee.com
[license]: https://github.com/mhenrixon/rspec-fuubar/blob/master/LICENSE.txt
[mhenrixon-profile]: https://github.com/mhenrixon
[pry]: https://github.com/pry/pry
[rpb-docs]: https://github.com/jfelchner/ruby-progressbar/wiki/Options
[rpb-github]: https://github.com/jfelchner/ruby-progressbar
[rspec]: https://github.com/rspec
