defmodule Finecode.Blog.Post do
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date]
  defstruct [:id, :author, :title, :body, :description, :tags, :date]

  def parse!(filename) do
    [year, month_day_id] = filename |> Path.split() |> Enum.take(-2)
    [month, day, id_with_md] = month_day_id |> String.split("-", parts: 3)

    id = Path.rootname(id_with_md)

    date = Date.from_iso8601!("#{year}-#{month}-#{day}")

    contents = parse_contents(File.read!(filename))

    struct!(__MODULE__, [id: id, date: date] ++ contents)
  end

  defp parse_contents(contents) do
    # Split contents into  ["==title==\n", "this title", "==tags==\n", "this, tags", ...]
    parts = Regex.split(~r/^==(\w+)==\n/m, contents, include_captures: true, trim: true)

    # Now chunk each attr and value into pairs and parse them
    for [attr_with_equals, value] <- Enum.chunk_every(parts, 2) do
      [_, attr, _] = String.split(attr_with_equals, "==")
      attr = String.to_atom(attr)
      {attr, parse_attr(attr, value)}
    end
  end

  defp parse_attr(:title, value),
    do: String.trim(value)

  defp parse_attr(:author, value),
    do: String.trim(value)

  defp parse_attr(:description, value),
    do: String.trim(value)

  defp parse_attr(:body, value),
    do: value |> Earmark.as_html!() |> Finecode.Blog.Highlighter.highlight()

  defp parse_attr(:tags, value),
    do: value |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.sort()
end
