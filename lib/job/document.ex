defmodule ElixirLatex.Document do
  defmacro __using__(opts) do
    unless view = Keyword.get(opts, :view) do
      raise ArgumentError,
            "no view was set, " <>
              "you can set one with `use ElixirLatexDocument, view: MyApp.EmailView`"
    end

    layout = Keyword.get(opts, :layout)

    quote bind_quoted: [view: view, layout: layout] do
      import ElixirLatex.Job
    end
  end
end
