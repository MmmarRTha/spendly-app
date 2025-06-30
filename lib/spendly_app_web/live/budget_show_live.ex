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

      summary = Tracking.summarize_budget_transactions(budget)

      {:ok,
       assign(socket,
         budget: budget,
         transactions: transactions,
         summary: summary
       )}
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

    <div class="px-6 py-6 bg-white border border-gray-100 rounded">
      <div class="flex items-center justify-between mb-4 space-x-2">
        <div>
          <h1 class="text-2xl font-bold text-gray-900 uppercase">{@budget.name}</h1>
          <p :if={@budget.description} class="mt-1 text-gray-600">{@budget.description}</p>
        </div>
      </div>
      <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
        <div class="space-y-2">
          <% funding = Map.get(@summary, :funding, Decimal.new("0")) %>
          <% spending = Map.get(@summary, :spending, Decimal.new("0")) %>
          <% balance = Decimal.sub(funding, spending) %>
          <div class="flex items-center space-x-2">
            <.icon name="hero-wallet" class="w-4 h-4 text-gray-400" />
            <span class="text-sm font-medium text-gray-500">Balance</span>
          </div>
          <div>
            <.currency amount={balance} class="text-2xl font-bold" />
          </div>
          <div class="grid grid-cols-2 text-gray-500">
            <div>Funding</div>
            <div>Spending</div>
            <div><.currency amount={funding} positive_class="text-gray-400" /></div>
            <div><.currency amount={Decimal.negate(spending)} negative_class="text-gray-400" /></div>
          </div>
        </div>
        <div class="space-y-2">
          <div class="flex items-center space-x-2">
            <.icon name="hero-banknotes" class="w-4 h-4 text-gray-400" />
            <span class="text-sm font-medium text-gray-500">Transactions</span>
          </div>
          <div class="text-gray-900">
            <.link
              navigate={~p"/budgets/#{@budget}/new-transaction"}
              class="inline-flex items-center gap-2 px-3 py-2 text-blue-800 bg-blue-100 rounded-lg hover:bg-blue-200"
            >
              <.icon name="hero-plus" class="w-5 h-5" />
              <span>New Transaction</span>
            </.link>
          </div>
        </div>
      </div>
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
