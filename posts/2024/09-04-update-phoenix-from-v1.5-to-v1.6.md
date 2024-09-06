==title==
Phoenix をv1.5からv1.6に更新

==author==
yosu

==description==

Phoenix v1.5 で作られていたこのサイトをPhoenix v1.6に移行したのでそのメモです。

==tags==
elixir

==body==

Phoenix v1.5 で作られていたこのサイトをPhoenix v1.6に移行したのでそのメモです。


ざっくりとした流れ

- 公式の手順に従って変更
- Render向けデプロイ対応
- 不具合の修正

## 公式の手順に従って修正

Phoenixの[リリースノート](https://www.phoenixframework.org/blog/phoenix-1.6-released)からアップデートの[手順](https://gist.github.com/chrismccord/2ab350f154235ad4a4d0f4de6decba7b)へのリンクがあるのでそれに従って進めました。

### 依存ライブラリの更新

`mix.exs` を以下のように更新

```elixir
def deps do
    [
      {:phoenix, "~> 1.6.0"},
      ...
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.16.4"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      ...
    ]
end
```

その後、`mix deps.get` を実行。


### esbuild へ移行

webpackのコンフィグと`node_modules`ディレクトリを削除。

```
$ rm assets/webpack.config.js assets/package.json assets/package-lock.json assets/.babelrc
$ rm -rf assets/node_modules
```

`mix.exs` の `deps` に `esbuild` を追加

```elixir
def deps do
  [
    ...
    {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
  ]
end
```


`config/config.exs` を修正。

```elixir
# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
```

※`--external:/images/*` は追記した。

参考: https://hexdocs.pm/phoenix/1.6.2/asset_management.html#images-fonts-and-external-files



`config/dev.exs`のウォッチャー設定をesbuildに変更。

```elixir
config :finecode, FinecodeWeb.Endpoint,
  ...,
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch --loader:.jpg=file)]}
  ]
```

`--loader:.jpg=file` はCSSの `background-image` 指定でエラーが出たため追記。

参考： [[Image assets in CSS on Phoenix 1.6.0-rc.0](https://elixirforum.com/t/image-assets-in-css-on-phoenix-1-6-0-rc-0/42262)
](https://elixirforum.com/t/image-assets-in-css-on-phoenix-1-6-0-rc-0/42262)


mixコマンドのエイリアスを追加。

```elixir
  defp aliases do
    [
      ...,
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
```


`$ mix assets.deploy` を実行してesbuildのバイナリダウンロードとアセットビルドをする。

htmlテンプレート内の `js/app.js` と `css/app.css` の記述を `assets/app.js` と `assets/app.css` に修正。

```
    <link phx-track-static rel="stylesheet" href={Routes.static_path(@conn, "/assets/app.css")}/>
    <script defer phx-track-static type="text/javascript" src={Routes.static_path(@conn, "/assets/app.js")}></script>
```

静的ファイルのPlug設定（`lib/finecode_web/endpoint.ex`）から `js/` `css/`を削除して `assets` を追加 。

```elixir
  plug Plug.Static,
    at: "/",
    from: :finecode,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)
```


## Render向けデプロイ対応

このサイトは [Render](https://render.com) 上で動かしているので、Render向けに行った変更メモ。

### ビルドスクリプトの修正

アセット周りの処理を `mix assets.deploy` を実行するように変更。

```bash
#!/bin/bash

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
# npm install --prefix ./assets
# npm run deploy --prefix ./assets
# mix phx.digest
MIX_ENV=prod mix assets.deploy

# Remove the existing release directory and build the release
rm -rf "_build"
MIX_ENV=prod mix release
```

デプロイしてみると起動時にクラッシュしたためログを見てみるとErlangのバージョンが古いことが原因のようだったので管理ページから明示的に環境変数指定するようにした（これまでは指定なしでデフォルトのバージョンで動いていた）。

- ELIXIR_VERSION: 1.15.2
- ERLANG_VERSION: 26.0.2

これでクラッシュせず動くようになった。

## 不具合の修正

リリースしてみるとロゴ画像とfaviconがリンク切れするようになった。CSSで指定している背景画像は問題なかった。
これまで `assets/static/images` 配下を`/images/...` で参照できていたのができなくなっていた。

v1.6からはjs/cssとそこから参照されるリソース以外は直接 `priv/static` 以下に入れないとリンクが切れることが分かった。

参考: [Loading images and assets in phoenix 1.6.2](https://elixirforum.com/t/loading-images-and-assets-in-phoenix-1-6-2/43259/7)

このため `.gitignore` ファイルも以下のように変更。

- pre-1.6

```elixir
# Since we are building assets from assets/,
# we ignore priv/static. You may want to comment
# this depending on your deployment strategy.
  /priv/static/
```

- 1.6.x

```elixir
# Ignore assets that are produced by build tools.
/priv/static/assets/

# Ignore digested assets cache.
/priv/static/cache_manifest.json
```

それから、`assets/static/images` 配下のファイルを `priv/static/images` 配下に移動してコミットしたところリンク切れしなくなった（HTML側の修正はなし）。

