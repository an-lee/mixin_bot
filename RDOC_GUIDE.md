# RDoc Documentation Guide for MixinBot

This guide explains the comprehensive RDoc documentation that has been added to the MixinBot gem.

## Quick Start

### Generate Documentation

```bash
# Using Rake (recommended)
rake rdoc

# Or using RDoc directly
rdoc --main README.md --title "MixinBot - Ruby SDK for Mixin Network"

# Or using YARD (alternative)
gem install yard
yard doc
yard server  # Browse at http://localhost:8808
```

### View Documentation

After generation, open `doc/index.html` in your browser:

```bash
# macOS
open doc/index.html

# Linux
xdg-open doc/index.html

# Windows
start doc/index.html
```

## Documentation Style

All documentation follows Ruby community conventions and RDoc format:

### Module/Class Documentation

```ruby
##
# Brief one-line description.
#
# Detailed description with multiple paragraphs.
#
# == Sections
#
# [Term] Description
#
# == Examples
#
#   code_example
#   # => result
#
module/class Name
```

### Method Documentation

```ruby
##
# Brief description of what the method does.
#
# Longer description with details about behavior,
# edge cases, and important notes.
#
# @param param_name [Type] description of parameter
# @option kwargs [Type] :key description of option
# @return [Type] description of return value
# @raise [ExceptionClass] when exception occurs
#
# @example Basic usage
#   result = method_name(param)
#   puts result
#
# @see RelatedClass#method
# @see https://example.com/docs
#
def method_name(param, **kwargs)
```

## What Has Been Documented

### ✅ Core Components

1. **MixinBot Module** (`lib/mixin_bot.rb`)
   - Complete module documentation
   - Installation and setup guide
   - Quick start examples
   - Error handling patterns
   - All module-level methods
   - All error classes

2. **MixinBot::API** (`lib/mixin_bot/api.rb`)
   - Comprehensive API overview
   - All initialization options
   - Usage patterns (global vs. instance)
   - Key methods with examples
   - API categorization

3. **MixinBot::Configuration** (`lib/mixin_bot/configuration.rb`)
   - Configuration options
   - Key management and conversion
   - Validation methods
   - Usage examples

4. **MixinBot::Client** (`lib/mixin_bot/client.rb`)
   - HTTP client documentation
   - Error handling
   - Request/response flow
   - Authentication details

5. **MixinBot::UUID** (`lib/mixin_bot/uuid.rb`)
   - UUID format conversions
   - All methods with examples
   - Usage patterns

6. **MixinBot::Utils** (`lib/mixin_bot/utils.rb`)
   - Utility module overview
   - Sub-modules description
   - Common use cases

7. **MixinBot::Utils::Crypto** (`lib/mixin_bot/utils/crypto.rb`)
   - Cryptographic operations
   - Key generation
   - Token authentication
   - UUID operations
   - Signing and encryption

8. **API Modules**
   - `MixinBot::API::Me` - Profile management
   - `MixinBot::API::Asset` - Asset operations
   - `MixinBot::API::Transfer` - Transfer operations

9. **MVM Module** (`lib/mvm.rb`)
   - MVM overview
   - Components description
   - Usage examples

10. **MVM Components**
    - `MVM::Bridge` - Cross-chain operations
    - `MVM::Client` - HTTP client

## Documentation Features

### 1. Comprehensive Coverage

Every public interface is documented with:
- **Purpose**: What it does
- **Parameters**: Types and descriptions
- **Return Values**: Type and structure
- **Examples**: Real-world usage
- **Exceptions**: Error conditions
- **Related Links**: Cross-references

### 2. Rich Examples

```ruby
# Simple example
api.me
# => { "user_id" => "...", "full_name" => "..." }

# Complex example with error handling
begin
  result = api.create_transfer(
    members: 'recipient-id',
    asset_id: 'asset-id',
    amount: '0.01',
    memo: 'Payment'
  )
  puts result['snapshot_id']
rescue MixinBot::InsufficientBalanceError => e
  puts "Insufficient balance: #{e.message}"
end
```

### 3. Clear Structure

Documentation is organized by:
- **Modules**: Top-level namespaces
- **Classes**: Core functionality
- **Methods**: Individual operations
- **Examples**: Usage patterns
- **Errors**: Exception handling

### 4. Cross-References

Links between related components:
```ruby
# @see MixinBot::API#create_transfer
# @see https://developers.mixin.one/docs/api/transfer
```

## Best Practices

### For Developers Using the Gem

1. **Start with the main module**: Read `MixinBot` module documentation
2. **Explore by use case**: Find your operation (transfers, messaging, etc.)
3. **Check examples**: Every method has usage examples
4. **Handle errors**: See error class documentation
5. **Refer to API docs**: Links to Mixin Network documentation

### For Contributors

1. **Document all public methods**: No exceptions
2. **Include examples**: At least one per method
3. **Specify types**: Use `[Type]` notation
4. **Explain edge cases**: Document special behaviors
5. **Cross-reference**: Link to related functionality
6. **Update module docs**: When adding new features

