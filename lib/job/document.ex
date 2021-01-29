defmodule ElixirLatex.Document do
  defmacro __using__(opts) do
    unless view = Keyword.get(opts, :view) do
      raise ArgumentError,
            "no view was set, " <>
              "you can set one with `use ElixirLatexDocument, view: MyApp.EmailView`"
    end

    layout = Keyword.get(opts, :layout, false)

    quote bind_quoted: [view: view, layout: layout] do
      import ElixirLatex.Job

      @view view
      @layout layout

      def new do
        %ElixirLatex.Job{}
        |> put_view(@view)
        |> put_layout(@layout)
      end
    end
  end
end
