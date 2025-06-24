defmodule SpendlyApp.Tracking do
  import Ecto.Query, warn: false

  alias SpendlyApp.Repo
  alias SpendlyApp.Tracking.Budget

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end
end
