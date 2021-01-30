defmodule ElixirLatex.LatexHelpers do
  @special_char_regex ~r/([\\\^\%~\#\$%&_\{\}])/

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
end
