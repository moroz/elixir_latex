defmodule ElixirLatex.LatexHelpers do
  @special_char_regex ~r/([\\\^\%~\#\$%&_\{\}])/

  @spec escape_latex(string :: binary) :: binary
  @doc """
  Replaces all characters that have a special meaning in latex sources
  with their corresponding escape sequences.
  """
  def escape_latex(string) when is_binary(string) do
    Regex.replace(@special_char_regex, string, &replace_special_char/1)
  end

  @replacement_map %{
    "#" => "\\#",
    "$" => "\\$",
    "%" => "\\%",
    "&" => "\\&",
    "~" => "\\~{}",
    "_" => "\\_",
    "^" => "\\^{}",
    "\\" => "\\textbackslash{}",
    "{" => "\\{",
    "}" => "\\}"
  }

  for {source, replacement} <- @replacement_map do
    defp replace_special_char(unquote(source)), do: unquote(replacement)
  end

  @spec format_plain_as_latex(plain :: iodata) :: binary
  def format_plain_as_latex(string) when is_binary(string) do
    string
    |> String.trim()
    |> escape_latex()
    |> String.replace(~r/(\r?\n){2,}/, "\\par{}")
    |> String.replace(~r/(\r?\n)/, "\\\\\\\\")
  end

  def format_plain_as_latex(iodata) when is_list(iodata) do
    IO.iodata_to_binary(iodata)
    |> format_plain_as_latex()
  end
end
