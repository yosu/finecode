==title==
From Phoenix.View To Phoenix.Component

==author==
yosu

==description==

Phoenix v1.7への移行に引き続きPhoenix.ViewからPhoenix.Componentに移行しました。

==tags==
elixir

==body==

Phoenix v1.7への移行に引き続きPhoenix.ViewからPhoenix.Componentに移行しました。

`phoenix_view` のページに移行ガイドがあるのでそれを参考にしました。

- [Replaced by Phoenix.Component - phoenix\_view](https://hexdocs.pm/phoenix_view/Phoenix.View.html#module-replaced-by-phoenix-component)

## ヘルパーの置き換え

`lib/finecode_web.ex` で定義されている `def view` ヘルパーマクロを `def html` としてコピーし、`use Phoenix.View` の代わりに
`use Phoenix.Component` を使うようにする。移行が終わるまでは `import Phoenix.View` も追加しておく。

```elixir
  def html do
    quote do
      use Phoenix.Component

      import Pheonix.View # 移行の間だけ追加

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import FinecodeWeb.ErrorHelpers
      use Gettext, backend: FinecodeWeb.Gettext

      unquote(verified_routes())
    end
  end
```

各viewで `use FincodeWeb, :view` の代わりに `use FincodeWeb, :html` を使い、`embed_templates "../templates/xx/*"` を呼ぶようにする。

例）
```elixir
defmodule FinecodeWeb.BlogView do
  use FinecodeWeb, :html

  embed_templates "../templates/blog/*"
end
```

## Phoenix.View の依存を削除

`lib/fincode_web.ex` の `def view` 定義と `def html` 中の `import Phoenix.View` を削除する。
その後、`mix.exs` の `deps` `:phoenix_view` を削除。

```elixir
  defp deps do
    [
-      {:phoenix_view, "~> 2.0"},
    ]
  end
```

`mix.lock` の依存も削除するため `mix deps.clean --unused` を実行する。


ここまででひとまず `Phoenix.Component` への移行は終わりですが、v1.7ではViewは標準ではなくなりディレクトリ構成も変わるので次回はその対応をしたいと思います。
