==title==
Phoenix をv1.6 からv1.7にアップデート

==author==
yosu

==description==

Phoenix v1.6 から v1.7に移行したのでそのメモです。

==tags==
elixir

==body==

Phoenix v1.6 から v1.7に移行したのでそのメモです。

## 公式の手順に従って修正

以下の手順に従って更新。

[Upgrading from Phoenix v1.6.x to v1.7.0](https://gist.github.com/chrismccord/00a6ea2a96bc57df0cce526bd20af8a7)

あらかじめ依存ライブラリをアップデートして動作確認。

```elixir
def deps do
  [
    {:phoenix_view, "~> 2.0"},
    {:phoenix_live_view, "~> 0.18.18"},
    {:phoenix_live_dashboard, "~> 0.7.2"},
    ...
  ]
end
```

`phoenix_view` は依存になかったので追記。

次にPhoenix を v1.7にアップデート。

```elixir
def deps do
  [
    {:phoenix, "~> 1.7.0"},
    ...
  ]
end
```


`mix.exs` のcompilers設定を削除。


```diff
def project do
  [
-   compilers: [:phoenix] ++ Mix.compilers(),
  ]
end
```

`.formatter.exs` のplugins行を追加。

```elixir
[
  ...
  plugins: [Phoenix.LiveView.HTMLFormatter],
]
```

## VerifiedRoutesのサポート

ヘルパーマクロを`finecode_web.ex`に追加。

```diff
+  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

   def controller do
     quote do
       import Plug.Conn
       use Gettext, backend: FinecodeWeb.Gettext
-      alias FinecodeWeb.Router.Helpers, as: Routes

+      unquote(verified_routes())
     end
   end

@@ -41,7 +43,17 @@ defmodule FinecodeWeb do
  def view do
    quote do
      use Phoenix.View,
        root: "lib/finecode_web/templates",
        namespace: FinecodeWeb

-      alias FinecodeWeb.Router.Helpers, as: Routes

+      unquote(verified_routes())
     end
   end

+  def verified_routes() do
+    quote do
+      use Phoenix.VerifiedRoutes,
+        endpoint: FinecodeWeb.Endpoint,
+        router: FinecodeWeb.Router,
+        statics: FinecodeWeb.static_paths()
+    end
+  end
```

合わせて`endpoint.ex`の`Plug.Static` の設定を新しく定義した `static_paths` を使うように修正。

```diff
  plug Plug.Static,
    at: "/",
    from: :app,
    gzip: false,
-   only: ~w(assets fonts images favicon.ico robots.txt)
+   only: FinecodeWeb.static_paths()
```

テストケースでも使えるように `test/support/conn_case.ex` を修正。

```diff
  using do
    quote do
      # The default endpoint for testing
      @endpoint FinecodeWeb.Endpoint

+     use FinecodeWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias FinecodeWeb.Router.Helpers, as: Routes
    end
  end
```

## サポートされたVerifiedRoutesを使ってRoutes利用箇所を修正

`app.html.heex` など各リンクを書き換え。

```diff
 <html>
   <head>
     <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
     <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
     <title><%= assigns[:page_title] || "FineCode - Exploring better coding" %></title>
-    <link rel="icon" href={Routes.static_path(@conn, "/images/favicon.png")} />
+    <link rel="icon" href={~p"/images/favicon.png/"} />
     <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/milligram/1.3.0/milligram.css">
-    <link rel="stylesheet" href={Routes.static_path(@conn, "/assets/app.css")}/>
-    <link rel="alternate" href={Routes.feed_url(@conn, :atom)} type="application/atom+xml" title="FineCode Atom Feed">
+    <link rel="stylesheet" href={~p"/assets/app.css"}/>
+    <link rel="alternate" href={~p"/feeds/atom.xml"} type="application/atom+xml" title="FineCode Atom Feed">
     <%= csrf_meta_tag() %>
   </head>
   <body>
     <header class="page-header wrapper">
       <a href="/">
-          <img src={Routes.static_path(@conn, "/images/logo.png")} alt="FineCode Logo" class="logo"/>
+          <img src={~p"/images/logo.png"} alt="FineCode Logo" class="logo"/>
       </a>
       <nav role="navigation">
         <ul class="main-nav">
-          <li><a href={Routes.blog_path(@conn, :index)}>Blog</a></li>
-          <li><a href={Routes.page_path(@conn, :about)}>About</a></li>
+          <li><a href={~p"/blog"}>Blog</a></li>
+          <li><a href={~p"/about"}>About</a></li>
         </ul>
       </nav>
     </header>
@@ -28,6 +28,6 @@
       <p class="alert alert-danger" role="alert"><%= Phoenix.Flash.get(@flash, :error) %></p>
       <%= @inner_content %>
     </main>
-    <script type="text/javascript" src={Routes.static_path(@conn, "/assets/app.js")}></script>
+    <script type="text/javascript" src={~p"/assets/app.js"}></script>
   </body>
 </html>
```

atomフィードの場合相対パスではなくURLが必要なので[url](https://hexdocs.pm/phoenix/Phoenix.VerifiedRoutes.html#url/1)を使って書き換え。

```diff
-  <link rel="alternate" type="text/html" href="<%= Routes.page_url(@conn, :index) %>"/>
-  <link rel="self" type="application/atom+xml" href="<%= Routes.feed_url(@conn, :atom) %>"/>
+  <link rel="alternate" type="text/html" href="<%= url(~p"/") %>"/>
+  <link rel="self" type="application/atom+xml" href="<%= url(~p"/feeds/atom.xml") %>"/>
```

URLが直接見えるようになって分かりやすなった上にURLが間違っていた場合ちゃんとwarningが出るのですごくいい。実際`/feeds/atom.xml`を`/feed/atom.xml`としていてwanrningで間違いに気づき修正できた。


