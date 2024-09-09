defmodule FinecodeWeb.FeedControllerTest do
  use FinecodeWeb.ConnCase

  test "Get /feeds/atom.xml", %{conn: conn} do
    conn = get(conn, "/feeds/atom.xml")

    assert response_content_type(conn, :xml) == "application/atom+xml; charset=utf-8"
    assert response(conn, 200) =~ "<feed xmlns=\"http://www.w3.org/2005/Atom\">"
  end
end
