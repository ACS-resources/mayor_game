import Config

# Configure your database

# /uhhhh commented this out, does it pull from dev.secret.exs?

# config :mayor_game, MayorGame.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "mayor_game_dev",
#   hostname: "localhost",
#   show_sensitive_data_on_connection_error: true,
#   pool_size: 10,
#   # this sets dev logging level; set to false, :info, :warn
#   log: false

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :mayor_game, MayorGameWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
    # npx: [
    #   "tailwindcss",
    #   "--input=css/app.css",
    #   "--output=../priv/static/assets/app.css",
    #   "--postcss",
    #   "--watch",
    #   cd: Path.expand("../assets", __DIR__)
    # ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :mayor_game, MayorGameWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/mayor_game_web/(live|views)/.*(ex)$",
      ~r"lib/mayor_game_web/templates/.*(eex)$",
      ~r"lib/mayor_game/.*(ex)$",
      ~r"lib/mayor_game/(city|city_calculator)/.*(ex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

import_config "dev.secret.exs"
