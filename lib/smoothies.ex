defmodule Smoothies do
  @moduledoc """
  Documentation for `Smoothies`.
  """

  @doc """
    main get smoothies recipe function
  """
  def get_smoothies_recipe do
    smoothies =
      get_smoothies_url()
      |> get_smoothies_html_body()
      |> Enum.map(fn body ->
        %{
          name: get_smoothie_name(body),
          ingredients: get_smoothie_ingredients(body),
          directions: get_smoothie_directions(body)
        }
      end)

    {:ok, smoothies}
  end

  @doc """
    display smoothies in a nice and readable way
  """
  def display_smoothies({_, smoothies}) do
    smoothies
    |> Enum.map(fn s ->
      IO.puts(s.name)
      IO.puts(s.ingredients)
      IO.puts(s.directions)
      IO.puts("+++++++++++++")
    end)
  end

  @doc """
    a function that grabs the smoothies urls
  """
  def get_smoothies_url() do
    HTTPoison.get(
      "https://www.allrecipes.com/recipes/138/drinks/smoothies/?internalSource=hubcard&referringContentType=Search&clickId=cardslot%201"
    )
    |> parse_smoothie_urls()
  end

  @doc """
    a crawler function that will fetch the HTML of each smoothie’s page.
  """
  def get_smoothies_html_body({_, urls}) do
    urls
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  @doc """
    get an ingredient by looking at its label's title attr
  """
  def get_smoothie_ingredients(body) do
    body
    |> Floki.attribute("label", "title")
    |> Floki.text(sep: "+")
    |> String.split("+")
  end

  @doc """
    get smoothies name
  """
  def get_smoothie_name(body) do
    body
    |> Floki.find("h1#recipe-main-content")
    |> Floki.text()
  end

  @doc """
    get smoothies directions
  """
  def get_smoothie_directions(body) do
    body
    |> Floki.find("span.recipe-directions__list--item")
    |> Floki.text(sep: "=>")
    |> String.split("=>")
  end

  # private functions
  defp parse_smoothie_urls({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    urls =
      body
      |> Floki.find("a.fixed-recipe-card__title-link")
      |> Floki.attribute("href")

    {:ok, urls}
  end

  defp parse_smoothie_urls({:ok, %HTTPoison.Response{status_code: 404}}) do
    IO.puts("Not found :(")
  end

  defp parse_smoothie_urls({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect(reason)
  end
end
