defmodule SpendlyAppWeb.BudgetListLiveTest do
  use SpendlyAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias SpendlyApp.Tracking

  setup do
    %{user: insert(:user)}
  end

  describe "Index View" do
    test "show budget when one exists", %{conn: conn, user: user} do
      budget = insert(:budget, creator: user)

      conn = log_in_user(conn, user)

      {:ok, _lv, html} = live(conn, ~p"/budgets")

      # open_browser(lv)

      assert html =~ budget.name
      assert html =~ budget.description
      assert html =~ user.name
    end
  end

  describe "Create budget modal" do
    test "modal is presented when 'Create Budget' button is clicked", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)

      {:ok, lv, _html} = live(conn, ~p"/budgets/new")

      assert has_element?(lv, "#create-budget-modal")
    end
  end

  test "validate errors are shown when form has an invalid input", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)

    {:ok, lv, _html} = live(conn, ~p"/budgets/new")

    form =
      form(lv, "#create-budget-modal form", %{
        "budget" => %{"name" => ""}
      })

    html = render_change(form)

    assert html =~ html_escape("can't be blank")
  end

  test "creates a budget", %{
    conn: conn,
    user: user
  } do
    conn = log_in_user(conn, user)
    {:ok, lv, _html} = live(conn, ~p"/budgets/new")

    form =
      form(lv, "#create-budget-modal form", %{
        "budget" => %{
          "name" => "A new name",
          "description" => "The new description",
          "start_date" => "2025-07-01",
          "end_date" => "2025-07-31"
        }
      })

    {:ok, _lv, html} =
      render_submit(form)
      |> follow_redirect(conn)

    assert html =~ "Budget created successfully."
    assert html =~ "A new name"

    assert [created_budget] = Tracking.list_budgets()
    assert created_budget.name == "A new name"
    assert created_budget.description == "The new description"
    assert created_budget.start_date == ~D[2025-07-01]
    assert created_budget.end_date == ~D[2025-07-31]
  end

  test "validation errors are presented when form is submitted with invalid input", %{
    conn: conn,
    user: user
  } do
    conn = log_in_user(conn, user)
    {:ok, lv, _html} = live(conn, ~p"/budgets/new")

    form =
      form(lv, "#create-budget-modal form", %{
        "budget" => %{"name" => ""}
      })

    html = render_submit(form)

    assert html =~ html_escape("can't be blank")
  end

  test "end date before start date error is presented when form is submitted with invalid dates",
       %{
         conn: conn,
         user: user
       } do
    conn = log_in_user(conn, user)
    {:ok, lv, _html} = live(conn, ~p"/budgets/new")

    attrs =
      params_for(:budget,
        start_date: ~D[2025-12-31],
        end_date: ~D[2025-01-01]
      )

    form =
      form(lv, "#create-budget-modal form", %{
        budget: attrs
      })

    html = render_submit(form)

    assert html =~ "must end after start date"
  end
end
