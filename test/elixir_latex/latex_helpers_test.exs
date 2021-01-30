defmodule ElixirLatex.LatexHelpersTest do
  use ExUnit.Case
  alias ElixirLatex.LatexHelpers

  @sample_text "\\documentclass[a4paper]{article}"

  test "escape_latex/1 replaces special LaTeX chars with escape sequences" do
    actual = LatexHelpers.escape_latex(@sample_text)
    assert actual == "\\textbackslash{}documentclass[a4paper]\\{article\\}"
  end
end
