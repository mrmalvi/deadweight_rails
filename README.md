# DeadweightRails

[![Gem Version](https://badge.fury.io/rb/deadweight_rails.svg)](https://badge.fury.io/rb/deadweight_rails)

DeadweightRails scans your Rails project for **unused assets and Ruby code**, helping you reduce bundle size, improve performance, and clean your codebase.

---

## Features

- Detect **unused CSS and JS** in Rails asset pipeline
- Detect **unused Ruby methods**
- Generate a **report** in terminal with colored output
- Works with standard Rails directories (`app/assets`, `app/views`, `app/models`)
- Simple Rake task integration

---

## Installation

Add this line to your Gemfile:

```ruby
gem 'deadweight_rails'
```

Then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install deadweight_rails
```

---

## Usage

### 1. Rake task

Add this task to `lib/tasks/deadweight.rake`:

```ruby
require "rake"
require "deadweight_rails"

namespace :deadweight do
  desc "Scan Rails project for unused assets and Ruby code"
  task :scan do
    DeadweightRails.run
  end
end
```

Run the task:

```bash
bundle exec rake deadweight:scan
```

---

### 2. Programmatically

```ruby
require "deadweight_rails"

# Scan current Rails project
DeadweightRails.run

# Or scan a specific path
DeadweightRails.run(path: "/path/to/project")
```

---

## Example Output

```
🔎 DEADWEIGHTRAILS REPORT

--- Assets ---
Unused CSS: old.css
Unused JS:  legacy.js

--- Ruby ---
Unused Methods: old_helper
```

---

## Development

After checking out the repo, run:

```bash
bin/setup
rake spec
bin/console
```

To install the gem locally:

```bash
bundle exec rake install
```

To release a new version:

```bash
bundle exec rake release
```

---

## Contributing

Bug reports and pull requests are welcome on GitHub:
gem "deadweight_rails", path: "../deadweight_rails"
https://github.com/[USERNAME]/deadwe
