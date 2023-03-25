import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ai_playground, AIPlaygroundWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "rTWeSj8Dtjsp6eL7E3EiyiFGdSiVMhAIn/aoaMu9twp77337KaoRyXi7gPHUfaBP",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
