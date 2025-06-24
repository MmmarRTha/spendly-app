defmodule SpendlyApp.TrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SpendlyApp.Tracking` context.
  """

  def valid_budget_attributes(attrs \\ %{}) do
    attrs
    |> add_creator_if_necessary()
    |> Enum.into(%{
      name: "Test Budget",
      description: "A budget for testing",
      start_date: ~D[2025-06-23],
      end_date: ~D[2025-07-23]
    })
  end

  @doc """
  Generate a budget.
  """
  def budget_fixture(attrs \\ %{}) do
    {:ok, budget} =
      attrs
      |> valid_budget_attributes()
      |> SpendlyApp.Tracking.create_budget()

    budget
  end

  defp add_creator_if_necessary(attrs) when is_map(attrs) do
    Map.put_new_lazy(attrs, :creator_id, fn ->
      user = SpendlyApp.AccountsFixtures.user_fixture()
      user.id
    end)
  end
end
