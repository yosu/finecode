==title==
daisyUI の利用

==author==
yosu

==description==

Phoenix 1.7 で daisyUI を利用するためのまとめです。

==tags==
elixir,phoenix,daisyui

==body==

Phoenix 1.8 の[デフォルトで採用されそう](https://github.com/phoenixframework/phoenix/issues/6121)な [daisyUI](https://daisyui.com/) をPhoenix 1.7 で導入する際のまとめです。
自作のサービスはまだ Phoenix 1.7 のため、1.8になるまでの間の備忘録として残しておきます。
（daisyUIの[Phoenixガイド](https://daisyui.com/docs/install/phoenix/)では Phoenix 1.8 rc版を使えばインストール不要という流れが書かれています）


## インストール

```bash
$ npm i -D daisyui@latest --prefix assets
```

`tailwind.config.js` を編集。

```js
module.exports = {
  // ...
  plugins: [
    require("daisyui"), // 追加
    require("@tailwindcss/forms"),
    // ...
  ]
}
```

これで開発環境では daysyUI を利用できるようになります。

## リリースの作成

本番環境へのデプロイではアセットのセットアップに `mix assets.deploy` を利用しますが、その際に追加の手順が必要になります。
`mix phx.gen.release --docker` で生成した Dockerfile の場合、以下の行を追加します。

```Dockerfile
# npmを利用できるようにするため、RUNコマンドの2~4行目を追加
# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash \
    && apt-get install -y nodejs \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# ...
COPY assets assets

# daisyUIの依存取得のため以下を追加
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

# compile assets
RUN mix assets.deploy
```

特にむずかしいことはないのですが参考まで。



