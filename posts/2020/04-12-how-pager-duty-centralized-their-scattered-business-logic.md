==title==
PagerDutyのElixir上でビジネスロジックを一元化した話がおもしろかった

==author==
yosu

==description==

PagerDutyの「散らばったビジネスロジックを一元化した話（How I Centralized Our Scattered Business Logic Into One Clear Pipeline For Our Elixir Webhook Service）」という記事を読んだ感想です。

==tags==
elixir

==body==

次の記事を読みました。

[How I Centralized Our Scattered Business Logic Into One Clear Pipeline For Our Elixir Webhook Service | PagerDuty](https://www.pagerduty.com/eng/elixir-webhook-service/)

一見最初のコードも何の問題もないように見えます。
全体としてやりたいことはできてるし、それぞれのモジュールも割とシンプル。

でも、注意深く見るとビジネスロジックとしての判断が複数のモジュールに散らばっているのが分かります。

- Parserがexpireかどうかを見てエラーを出している（中身の**意味を解釈して、判断**してしまっている）
- Senderが返ってきたレスポンスを受け取り、**成功失敗を判断**し、次のロジック（DBモジュールへの保存）を呼んでいる

説明にフォーカスするために例がシンプルになっているけど、さらにビジネスロジック多い場合、
問題があったときにどこをみたらよいかや、新たなビジネスロジックを追加したいときに目星をつける場所に迷うのが目に浮かびます。

一元化されたコードはビジネスロジックを書く場所が１箇所なのでその辺の迷いがなくなっています。
こういうときに `with` 句が便利。
`with` については次の記事も参考になります。`with` に渡すパターンマッチを工夫することでエラーケースをうまく分岐しています。

[Elixir’s with statement is fantastic - AgentRisk: Superhuman Wealth Management](https://blog.agentrisk.com/elixirs-with-statement-is-fantastic-1431bcbcde3)


さらに複雑なビジネスロジックパイプラインを記述できるライブラリ、[Opus](https://github.com/zorbash/opus)も興味深い。小さなプロジェクトで試してみたい。
