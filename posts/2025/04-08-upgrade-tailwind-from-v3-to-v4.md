==title==
Tailwind v4へのアップグレード

==author==
yosu

==description==

Phoenix 1.7 で Tailwind v3 から v4 へのアップグレード手順です。

==tags==
elixir

==body==

[daisy UI を導入](http://localhost:4010/blog/use-daisy-ui) してみたのですが、Tabのスタイルがうまく当たらない問題があり、もしかしたらTailwindのバージョンがv3が原因ではないかと思い、v4にアップグレードしてみました。
v4にアップグレードすると無事デモと同じようにスタイルが当たるようになりました。

少しつまずいたのでその流れを書いておきます。

## Tailwind のアップグレード

`config/config.exs` で利用するTailwindのバージョンを変更します。
どのバージョンを利用するかは[Tailwindのリリース](https://github.com/tailwindlabs/tailwindcss/releases)から選びます。
この記事を書いてる時点の最新は4.1.3 でした。

```elixir
config :tailwind,
  version:"4.1.3", # <- version "3.4.3" から変更
```

バージョンを変更後、 `mix tailwind.install` コマンドを実行して指定したバージョンのTailwindをインストールします。

その後 `mix phx.server` を実行すると以下のエラーが出ました。

> Error: Can't resolve 'tailwindcss/base' in '/path/to/myapp/assets/css'

[Tailwind のフレームワークガイド](https://tailwindcss.com/docs/installation/framework-guides/phoenix)を見ると、
`app.css` に記述する@importの指定方法が変わっているため、それを反映します。

```css
/* 削除
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";
*/
@import "tailwindcss"; /* 追加 */
```

この状態で `mix phx.server` を実行すると無事エラーが出なくなりました。


しかし、スタイルが当たらない状態になってしまいました。
調べてみると `config/config.exs` の修正がさらに必要でした。

```diff
 config :tailwind,
  version: "4.1.3",
   myapp: [
     args: ~w(
-      --config=tailwind.config.js
-      --input=css/app.css
-      --output=../priv/static/assets/app.css
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
     ),
-    cd: Path.expand("../assets", __DIR__)
+    cd: Path.expand("../", __DIR__)
   ]
```

指し示すパスの場所は同じなのですが、ソースの検出方法が変わった影響か以前の指定方法だとうまくいかないようです。

参考: [Mix tailwind - 4.0.0-beta.1 support - Phoenix Forum / Chat / Discussions - Elixir Programming Language Forum](https://elixirforum.com/t/mix-tailwind-4-0-0-beta-1-support/67636/2)

以上でTailwindのスタイルは当たるようになりましたが、daisyUIが適用されない状態になったので次はそれを修正していきます。

### daisyUI の適用

Tailwind v4 では pluginの指定方法が変わったようです。

`tailwind.config.js` から以下の行を削除

```js
plugins: [
  require("daisyui"), // この行を削除
]
```

`app.css` に以下の行を追加

```css
@import "tailwindcss";
@plugin "daisyui"; /* 追加*/
```

これで無事daisyUIのスタイルも当たるようになりました。


## 最終的な差分

最終的な更新の差分は以下のとおりです。

assets/css/app.css
```diff
-@import "tailwindcss/base";
-@import "tailwindcss/components";
-@import "tailwindcss/utilities";
+@import "tailwindcss";
+@plugin "daisyui";
```

assets/tailwind.config.js
```js
 module.exports = {
   plugins: [
-    require("daisyui"),
```

config/config.exs
```elixir
 config :tailwind,
-  version: "3.4.3",
+  version: "4.1.3",
   dahlia: [
     args: ~w(
-      --config=tailwind.config.js
-      --input=css/app.css
-      --output=../priv/static/assets/app.css
+      --input=assets/css/app.css
+      --output=priv/static/assets/app.css
     ),
-    cd: Path.expand("../assets", __DIR__)
+    cd: Path.expand("../", __DIR__)
   ]
```