## RDoc Markup Reference

### Headings

```ruby
# = Level 1 (Document Title)
# == Level 2 (Major Section)
# === Level 3 (Subsection)
```

### Lists

```ruby
# Bulleted list:
# - Item 1
# - Item 2
#
# Numbered list:
# 1. First
# 2. Second
#
# Definition list:
# [Term] Definition
```

### Code

```ruby
# Inline code: +code+
# Code block (indented):
#   code_here
#   more_code
```

### Links

```ruby
# External: {Link Text}[https://example.com]
# Internal: ClassName#method_name
# See also: @see ClassName#method
```

### Formatting

```ruby
# *bold*
# _italic_
# +code+
```

## Advanced Features

### Custom Tags

```ruby
##
# @param name [String] the user name
# @option opts [Integer] :age (18) the user age
# @return [Hash] user information
# @raise [ArgumentError] if name is invalid
# @example
#   create_user("John", age: 25)
# @see User
# @since 1.0.0
# @deprecated Use #new_method instead
```

### Conditional Documentation

```ruby
##
# This method is documented.
def public_method
end

# :nodoc:
# This method is not included in docs.
def internal_method
end
```

## Generating Custom Documentation

### With Custom Options

```ruby
# Rakefile
RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'MixinBot Documentation'
  rdoc.options << '--line-numbers'
  rdoc.options << '--charset=UTF-8'
  rdoc.options << '--all'  # Include private methods
  rdoc.rdoc_files.include('lib/**/*.rb', 'README.md')
end
```

### Command Line

```bash
# Basic
rdoc

# With options
rdoc --main README.md \
     --title "MixinBot" \
     --line-numbers \
     --output doc \
     lib/**/*.rb README.md

# Specific files only
rdoc lib/mixin_bot.rb lib/mixin_bot/api.rb
```

## Viewing Documentation

### Local Browser

```bash
# Generate and open
rake rdoc
open doc/index.html
```

### Documentation Server

```bash
# Using YARD
yard server

# Using RDoc (via gem server)
gem server
# Visit http://localhost:8808
```

### Online

When published to RubyGems.org, documentation is automatically available at:
```
https://www.rubydoc.info/gems/mixin_bot
```

## Maintenance

### Updating Documentation

When modifying code:

1. ✅ Update method documentation
2. ✅ Update examples if API changes
3. ✅ Update class overview if behavior changes
4. ✅ Regenerate documentation: `rake rdoc`
5. ✅ Review changes in browser

### Quality Checklist

- [ ] All public methods documented
- [ ] Parameters and return values described
- [ ] At least one example per method
- [ ] Error conditions documented
- [ ] Cross-references added
- [ ] Examples tested and working
- [ ] Typos checked
- [ ] Links valid

## Examples of Good Documentation

### Module Documentation

```ruby
##
# = ModuleName
#
# Brief overview in one sentence.
#
# == Detailed Description
#
# Multiple paragraphs explaining the module's purpose,
# key concepts, and overall architecture.
#
# == Usage
#
#   basic_example
#   # => result
#
# == Key Concepts
#
# [Concept 1] Explanation
# [Concept 2] Explanation
#
module ModuleName
```

### Method Documentation

```ruby
##
# Brief description of the method.
#
# Detailed explanation of what the method does,
# including edge cases and important behaviors.
#
# @param name [String] the name parameter
# @param age [Integer] the age parameter
# @param opts [Hash] optional parameters
# @option opts [String] :city the city name
# @option opts [String] :country the country code
# @return [Hash] the result hash containing:
#   - name: the provided name
#   - age: the provided age
#   - location: the combined location
# @raise [ArgumentError] if age is negative
#
# @example Simple usage
#   result = process("John", 25)
#   # => { name: "John", age: 25 }
#
# @example With options
#   result = process("John", 25, city: "NYC", country: "US")
#   # => { name: "John", age: 25, location: "NYC, US" }
#
def process(name, age, **opts)
```

## Resources

### RDoc Resources
- [RDoc Home](https://ruby.github.io/rdoc/)
- [RDoc Markup](https://ruby.github.io/rdoc/RDoc/Markup.html)
- [RDoc Options](https://ruby.github.io/rdoc/RDoc/Options.html)

### Ruby Documentation
- [Ruby Style Guide](https://rubystyle.guide/#documentation)
- [Ruby Documentation Guide](https://www.ruby-lang.org/en/documentation/)

### Mixin Network
- [Mixin Developers](https://developers.mixin.one/docs)
- [GitHub Repository](https://github.com/an-lee/mixin_bot)

## Summary

✅ Comprehensive RDoc documentation added
✅ Follows Ruby community standards
✅ Rich examples and usage patterns
✅ Clear structure and organization
✅ Easy to generate and browse
✅ Maintainable and extensible

The MixinBot gem now has production-ready documentation following the Ruby way!
