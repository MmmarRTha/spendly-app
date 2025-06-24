defmodule SpendlyAppWeb.BudgetListLiveTest do
  use SpendlyAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SpendlyApp.TrackingFixtures

  setup do
    user = SpendlyApp.AccountsFixtures.user_fixture()
    %{user: user}
  end

  describe "Index View" do
    test "show budget when one exists", %{conn: conn, user: user} do
      budget = budget_fixture(%{creator_id: user.id})

      conn = log_in_user(conn, user)

      {:ok, _lv, html} = live(conn, ~p"/budgets")

      # open_browser(lv)

      assert html =~ budget.name
      assert html =~ budget.description
    end
  end
end
