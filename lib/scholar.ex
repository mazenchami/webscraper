defmodule Scholar do
  @moduledoc """
  Documentation for `Scholar`.
  """

  @med_rx_iv "https://www.medrxiv.org"

  @doc """
    a function that grabs all the articles
  """
  def get_articles(search_term) do
    search_term = String.replace(search_term, " ", "%252B")
    page_one_search_url = transform_url("/search/") <> search_term
    page_two_search_url = transform_url("/search/") <> search_term <> "?page=1"
    page_three_search_url = transform_url("/search/") <> search_term <> "?page=2"
    page_four_search_url = transform_url("/search/") <> search_term <> "?page=3"
    page_five_search_url = transform_url("/search/") <> search_term <> "?page=4"

    page_one_results =
      HTTPoison.get(page_one_search_url)
      |> parse_search_body()
      |> get_content_html_body()

    page_two_results =
      HTTPoison.get(page_two_search_url)
      |> parse_search_body()
      |> get_content_html_body()

    page_three_results =
      HTTPoison.get(page_three_search_url)
      |> parse_search_body()
      |> get_content_html_body()

    page_four_results =
      HTTPoison.get(page_four_search_url)
      |> parse_search_body()
      |> get_content_html_body()

    page_five_results =
      HTTPoison.get(page_five_search_url)
      |> parse_search_body()
      |> get_content_html_body()

    %{
      page_one_results: page_one_results,
      page_two_results: page_two_results,
      page_three_results: page_three_results,
      page_four_results: page_four_results,
      page_five_results: page_five_results
    }
  end

  @doc """
    a function that grabs all content specific information
  """
  def get_content_html_body({_, articles}) do
    articles
    |> Enum.map(fn article ->
      {_, main_items_body} =
        HTTPoison.get(transform_url(article))
        |> parse_content_body()

      {_, info_items_body} =
        HTTPoison.get(transform_url(article) <> ".article-info")
        |> parse_content_body()

      %{
        page_url: transform_url(article),
        abstract: main_items_body |> Floki.find("div.section.abstract p") |> Floki.text(),
        title: main_items_body |> Floki.find("h1#page-title") |> Floki.text(),
        author: get_author_information(info_items_body)
      }
    end)
  end

  @doc """
    a function that grabs all the authors specific information
  """
  def get_author_information(info_items_body) do
    email =
      info_items_body
      |> Floki.find("li.corresp span.em-addr")
      |> Floki.text()
      |> String.replace("{at}", "@")

    contributor_list =
      info_items_body
      |> Floki.find("ol.contributor-list")

    names_list =
      contributor_list
      |> Floki.find("span.name")
      |> Enum.map(fn item ->
        item
        |> Floki.text()
      end)

    emails_list =
      contributor_list
      |> Floki.find("span.contrib-email span.em-addr")
      |> Enum.map(fn item ->
        item
        |> Floki.text()
      end)

    %{
      contributor_email: email,
      contributors: %{
        names: names_list,
        emails: emails_list
      }
    }
  end

  # private functions
  defp parse_content_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp parse_content_body({:ok, %HTTPoison.Response{status_code: 404}}) do
    IO.puts("Not found :(")
  end

  defp parse_content_body({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect(reason)
  end

  defp parse_search_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    articles =
      body
      |> Floki.find("li.search-result a.highwire-cite-linked-title")
      |> Floki.attribute("href")

    {:ok, articles}
  end

  defp parse_search_body({:ok, %HTTPoison.Response{status_code: 404}}) do
    IO.puts("Not found :(")
  end

  defp parse_search_body({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect(reason)
  end

  defp transform_url(add_on_url) do
    @med_rx_iv <> add_on_url
  end
end
