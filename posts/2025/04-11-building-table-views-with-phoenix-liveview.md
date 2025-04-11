==title==
Build Table Views with Phoenix LiveView

==author==
yosu

==description==

Build Table Views with Phoenix LiveView を読みました。
この本の感想と実際にコードを動かした際に、この本のコードそのままでは動かない箇所がいくつかあったためその修正内容について書いています。

==tags==
elixir,phoenix,liveview

==body==

[Building Table Views with Phoenix LiveView](https://pragprog.com/titles/puphoe/building-table-views-with-phoenix-liveview/)を買って、手を動かしながら読みました。

LiveView にはだいぶ慣れてきてたのですが、ちょうどセールもやっていてよさそうだったの買ってみました。

特に良かったのはLiveViewとLiveComponentの棲み分け方で、インタラクションはLiveComponentに任せて、LiveViewはナビゲーションに専念する。
こうしておくことでLiveViewの処理がごちゃごちゃせず、かつURLフレンドリーなインタラクションが実現できてよかったです。このパターンは覚えて利用していこうと思いました。

残念な点は、利用されているコードが少し古いのでしばしばそのままでは動かず修正が必要でした。
以降はその修正点について書いていきます。

また修正済みのコードはこちらにあります。 https://github.com/yosu/meow

## Schemaless changeset

パラメータのバリデーションにEctoのSchemaless changeset を利用するのですが、フィールド定義でEcto.Enum型を利用するためのコードがエラーで動きませんでした。

before
```elixir
  sort_by: {:parametriezed, Ecto.Enum, Ecto.Enum.init(values: [:id, :name]
```

Ectoのドキュメントを参考に以下のようにすれば大丈夫でした。

after
```elixir
  sort_by: Ecto.ParameterizedType.init(Ecto.Enum, values: [:id, :name]),
```

## URLへのパラメータ埋め込み

本書では以下のようにパラメータ付きURLをセットしてナビゲーションしていました。

```elixir
def handle_info({:update, opts}, socket) do
  path = Routes.live_path(socket, __MODULE__, opts)
  {:noreply, push_patch(socket, to: path, replace: true}
end
```

Phoenix 1.7 以降ではルーターヘルパーがなくなり~pベースになったので以下のようになります。

```elixir
def handle_info({:update, opts}, socket) do
  path = ~p"/meow/?#{opts}"
  {:noreply, push_patch(socket, to: path, replace: true}
end
```


## Formの記述

フォームに関しても古い記述のため、CoreComponents の `<.simple_form>` と `<.input>` を使う形に置き換える必要がありました。

その際 `<.input>` のfield属性が `Phoenix.HTML.Form` を期待するため Schemaless changeset そのままでは渡せません。通常のEctoスキーマであれば `Phoenix.Component.to_form/2` で変換できるのですがこちらはSchemaless changesetには対応してません。

このため、まずフォームと連携できるようにパラメータの構造をSchemaless changeset（tuple）からEmbedded Schema（struct）に変更します。

before
```elixir
defmodule MeowWeb.Forms.FilterForm do
  import Ecto.Changeset

  @fields %{
    id: :integer,
    name: :string
  }

  @default_values %{
    id: nil,
    name: nil,
  }

  def parse(params) do
    {@default_values, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end
end
```

after
```elixir
defmodule MeowWeb.Forms.FilterForm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :integer
    field :name, :string
  end

  def parse(params) do
    %__MODULE__{}
    |> cast(params, [:id, :name])
    |> apply_action(:insert)
  end
end
```

定義したEmbbed schema を `Ecto.Changeset.cast/4` を使ってchangesetに変換後、前述の `to_form` を使って`<.input>` に渡せるform変数を作ります。


before
```heex
    <div>
      <.form :let={f} for={@changeset} as="filter" phx-submit="search" phx-target={@myself}>
        <div>
          <div>
            {label f, :id}
            {text_input f, :id}
            { error_tag f, :id}
          </div>
          <div>
            {label f, :name}
            {text_input f, :name}
            { error_tag f, :name}
          </div>
        </div>
        {submit "Search"}
        </.form>
    </div>
```

after
```heex
    <div>
      <.simple_form for={@form} as="filter" phx-submit="search" phx-target={@myself}>
        <.input field={@form[:id]} label="Id" />
        <.input field={@form[:name]} label="Name" />
        <.action>
          <.button>Search</.button>
        </.actions>
      </.simple_form>
    </div>
```

ここまででフォームの表示、サブミットができるようになります。

ただ、パラメータの定義をEmmbed Schemaにした関係でユーザー入力をパースした際に、struct が返ってくるようになります。
その後、パラメータをURLに含める処理で複数のパラメータを合成、フィルタリング（nilのパラメータを除く）処理をしますが、structはEnumerableでないためフィルタリングの処理がうまくいません。

結果、structで渡ってきたパラメータを一度Map.from_struct()でMapに変換する処理を挟みます。

```elixir
  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
    %{sorting: sorting, filter: filter} = socket.assigns

    %{}
    |> Map.merge(sorting)
    |> Map.merge(filter)
    |> Map.merge(overrides)
    |> Map.drop([:total_count])
    |> Map.from_struct() # 追記
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end
```

これでようやく期待する動作になりました。

## その他

無限スクロールの例については必要な時に試そうと思いコードは書いていないのですが、要素を追加していく処理をstreamを使った形に変える必要がありそうでした（本書ではphx-updateにappendを指定していますが[現在この指定はないため](https://hexdocs.pm/phoenix_live_view/html-attrs.html#dom-element-lifecycle)）。
