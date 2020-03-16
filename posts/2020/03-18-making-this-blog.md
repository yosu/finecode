==title==
Phoenixでブログを作った

==author==
yosu

==description==
José Valimの記事に影響を受けて、Phoenixで自分のブログを作ってみました。

==tags==
elixir, phoenix, render

==body==
Elixirの作者José Valimが[Dashbit](https://dashbit.co/)のブログに書いた
[Welcome to our blog: how it was made!](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made)
（Dashbitのブログをどうやって作ったか）を読んだのがきっかけでこのブログサイトを作りました。

記事の中でデータベースを使わずブログ記事をGitで管理しつつ、最終的なコンテンツはアプリケーションから動的に生成する方法
（静的サイトジェネレータとは違ったやり方）が紹介されていてこれはすばらしいアイディアだと思いました。

最近Elixirにはまっていることもあり、何よりPhoenixとElixirの基本的なことができれば自由度の高いブログサイトが作れそうなのでやってみました。

## Dashbitブログの仕組み

詳しくはの記事に書いてあるのですが、要約すると

- 記事をテキストファイルで書く
- 記事ファイルを **コンパイル時にパースし** 、アプリケーション起動後は構造体データとして記事情報にアクセスできるようにする
- あとは好きに使うだけ（MarkdownをHTMLに変換したり、シンタックスハイライトをつけたり）


記事ファイルは以下のようなフォーマットで書きます（書いたものを自分でパースするので好きに変えてしまってもいい）。

<pre>
 ==title==
 Welcome to our blog: how it was made!

 ==author==
 José Valim

 ==description==
 Today we announce...

 ==tags==
 elixir, phoenix

 ==body==
 Two weeks ago we officially unveiled Dashbit...
</pre>

これを以下の構造体として読み込みます。

```elixir
defmodule Dashbit.Blog.Post do
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date]
  defstruct [:id, :author, :title, :body, :description, :tags, :date]
end
```

具体的には以下のようなコードで `defmodule` 定義中でファイル読み込み、パースまでしてしまい、それをモジュール属性から利用できるようにしてしまいます。

```elixir
defmodule Dashbit.Blog do
  alias Dashbit.Blog.Post

  posts_paths = "posts/**/*.md" |> Path.wildcard() |> Enum.sort()

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts do
    @posts
  end
end
```

こんなことできるとは全然思いつきもしませんでした。

### 実際に作ってみた

Dashbitの記事通りやるとMarkdownで記事が書けたり、シンタックスハイライトのついたブログが作れました。

ちょっと引っかかったのが手元のElixirバージョンが古かったので（と言っても1.9.4）、1.10以上に上げる必要がありました。

```elixir
# 以下のコードが1.9以下だと通らない。
# 第3引数で{:desc, module()} の形式を受け付けるのは1.10から
Enum.sort_by(posts, & &1.date, {:desc, Date})
```

### デプロイ

Phoenixのデプロイが初めてだったのでちょっと迷いましたが、最終的には以下の記事を参考に[render.com](https://render.com/) を利用しています。

- [RealWorldPhoenix · Getting Real with Phoenix and Elixir](https://realworldphoenix.com/blog/2019-12-31/lets_deploy)

記事の内容自体もとても良いのですが、render.com はElixir/Phoenixをきちんとサポートしていてドキュメントも分かりやすくてよかったです。
デフォルトのElixirバージョンは1.9だったため、バージョンを上げる必要がありましたがドキュメントを見て環境変数を設定するだけで簡単に対応ができました。

参考: [Specifying Elixir and Erlang Versions | Render](https://render.com/docs/elixir-erlang-versions)

## 感想

このやり方はデータベースを使わないので運用が楽なこと、静的サイトジェネレータを学ぶといった学習コストが少なく、
その分自分でコーディングする必要はありますが自由度が高いことが魅力です。

PhoenixのLivereloadの仕組みに乗っかって記事を確認しながら書けるのも便利です。

デザインを変えたり動的なコンテンツを作ってみたりしばらくは楽しんでみたいと思います。
