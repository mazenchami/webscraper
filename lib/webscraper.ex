defmodule Webscraper do
  @moduledoc """
  Documentation for `Webscraper`.
  """

  @doc """
    scrapes allrecipes.com for smoothies
  """
  def smoothies do
    Smoothies.get_smoothies_recipe()
    |> Smoothies.display_smoothies()
  end

  @doc """
    scrapes premierleague.com for club details
  """
  def english_premier_league do
    Football.get_english_premier_league_football_clubs()
  end

  @doc """
    scrapes scholar.google.com for specific articles
  """
  def google_scholar(search_term) do
    Scholar.get_articles(search_term)
  end
end
