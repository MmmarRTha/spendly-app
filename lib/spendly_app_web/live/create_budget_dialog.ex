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

  @impl true
  def handle_event("validate", %{"budget" => budget_params}, socket) do
    changeset =
      Tracking.change_budget(%Budget{}, budget_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"budget" => budget_params}, socket) do
    budget_params = Map.put(budget_params, "creator_id", socket.assigns.current_user.id)

    with {:ok, %Budget{}} <- Tracking.create_budget(budget_params) do
      socket =
        socket
        |> put_flash(:info, "Budget created successfully.")
        |> push_navigate(to: ~p"/budgets", replace: true)

      {:noreply, socket}
    else
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
