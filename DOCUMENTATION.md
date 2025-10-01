# MixinBot Documentation Guide

This document explains how to generate and view the comprehensive RDoc documentation for the MixinBot gem.

## Generating Documentation

### Using RDoc

RDoc is Ruby's built-in documentation tool. To generate documentation:

```bash
# Generate HTML documentation
rdoc

# Generate documentation with custom options
rdoc --main README.md --title "MixinBot - Ruby SDK for Mixin Network"
```

The documentation will be generated in the `doc/` directory.

### Using YARD (Alternative)

YARD provides enhanced documentation features:

```bash
# Install YARD if not already installed
gem install yard

# Generate YARD documentation
yard doc

# Start YARD server to browse documentation
yard server
```

Then visit http://localhost:8808 in your browser.

## Documentation Structure

The MixinBot gem documentation is organized into the following sections:

### Main Module: MixinBot

The root module containing:
- Configuration management
- Global API instance
- Error definitions
- Utility access

### Core Classes

#### MixinBot::API
Main interface for all Mixin Network operations:
- User and bot profile management
- Asset operations
- Transfers and payments
- Messaging via Blaze
- Multisig operations
- NFT/collectible operations

#### MixinBot::Configuration
Credential and settings management:
- Application credentials
- Key management
- Host configuration

#### MixinBot::Client
HTTP client for API requests:
- Request/response handling
- Authentication
- Error handling

### Data Classes

#### MixinBot::UUID
UUID format conversions between:
- Standard UUID format (with dashes)
- Packed binary format
- Hex format

#### MixinBot::MixAddress
Mixin Network address handling:
- Address encoding/decoding
- Multi-signature addresses
- Main network addresses

#### MixinBot::Invoice
Invoice creation and parsing:
- Payment requests
- QR code generation
- Invoice validation

#### MixinBot::Nfo
NFT memo handling:
- NFT minting
- Token identification
- Metadata encoding

#### MixinBot::Transaction
Transaction encoding/decoding:
- Safe API transactions
- Legacy transactions
- Input/output management

### Utility Modules

#### MixinBot::Utils::Crypto
Cryptographic operations:
- JWT token generation
- Key generation (Ed25519, RSA)
- Transaction signing
- PIN encryption
- UUID generation

#### MixinBot::Utils::Encoder
Data encoding utilities:
- Integer encoding
- Transaction encoding
- Binary packing

#### MixinBot::Utils::Decoder
Data decoding utilities:
- Integer decoding
- Transaction decoding
- Binary unpacking

#### MixinBot::Utils::Address
Address utilities:
- Address validation
- Key derivation
- Ghost key generation

### MVM Module

Mixin Virtual Machine integration:

#### MVM::Bridge
Cross-chain bridge operations

#### MVM::Client
HTTP client for MVM services

#### MVM::Nft
NFT operations on MVM

#### MVM::Registry
Contract registry operations

#### MVM::Scan
Blockchain explorer interface

## API Modules

The API class includes the following modules, each handling specific API endpoints:

### User & Profile
- `MixinBot::API::Me` - Bot profile operations
- `MixinBot::API::User` - User lookup and search
- `MixinBot::API::Auth` - Authentication operations

### Assets & Balance
- `MixinBot::API::Asset` - Asset information
- `MixinBot::API::Snapshot` - Transaction history
- `MixinBot::API::Output` - UTXO operations

### Transfers & Payments
- `MixinBot::API::Transfer` - Safe API transfers
- `MixinBot::API::Payment` - Payment operations
- `MixinBot::API::Transaction` - Transaction management
- `MixinBot::API::LegacyTransfer` - Legacy transfers

### Messaging
- `MixinBot::API::Blaze` - WebSocket messaging
- `MixinBot::API::Message` - Message operations
- `MixinBot::API::EncryptedMessage` - Encrypted messages
- `MixinBot::API::Conversation` - Conversation management

### Multisig
- `MixinBot::API::Multisig` - Multisig operations
- `MixinBot::API::LegacyMultisig` - Legacy multisig

### NFT & Collectibles
- `MixinBot::API::Inscription` - Inscription operations
- `MixinBot::API::LegacyCollectible` - Legacy collectibles

### Other
- `MixinBot::API::Pin` - PIN management
- `MixinBot::API::Withdraw` - Withdrawal operations
- `MixinBot::API::Attachment` - File attachments
- `MixinBot::API::Address` - Address operations
- `MixinBot::API::Rpc` - RPC operations
- `MixinBot::API::Tip` - TIP signing

## Examples

The documentation includes extensive examples throughout. Here are some key examples:

### Basic Usage

```ruby
# Configure bot
MixinBot.configure do
  app_id = 'your-app-id'
  session_id = 'your-session-id'
  session_private_key = 'your-private-key'
  server_public_key = 'server-public-key'
end

# Get bot profile
profile = MixinBot.api.me
puts profile['full_name']

# List assets
assets = MixinBot.api.assets
assets.each do |asset|
  puts "#{asset['symbol']}: #{asset['balance']}"
end
```

### Transfers

```ruby
# Simple transfer
result = MixinBot.api.create_transfer(
  members: 'recipient-user-id',
  asset_id: 'asset-uuid',
  amount: '0.01',
  memo: 'Payment'
)

# Multisig transfer (2-of-3)
result = MixinBot.api.create_transfer(
  members: ['user1', 'user2', 'user3'],
  threshold: 2,
  asset_id: 'asset-uuid',
  amount: '0.01'
)
```

### Messaging

```ruby
# Connect to Blaze
EM.run {
  MixinBot.api.start_blaze_connect do
    def on_message(blaze, event)
      raw = JSON.parse(event.data)
      # Process message
    end
  end
}
```

## Error Handling

The documentation describes all custom error classes:

- `MixinBot::Error` - Base error
- `MixinBot::HttpError` - HTTP errors
- `MixinBot::ResponseError` - API response errors
- `MixinBot::UnauthorizedError` - Authentication failures
- `MixinBot::InsufficientBalanceError` - Balance issues
- And more...

Example:

```ruby
begin
  MixinBot.api.create_transfer(...)
rescue MixinBot::InsufficientBalanceError => e
  puts "Insufficient balance: #{e.message}"
rescue MixinBot::ResponseError => e
  puts "API error: #{e.message}"
end
```

## Viewing Documentation

After generation, open the documentation:

### RDoc
```bash
# Open in default browser
open doc/index.html  # macOS
xdg-open doc/index.html  # Linux
start doc/index.html  # Windows
```

### YARD
```bash
# Start server
yard server

# Visit http://localhost:8808
```

## Documentation Standards

All documentation follows Ruby community standards:

1. **RDoc Format**: Uses standard RDoc markup
2. **Method Documentation**: All public methods are documented with:
   - Description
   - Parameters with types
   - Return values with types
   - Examples
   - Related links
3. **Module Documentation**: Comprehensive module/class overviews
4. **Examples**: Real-world usage examples throughout
5. **Cross-references**: Links between related classes and methods

## Contributing to Documentation

When adding new features or modifying existing code:

1. Document all public methods
2. Include parameter types and descriptions
3. Provide usage examples
4. Update module overviews when needed
5. Add cross-references to related functionality
6. Follow existing documentation style

## Resources

- [RDoc Documentation](https://ruby.github.io/rdoc/)
- [YARD Documentation](https://yardoc.org/)
- [Mixin Network API](https://developers.mixin.one/docs)
- [GitHub Repository](https://github.com/an-lee/mixin_bot)
