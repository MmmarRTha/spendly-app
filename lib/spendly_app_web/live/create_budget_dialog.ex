defmodule SpendlyAppWeb.CreateBudgetDialog do
  use SpendlyAppWeb, :live_component

  alias SpendlyApp.Tracking
  alias SpendlyApp.Tracking.Budget

  @impl true
  def update(assigns, socket) do
    changeset = Tracking.change_budget(%Budget{})

    socket =
      socket
      |> assign(assigns)
      |> assign(form: to_form(changeset))

    {:ok, socket}
  end
end
