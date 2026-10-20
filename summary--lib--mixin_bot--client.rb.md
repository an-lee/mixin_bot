# Summary: lib/mixin_bot/client.rb
`size: 5159`
Faraday HTTP client against `https://#{api_host}`. Methods: `get`, `post`, `fetch_get`, `fetch_post`, `fetch_post_array`. Middleware: JSON, retry (max 2 on ConnectionFailed/TimeoutError), optional `http_timeout`, optional logger when debug. Private: `authorization_headers`, `sign_token`, `parse_response!` (returns `MixinBot::Models::ApiEnvelope` or raises via `ErrorMapper`), `http_error_status?` (401/403/429 or >=500), `raise_http_status_error!`.
