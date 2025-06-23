defmodule SpendlyAppWeb.ErrorJSONTest do
  use SpendlyAppWeb.ConnCase, async: true

  test "renders 404" do
    assert SpendlyAppWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert SpendlyAppWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
