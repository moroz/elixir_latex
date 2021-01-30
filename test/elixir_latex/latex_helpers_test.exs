defmodule ElixirLatex.LatexHelpersTest do
  use ExUnit.Case
  alias ElixirLatex.LatexHelpers

  @sample_text "\\documentclass[a4paper]{article}"

  test "escape_latex/1 replaces special LaTeX chars with escape sequences" do
    actual = LatexHelpers.escape_latex(@sample_text)
    assert actual == "\\textbackslash{}documentclass[a4paper]\\{article\\}"
  end

  describe "format_plain_as_latex/1" do
    @source_paragraph """
    你好，世界！
    此為測試段落
    """

    @expected_paragraph "你好，世界！\\\\此為測試段落"

    test "converts single newlines to LaTeX newline literals" do
      actual = LatexHelpers.format_plain_as_latex(@source_paragraph)
      assert actual == @expected_paragraph
    end
  end
end
