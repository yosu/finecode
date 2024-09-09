defmodule FinecodeWeb.FeedController do
  use FinecodeWeb, :controller

  alias Finecode.Blog

  # コンテンツ内容を表す application/atom+xml をセットする。
  # （:xml フォーマットデフォルトのコンテンツタイプは text/xml ）
  # text/xml だと各ブラウザでXMLを表示してくれるが application/atom+xmlをセットした場合は
  # ダウンロードページが開かれたり、シンタックスハイライトが効かなくなってしまう問題がある。
  # あえてより好ましいコンテンツタイプを設定する。
  # https://stackoverflow.com/questions/8198154/rss-and-atom-content-type
  # https://www.petefreitag.com/blog/content-type-xml-feeds/
  def atom(conn, _params) do
    conn
    |> put_resp_content_type("application/atom+xml")
    |> render("atom.xml", posts: Blog.list_posts())
  end
end
