==title==
Hello World!

==author==
yosu

==description==
First blog post!

==tags==

==body==
## Hello H2

hello world!

この記事ではこのブログをどうやって作ったかについて書いていきたいと思います。
最近Elixirにはまっているのですが、作者のJoseが新しくDashbitという会社を始めて、
そのブログをどうやって作っているかの記事を読んだのがきっかけです。

これまでRailsやサイトジェネレータで作ったりしたこともあるのですが、個人ブログを作るにはどうもしっくり来なかった。
Joseのやり方は自分が不満に思っていたことにぴったりだなと思い実際試してみました。

### よかった点　

このやり方は軽量で自由度が高いのが魅力です。
まず、データベースが不要なのでセットアップや管理のオーバーヘッドが少ないです。
ブログの記事を書くのも好きなエディタで書け、Gitで履歴が管理できる（この辺はサイトジェネレータと同じ）。
コンテンツをプログラミングの要素として好きなように扱うことができます。


**hello world!**

- hello world!
- hello world!

### Hello H3

1. hello world!
1. hello world!

```python
def hello(message):
  puts(message)
```

```elixir
defmodule Finecode do
  def hello do
    IO.puts "Hello World!"
  end
end
```

--> [Top](/)
