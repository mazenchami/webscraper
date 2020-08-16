defmodule Football do
  @moduledoc """
  Documentation for `Football`.
  """

  @premier_league_url "https://www.premierleague.com"

  @doc """
    a function that grabs football teams
  """
  def get_english_premier_league_football_clubs() do
    HTTPoison.get(@premier_league_url <> "/clubs")
    |> parse_football_clubs()
    |> get_url_html_body()
    |> Enum.map(fn body ->
      %{
        club: get_club_details(body),
        squad: get_squad_information(body)
      }
    end)
  end

  @doc """
    setup club details
  """
  def get_club_details(body) do
    club =
      body
      |> Floki.find("div.clubDetails")
      |> Enum.map(fn body ->
        %{
          name: get_body_informtion(body, ".team"),
          website: get_body_informtion(body, ".website a"),
          website_url: get_club_website_url(body)
        }
      end)

    List.first(club)
  end

  @doc """
    setup squad details
  """
  def get_squad_information(body) do
    # TODO: position, dob, height
    body
    |> parse_squad_urls()
    |> get_url_html_body()
    |> Enum.map(fn body ->
      %{
        name: get_body_informtion(body, "div.name"),
        number: get_body_informtion(body, "div.number"),
        nationality: get_body_informtion(body, "span.playerCountry")
      }
    end)
  end

  # private functions
  defp get_body_informtion(body, item) do
    body
    |> Floki.find(item)
    |> Floki.text()
  end

  defp get_url_html_body({_, urls}) do
    urls
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  defp get_club_website_url(body) do
    List.first(
      String.split(
        body
        |> Floki.find(".website a")
        |> Floki.attribute("href")
        |> Floki.text(),
        "?",
        trim: true
      )
    )
  end

  defp parse_football_clubs({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    urls =
      body
      |> Floki.find(".indexSection div ul li a")
      |> Floki.attribute("href")
      |> Enum.map(fn url ->
        @premier_league_url <> String.replace(url, "overview", "squad")
      end)

    {:ok, urls}
  end

  defp parse_football_clubs({:ok, %HTTPoison.Response{status_code: 404}}) do
    IO.puts("Not found :(")
  end

  defp parse_football_clubs({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect(reason)
  end

  defp parse_squad_urls(body) do
    urls =
      body
      |> Floki.find("a.playerOverviewCard")
      |> Floki.attribute("href")
      |> Enum.map(fn url -> @premier_league_url <> url end)

    {:ok, urls}
  end
end
