defmodule SpendlyApp.Repo do
  use Ecto.Repo,
    otp_app: :spendly_app,
    adapter: Ecto.Adapters.Postgres
end
