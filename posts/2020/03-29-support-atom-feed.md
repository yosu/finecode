==title==
Atomフィードに対応した

==author==
yosu

==description==

自作ブログの記事をLAPRASに連携するためにAtomフィードに対応しました。

==tags==
elixir, phoenix, atom, feed

==body==
自作ブログの記事をLAPRASに連携するためにAtomフィードに対応しました。

最初はRSS 2.0に対応しようかと思いましたが、Atomが一番シンプルそうなのでAtomに対応することにしました。前回の記事、[Phoenixでブログを作った - FineCode Blog](https://fine-code.com/blog/making-this-blog)に引き続きやったことを書いていきます。


## シンプルなAtomを配信

まずは [RFC 4287 The Atom Syndication Format 日本語訳](https://www.futomi.com/lecture/japanese/rfc4287.html)
にあるシンプルなXMLをPhoenixから配信するようにしました。
`router.ex`にエンドポイントを追加します。

```elixir
  scope "/", FinecodeWeb do
    pipe_through :browser

    get "/default", PageController, :default
    get "/", PageController, :index
    get "/about", PageController, :about
    # 以下を追加
    get "/feeds/atom.xml", FeedController, :atom
  end
```

これに合わせてController, View, Templateをそれぞれ配置していきます。

`finecode_web/controllers/feed_controller.ex`
```elixir
defmodule FinecodeWeb.FeedController do
  use FinecodeWeb, :controller

  alias Finecode.Blog

  def atom(conn, _params) do
    render(conn, "atom.xml")
  end
end
```

`finecode_web/views/feed_view.ex`
```elixir
defmodule FinecodeWeb.FeedView do
  use FinecodeWeb, :view
end
```

動的な要素はなしのフィードを生成。

`finecode_web/templates/atom.xml.eex`
```elixir
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

  <title>FineCode</title>
  <link href="https://fine-code.com/"/>
  <updated>2003-12-13T18:30:02Z</updated>
  <author>
    <name>@yosu</name>
  </author>
  <id>https://fine-code.com</id>

  <entry>
    <title>Atom-Powered Robots Run Amok</title>
    <link href="http://example.org/2003/12/13/atom03"/>
    <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
    <updated>2003-12-13T18:30:02Z</updated>
    <summary>Some text.</summary>
  </entry>

</feed>
```

ここまでで `/feeds/atom.xml` にアクセスし、フィードが取得できることを確認。

## ブログポストからフィードを生成

エンドポイントが問題なく表示できることがわかったので今度はブログ記事からフィードを生成していきます。
記事であるBlog.Postは以下の構造体になっているので、これをもとにフィードの各要素を作ります。

```elixir
defmodule Finecode.Blog.Post do
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date]
  defstruct [:id, :author, :title, :body, :description, :tags, :date]

  # ...
end
```

updated要素の日時情報を作るのに以下のルールで作ることにしました。

- Post.dateから日時への変換は日本時間（JST）の00:00 AM ということにする
- feedのupdated要素は最新のBlog.Postの日付から生成する


FeedControllerを修正し、ViewやTemplateからBlog.Postが使えるようにします。

```elixir
defmodule FinecodeWeb.FeedController do
  use FinecodeWeb, :controller

  alias Finecode.Blog

  def atom(conn, _params) do
    render(conn, "atom.xml", posts: Blog.list_posts())
  end
end
```

ここまででフィードは以下のようになります。

`finecode_web/templates/atom.xml.eex`
```elixir
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

  <title>FineCode</title>
  <link href="https://fine-code.com/"/>
  <updated><%= @posts |> hd |> to_updated() %></updated>
  <author>
    <name>@yosu</name>
  </author>
  <id>https://fine-code.com</id>

  <%= for post <- @posts do %>
  <entry>
    <title><%= post.title %></title>
    <link href="<%= Routes.blog_url(@conn, :show, post.id) %>"/>
    <id><%= post.id %></id>
    <updated><%= to_updated(post) %></updated>
    <summary><%= post.description %></summary>
  </entry>
  <% end %>

</feed>
```

これであとは`to_updated(%Post{} = post)` を実装すればいいのですがこの実装方法で少し悩みました。


### Dateからタイムゾーン付きのDateTimeへの変換

Dateからタイムゾーン情報を持つ`DateTime` に変換したいのですが2つ問題がありました。

- 標準ではUTCしかサポートしていない
- `Date` から `DateTime` に素直に変換する方法がない


### タイムゾーンをサポートするようにする

デフォルトだとUTC以外のタイムゾーンを使って `DateTime` を使おうとすると以下のようにエラーになります。


```elixir
iex(20)> DateTime.now("Etc/UTC")
{:ok, ~U[2020-03-28 13:44:10.808908Z]}

iex(21)> DateTime.now("Asia/Tokyo")
{:error, :utc_only_time_zone_database}
```

ただ、これは標準のドキュメントに書いてある通り `tzdata` を導入すれば簡単に解決できます。

- [DateTime — Elixir v1.10.2](https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database)
- [lau/tzdata: tzdata for Elixir. Born from the Calendar library.](https://github.com/lau/tzdata)

やることは以下の2つ。


`mix.exs`
```elixir
  defp deps do
  [
    {:tzdata, "~> 1.0.3"}
  ]
```

`config.ex`
```
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
```

これで`mix deps.get` した後に `iex -S mix` で確認するとタイムゾーンが扱えるようになります。


```elixir
  iex(1)> DateTime.now("Etc/UTC")
  {:ok, ~U[2020-03-28 13:49:17.007027Z]}

  iex(2)> DateTime.now("Asia/Tokyo")
  {:ok, #DateTime<2020-03-28 22:49:22.794612+09:00 JST Asia/Tokyo>}
```


### DateからDateTimeへの変換

直接変換するようないいインタフェースがないので、結局`NaiveDateTime` 経由で変換することにしました。

`Date` -> 時間を付加 -> `NaiveDateTime` -> タイムゾーンを付加 -> `DateTime`

最初はまどろっこしいかと思ってたのですが、1ステップで1つのことだけやるので、結果的にシンプルかつ明瞭になりました。
実装は以下の通りです。


```elixir
defmodule FinecodeWeb.FeedView do
  use FinecodeWeb, :view

  alias Finecode.Blog.Post

  def to_updated(%Post{} = post) do
    to_iso8601(post.date)
  end

  defp to_iso8601(%Date{} = date) do
    {:ok, naive_datetime} = NaiveDateTime.new(date, ~T[00:00:00])

    naive_datetime
    |> DateTime.from_naive!("Asia/Tokyo")
    |> DateTime.to_iso8601()
  end
end
```

ここまででほぼ完成したのでチェックしてみます。


## フィードのチェック

フィードのチェックはW3Cのツールがあるのでこちらで行います。

[W3C Feed Validation Service, for Atom and RSS](https://validator.w3.org/feed/)


デフォルトはURL入力なのですが、フィードの本文をフォームに入力してチェックできるので、開発中はそちらでチェックします。
実際にチェックしてみると、3つエラーが出ました。


```
This feed does not validate.

line 12, column 20: id must be a full and valid URL: making-this-blog [help]

<id>making-this-blog</id>
                    ^
In addition, interoperability with the widest range of feed readers could be improved by implementing the following recommendations.

line 8, column 25: Identifier "https://fine-code.com" is not in canonical form (the canonical form would be "https://fine-code.com/") [help]

<id>https://fine-code.com</id>
                         ^
line 1, column 0: Missing atom:link with rel="self" [help]

<feed xmlns="http://www.w3.org/2005/Atom">
```

問題は、

- entryのidがvalidなURLではない
- feedのidがcanonical formではない
- rel="self" なlink要素がない

順に対応していきます。

### id要素に対応する

id要素には適当に値をセットしてしまったんですが、調べて見るとid要素にはUUIDのような世界的にグローバルなIDを指定する必要がありました（実際Atom仕様の例ではUUIDがセットされている）。

また、UUIDの他にtag URIを利用するのも一般的なようでこちらを採用することにしました。
UUIDよりもヒューマンフレンドリー（人間が見たときに何のIDか分かりやすい）というのが理由です。

こちらの記事が分かりやすい。

- [XMLデータを管理する: タグURI](https://www.ibm.com/developerworks/jp/xml/lib.ory/x-mxd6/index.html)
- [ちょっとしたメモ - 時間軸を使うURIスキーム、tag:がRFCに](https://www.kanzaki.com/memo/2005/02/25-1)


結局以下のようなidを生成することにしました。

- feedのid: fine-code.com,2020:feed
- entryのid: fine-code.com,2020:entry:<記事のid>

2020年にfine-code.comドメイン所有者（つまり自分）のfeed, entryという意味のID。
記事のidは今回のこの記事であれば `support-atom-feed` になります。

ベースとなるtag URIをコンフィグに定義し、Viewにそれぞれのid生成するメソッドを追加します。


`config/config.exs`
```elixir
# Base tag URI for Atom feed
config :finecode, :tag_uri, "tag:fine-code.com,2020"
```

`finecode_web/views/feed_view.ex`
```elixir
defmodule FinecodeWeb.FeedView do
  def feed_id() do
    tag_uri() <> ":feed"
  end

  def entry_id(%Post{} = post) do
    tag_uri() <> ":entry:#{post.id}"
  end

  defp tag_uri() do
    Application.fetch_env!(:finecode, :tag_uri)
  end
end
```


### rel="self" なlink要素を追加

Atomフィード自身を指し示すlink要素が必要なので以下を追加します。

```
  <link rel="self" type="application/atom+xml" href="<%= Routes.feed_url(@conn, :atom) %>"/>
```

ただ、こちらを追加してもW3Cのチェッカーでは以下のような警告が出てしまいました。

> line 4, column 90: Self reference doesn't match document location [help]


デプロイ後にURLを入力してのチェックでは出なくなったので、フォームからのバリデーションでは出てしまう不具合のようです。


### 最終的なフィードテンプレート

`finecode_web/templates/atom.xml.eex`
```elixir
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

  <title>FineCode</title>
  <link rel="alternate" type="text/html" href="<%= Routes.page_url(@conn, :index) %>"/>
  <link rel="self" type="application/atom+xml" href="<%= Routes.feed_url(@conn, :atom) %>"/>
  <updated><%= @posts |> hd |> to_updated() %></updated>
  <author>
    <name>@yosu</name>
  </author>
  <id><%= feed_id() %></id>

  <%= for post <- @posts do %>
  <entry>
    <title><%= post.title %></title>
    <link href="<%= Routes.blog_url(@conn, :show, post.id) %>"/>
    <id><%= entry_id(post) %></id>
    <updated><%= to_updated(post) %></updated>
    <summary><%= post.description %></summary>
  </entry>
  <% end %>

</feed>
```

最後にこのフィードへのメタタグを追加。

```
<link rel="alternate" href="<%= Routes.feed_url(@conn, :atom) %>" type="application/atom+xml" title="FineCode Atom Feed">
```

ここまでの修正を入れてデプロイ後にW3Cのチェッカーに今度は本番URLを入れて問題ないことが確認できました。

[Feed Validator Results: https://fine-code.com/feeds/atom.xml](https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Ffine-code.com%2F)


## LAPRASに登録する

ここまで来たらLAPRASに登録してみます。

[クロール対象サイト（ブログ） の記事の取得について | LAPRAS ヘルプ](https://talent-help.lapras.com/ja/articles/3677477)

こちらを参考にログイン後、連携編集、クロール対象サイトの追加からサイトのURLを登録します。
入力するのはフィードのURLではないことに注意。


ステータスが確認中になるのでしばらく待った所（1時間くらい）、 連携失敗の結果が出てしまいました。

最低限のフィードなのでvalidだけど連携に必要な要素が足りないのかもしれないです。
うーん。



