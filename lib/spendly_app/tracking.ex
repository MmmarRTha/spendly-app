defmodule SpendlyApp.Tracking do
  import Ecto.Query, warn: false

  alias SpendlyApp.Repo
  alias SpendlyApp.Tracking.Budget

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  def list_budgets do
    Repo.all(Budget)
    |> Repo.preload(:creator)
  end

  def get_budget!(id), do: Repo.get!(Budget, id)
end
