==title==
Enum.max, min で日付（Date）を扱うときの注意

==author==
yosu

==description==

Enum.max, min に Date リストを渡したときに期待する挙動にならないことがありました。　

==tags==
elixir

==body==

日付ごとの体調（0〜10）をグラフを表示させるプログラムを書いていたときのことです。
3月の間は正しくグラフ表示されていたのが、4月に入ってグラフが表示されなくなりました。

問題はグラフ表示に使う日付を列挙するコードにありました。
記録に抜けがある日もグラフの軸に表示させるため以下のようなコードを書いていました。

```elixir
  def pad_dates([]), do: []

  def pad_dates(dates) do
    last_date = Enum.max(dates)
    first_date = Enum.min(dates)

    Date.range(first_date, last_date)
    |> Enum.to_list()
  end
```


原因はEnum.maxのヘルプでわかりました（ヘルプがとても親切！）。

> The fact this function uses Erlang's term ordering means that the comparison is
> structural and not semantic. For example:
>
>    iex> Enum.max([~D[2017-03-31], ~D[2017-04-01]])
>    ~D[2017-03-31]
>
> In the example above, max/2 returned March 31st instead of April 1st because
> the structural comparison compares the day before the year. For this reason,
> most structs provide a "compare" function, such as Date.compare/2, which
> receives two structs and returns :lt (less-than), :eq (equal to), and :gt
> (greater-than). If you pass a module as the sorting function, Elixir will
> automatically use the compare/2 function of said module:
>
>    iex> Enum.max([~D[2017-03-31], ~D[2017-04-01]], Date)
>    ~D[2017-04-01]

Enum.min,max 利用される比較演算がデータ構造に依存するためで、日付の場合、年月日の順ではなく日月年で評価されてしまうのが問題でした。
結果、比較演算のモジュールとして `Date` を渡してあげれば期待通りの動きになりました。

```elixir
  def pad_dates([]), do: []

  def pad_dates(dates) do
    last_date = Enum.max(dates, Date)
    first_date = Enum.min(dates, Date)

    Date.range(first_date, last_date)
    |> Enum.to_list()
  end
```

