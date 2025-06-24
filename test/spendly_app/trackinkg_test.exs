defmodule SpendlyApp.TrackinkgTest do
  use SpendlyApp.DataCase

  import SpendlyApp.TrackingFixtures

  alias SpendlyApp.Tracking

  describe "budgets" do
    alias SpendlyApp.Tracking.Budget

    test "create_budget/2 with valid data creates a budget" do
      user = SpendlyApp.AccountsFixtures.user_fixture()

      valid_attrs = valid_budget_attributes(%{creator_id: user.id})

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(valid_attrs)
      assert budget.name == "Test Budget"
      assert budget.description == "A budget for testing"
      assert budget.start_date == ~D[2025-06-23]
      assert budget.end_date == ~D[2025-07-23]
      assert budget.creator_id == user.id
    end

    test "create_budget/2 requires name" do
      attrs =
        valid_budget_attributes()
        |> Map.delete(:name)

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)
      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_budget/2 requires valid dates" do
      user = SpendlyApp.AccountsFixtures.user_fixture()

      attrs_end_before_start = %{
        name: "Invalid Budget",
        description: "A budget with invalid dates",
        start_date: ~D[2025-07-23],
        end_date: ~D[2025-06-23],
        creator_id: user.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tracking.create_budget(attrs_end_before_start)

      assert changeset.valid? == false
      assert %{end_date: ["must end after start date"]} = errors_on(changeset)
    end
  end
end
