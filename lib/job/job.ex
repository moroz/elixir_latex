defmodule ElixirLatex.Job do
  defmodule LatexError do
    defexception message: "LaTeX compilation job failed with an error"

    @moduledoc """
    Error raised when a LaTeX compilation job exits with a non-zero code.
    """
  end

  @type assigns :: %{optional(atom) => any}
  @type attachments :: %{optional(atom) => iodata}
  @type layout :: {atom, binary | atom} | false
  @type view :: atom | false

  @type t :: %__MODULE__{
          assigns: assigns,
          attachments: attachments,
          layout: layout,
          view: view,
          job_name: binary | nil
        }

  defstruct assigns: %{}, attachments: %{}, layout: false, view: false, job_name: nil

  alias ElixirLatex.Job

  @spec assign(t, atom, term) :: t
  def assign(%Job{assigns: assigns} = job, key, value) when is_atom(key) do
    %{job | assigns: Map.put(assigns, key, value)}
  end

  @spec put_attachment(t, atom, iodata) :: t
  def put_attachment(%Job{attachments: attachments} = job, key, value)
      when is_atom(key) do
    %{job | attachments: Map.put(attachments, key, value)}
  end

  @spec put_layout(t, layout) :: t
  def put_layout(%Job{} = job, layout) do
    Map.put(job, :layout, layout)
  end

  @spec render(t, binary) :: {:ok, binary} | {:error, term}
  def render(job, template, assigns \\ [])

  def render(%Job{} = job, template, assigns) when is_binary(template) do
    job = maybe_set_job_name(job)
    assigns = merge_assigns(job.assigns, assigns)
    source = render_with_layout(job, template, assigns)
    render_to_pdf(source, job.job_name)
  end

  def render_to_pdf(source, job_name) when is_binary(job_name) do
  end

  defp merge_assigns(original, overrides) do
    Map.merge(to_map(original), to_map(overrides))
  end

  defp to_map(assigns) when is_map(assigns), do: assigns
  defp to_map(assigns) when is_list(assigns), do: :maps.from_list(assigns)

  defp random_job_name do
    :crypto.strong_rand_bytes(10)
    |> Base.encode16(case: :mixed)
  end

  defp maybe_set_job_name(%Job{job_name: nil} = job) do
    %{job | job_name: random_job_name()}
  end

  defp maybe_set_job_name(job), do: job

  defp render_with_layout(job, template, assigns) do
    render_assigns = Map.put(assigns, :job, job)

    case job.layout do
      {layout_mod, layout_tpl} ->
        inner = Phoenix.View.render(job.view, template, render_assigns)
        root_assigns = render_assigns |> Map.put(:inner_content, inner) |> Map.delete(:layout)
        Phoenix.View.render_to_iodata(layout_mod, "#{layout_tpl}.tex", root_assigns)

      false ->
        Phoenix.View.render_to_iodata(job.view, template, render_assigns)
    end
  end
end
