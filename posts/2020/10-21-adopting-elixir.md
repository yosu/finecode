==title==
Adopting Elixir を読みました

==author==
yosu

==description==
Elixirを学ぶのに最初に読むといい本として紹介されていた Adopting Elixir を読んでみました。

==tags==
elixir 

==body==
## きっかけ

Elixir学習時のベストな読書順を紹介しているこちらの記事がきっかけです。

[The best books path to learn Elixir | by Fabio Tranjan](https://medium.com/@fabiotkx/the-best-books-path-to-learn-elixir-9a062fc6d71) 

この記事では全部で8冊の本が紹介されていますが、[Adopting Elixir](https://pragprog.com/titles/tvmelixir/adopting-elixir/) はその中でも最初の Pre-Beginner レベルとして紹介されています。

## 感想

タイトル通り、これからElixirを採用しようと思った時に考える必要があること、単に言語そのものだけでなくテストやコーディング規約、Lintなどの開発プロセスや開発環境、
デプロイやリリース周りなどを包括的に広く取り扱っていてとても参考になりました。

Pre-Begginner として紹介されている通り、ここから始めると自分にとって必要なところを深く選んで学べる基盤ができると思います。
また、 単純にElixirのいいところや特徴を知るというよりももう一歩深く、採用した企業の事例やインタビューを踏まえて得意、不得意や押さえておくべき原則などが学べるのはよかったです。

## その他

後半の Ecto と Phoenix の Instrumenting（計測）ではサンプルコードはそのままでは動きませんでした。
最近はTelemetryに統合されてるので以下のコードで同じ結果が得られました。


```elixir
# lib/demo/application.ex
defmodule Demo.Application do
  # ...

  def start(_type, _args) do
    :ok = :telemetry.attach_many(
      "demo-telemetry",
      [
        [:phoenix, :endpoint, :start],
        [:phoenix, :endpoint, :stop],
        [:demo, :repo, :query],
      ],
      &Demo.Telemetry.handle_event/4,
      nil
    )

  # ...
end
```


```elixir
# lib/demo/telemetry.ex
defmodule Demo.Telemetry do
  def handle_event([:phoenix, :endpoint, :start], measurements, metadata, _config) do
    IO.inspect {:start, measurements, metadata}
  end

  def handle_event([:phoenix, :endpoint, :stop], %{duration: duration}, _metadata, _config) do
    IO.inspect {:stop, duration}
  end

  def handle_event([:demo, :repo, :query], measurements, metadata, _config) do
    IO.inspect binding()
  end
end
```
