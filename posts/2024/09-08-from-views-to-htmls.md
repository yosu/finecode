==title==
命名規則とディレクトリ構成をView モジュールから HTMLモジュールに変更

==author==
yosu

==description==

前回の修正に引き続き、Phoenix 1.7の標準的なコーディングルールに従ってViewからHTMLにモジュール名とディレクトリ構成を変更しました。

==tags==
elixir

==body==

前回の修正に引き続き、Phoenix 1.7の標準的なコーディングルールに従ってViewからHTMLにモジュール名とディレクトリ構成を変更しました。


`lib/fincode_web.ex` の `def controller` の設定で`Controller` が `FooView` ではなく `FooHTML` を参照するように `namespace` オプションを削除し、`formats` オプションを設定。
また、レイアウトのモジュール名は`FooHTML` ではなく `Layouts` が標準のようなので合わせてそれも設定。

```diff
  def controller do
    quote do
-      use Phoenix.Controller, namespace: FinecodeWeb
+      use Phoenix.Controller,
+        formats: [:html, :xml],
+        layouts: [html: FinecodeWeb.Layouts]

      import Plug.Conn
      use Gettext, backend: FinecodeWeb.Gettext

      unquote(verified_routes())
    end
  end

```

モジュール名をそれぞれ `FooView` から `FooHTML` に変更し、配置先も `views` 配下から `controllers` 配下に移動する。
また、`templates` 配下の `.html.heex` ファイルも適宜 `controllers` 配下に移動する。



### before

- lib
  - finecode_web
    - views/
      - blog_view.ex
      - feed_view.ex
      - layout_view.ex
      - page_view.ex
    - templates/
      - page/
        - index.html.heex
        - about.html.heex
      - blog/
        - index.html.heex
        - show.html.heex
      - layout/
        - app.html.heex
      - feed/
        - atom.xml.eex

### after

- lib
  - finecode_web
    - components
      - layouts.ex
      - layouts/
        - app.html.heex
    - controllers/
      - blog_html/
        - index.html.heex
        - show.html.heex
      - blog_html.ex
      - feed_xml/
        - atom.xml.eex
      - feed_xml.ex
      - page_html/
        - index.html.heex
        - about.html.heex
      - page_html.ex

