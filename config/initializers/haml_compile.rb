Rails.application.config.assets.precompile = [ /(^[^_\/]|\/[^_])[^\/]*$/i ]

Sprockets.register_mime_type 'text/html', extensions: %w(.html)
Sprockets.register_mime_type 'text/haml', extensions: %w(.haml)
Sprockets.register_transformer 'text/haml', 'text/html', Tilt::HamlTemplate
