defmodule FinecodeWeb.PageControllerTest do
  use FinecodeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "ようこそ!"
  end
end
