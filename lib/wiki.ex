defmodule Wiki do
  @moduledoc """
  Documentation for `Wiki`.
  """

  @wikipedia_url "https://en.wikipedia.org"

  @doc """
    a function that grabs football teams
  """
  def test() do
    HTTPoison.get(transform_url("/wiki/List_of_football_clubs_in_England"))
    |> parse_body()
    |> get_url_html_body()
  end

  # private functions
  defp get_url_html_body({_, %{headers: headers, rows: rows}}) do
    headerTitles =
      headers
      |> Enum.map(fn item -> item |> Floki.text() end)

    rows
    |> Enum.map(fn item ->
      item
      |> Floki.find("td a")
      |> Enum.map(fn club ->
        IO.inspect(club)

        # IO.inspect(club |> Floki.text())
        # IO.inspect(List.first(club |> Floki.attribute("href")))

        %{
          club: club |> Floki.text(),
          clubUrl: List.first(club |> Floki.attribute("href"))
        }

        # %{
        #   club: ,
        #   leagueDivision: ,
        #   level: ,
        #   nickname: ,
        #   change: ,
        # }
      end)
    end)

    # urls
    # |> Enum.map(fn url -> HTTPoison.get(url) end)
    # |> Enum.map(fn {_, result} -> result.body end)
  end

  defp parse_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    headers =
      body
      |> Floki.find("table.sortable tbody tr th")

    rows =
      body
      |> Floki.find("table.sortable tbody tr")

    {:ok, %{headers: Enum.take(headers, 5), rows: List.delete_at(rows, 0)}}
  end

  defp parse_body({:ok, %HTTPoison.Response{status_code: 404}}) do
    IO.puts("Not found :(")
  end

  defp parse_body({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect(reason)
  end

  defp transform_url(add_on_url) do
    @wikipedia_url <> add_on_url
  end
end
