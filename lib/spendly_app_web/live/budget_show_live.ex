defmodule SpendlyAppWeb.BudgetShowLive do
  use SpendlyAppWeb, :live_view

  alias SpendlyApp.Tracking.BudgetTransaction
  alias SpendlyApp.Tracking

  def mount(%{"budget_id" => id}, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: :creator
      )

    if budget do
      transactions =
        Tracking.list_transactions(budget)

      {:ok, assign(socket, budget: budget, transactions: transactions)}
    else
      socket =
        socket
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/budgets")

      {:ok, socket}
    end
  end

  def mount(_invalid_id, _sessions, socket) do
    socket =
      socket
      |> put_flash(:error, "Budget not found")
      |> redirect(to: ~p"/budgets")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :new_transaction}
      id="create-transaction-modal"
      on_cancel={JS.navigate(~p"/budgets/#{@budget}", replace: true)}
      show
    >
      <.live_component
        module={SpendlyAppWeb.CreateTransactionForm}
        id="create-transaction"
        budget={@budget}
      />
    </.modal>
    <div class="flex items-center justify-between">
      <div>{@budget.name} by {@budget.creator.name}</div>
      <.link
        navigate={~p"/budgets/#{@budget}/new-transaction"}
        class="flex items-center gap-2 px-3 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 hover:text-gray-800"
      >
        <.icon name="hero-plus" class="w-4 h-4" />
        <span>New Transaction</span>
      </.link>
    </div>

    <.table id="transactions" rows={@transactions}>
      <:col :let={transaction} label="Description">{transaction.description}</:col>
      <:col :let={transaction} label="Date">{transaction.effective_date}</:col>
      <:col :let={transaction} label="Amount"><.transaction_amount transaction={transaction} /></:col>
    </.table>
    """
  end

  @doc """
  Renders a transaction amount as a currency value, considering the type of the transaction.
  ## Example
  <.transaction_amount transaction={%BudgetTransaction{type: :spending, amount: Decimal.new("24.05")}} />
  Output:
  <span class="text-red-500 tabular-nums">-24.05</span>
  """

  attr :transaction, BudgetTransaction, required: true

  def transaction_amount(%{transaction: %{type: :spending, amount: amount}}),
    do: currency(%{amount: Decimal.negate(amount)})

  def transaction_amount(%{transaction: %{type: :funding, amount: amount}}),
    do: currency(%{amount: amount})

  @doc """
  Renders a currency amount field.
  ## Example
  <.currency amount={Decimal.new("246.01")} />
  Output:
  <span class="text-green-500 tabular-nums">246.01</span>
  """
  attr :amount, Decimal, required: true
  attr :class, :string, default: nil
  attr :positive_class, :string, default: "text-green-500"
  attr :negative_class, :string, default: "text-red-500"

  def currency(assigns) do
    ~H"""
    <span class={[
      "tabular-nums",
      Decimal.gte?(@amount, 0) && @positive_class,
      Decimal.lt?(@amount, 0) && @negative_class,
      @class
    ]}>
      {Decimal.round(@amount, 2)}
    </span>
    """
  end
end
