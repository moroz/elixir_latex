defmodule ElixirLatex.Job do
  defmodule LatexError do
    defexception message: "LaTeX compilation job failed with an error"

    @moduledoc """
    Error raised when a LaTeX compilation job exits with a non-zero code.
    """
  end

  @type assigns :: %{optional(atom) => any}
  @type attachments :: %{optional(atom | binary) => iodata}
  @type layout :: {atom, binary | atom} | false
  @type view :: atom | false
  @type renderer :: binary | :xelatex | :latex | :pdflatex
  @type body :: iodata | nil

  @type t :: %__MODULE__{
          assigns: assigns,
          attachments: attachments,
          layout: layout,
          view: view,
          job_name: binary | nil,
          renderer: renderer,
          body: body
        }

  defstruct assigns: %{},
            attachments: %{},
            layout: false,
            view: false,
            job_name: nil,
            renderer: :xelatex,
            body: nil

  alias ElixirLatex.Job
  alias ElixirLatex.Attachment

  @spec assign(t, atom, term) :: t
  def assign(%Job{assigns: assigns} = job, key, value) when is_atom(key) do
    %{job | assigns: Map.put(assigns, key, value)}
  end

  @spec put_attachment(t, atom | binary, iodata) :: t
  def put_attachment(%Job{attachments: attachments} = job, key, value)
      when is_atom(key) do
    %{job | attachments: Map.put(attachments, key, value)}
  end

  @spec put_data_url_attachment(t, atom | binary, binary) :: t | :error
  def put_data_url_attachment(%Job{attachments: attachments} = job, key, data_url) do
    with %Attachment{} = attachment <- Attachment.from_data_url(data_url) do
      %{job | attachments: Map.put(attachments, key, attachment)}
    end
  end

  @spec put_layout(t, layout) :: t
  def put_layout(%Job{} = job, layout) do
    %{job | layout: layout}
  end

  @spec put_view(t, view) :: t
  def put_view(%Job{} = job, view) do
    %{job | view: view}
  end

  @spec set_renderer(t, renderer) :: t
  def set_renderer(%Job{} = job, renderer) when is_atom(renderer) or is_binary(renderer) do
    %{job | renderer: renderer}
  end

  @spec put_body(t, body) :: t
  def put_body(%Job{} = job, body) do
    %{job | body: body}
  end

  @spec render(t, binary) :: {:ok, binary} | {:error, term}
  def render(job, template, assigns \\ [])

  def render(%Job{} = job, template, assigns) when is_binary(template) do
    job = maybe_set_job_name(job)
    source = render_to_iodata(job, template, assigns)
    job = put_body(job, source)
    ElixirLatex.Renderer.render_to_pdf(job)
  end

  def render_to_iodata(%Job{} = job, template, assigns) when is_binary(template) do
    job = job |> maybe_set_job_name() |> assign_attachments()
    assigns = merge_assigns(job.assigns, assigns)
    render_with_layout(job, template, assigns)
  end

  defp merge_assigns(original, overrides) do
    Map.merge(to_map(original), to_map(overrides))
  end

  defp to_map(assigns) when is_map(assigns), do: assigns
  defp to_map(assigns) when is_list(assigns), do: :maps.from_list(assigns)

  defp random_job_name do
    :crypto.strong_rand_bytes(10)
    |> Base.encode16(case: :lower)
  end

  defp maybe_set_job_name(%Job{job_name: nil} = job) do
    %{job | job_name: random_job_name()}
  end

  defp maybe_set_job_name(job), do: job

  defp assign_attachments(%Job{attachments: attachments, assigns: assigns} = job) do
    attachments =
      for {key, %{filename: filename, extension: extension}} <- attachments, into: %{} do
        {key, "#{filename}.#{extension}"}
      end

    %{job | assigns: Map.put(assigns, :attachments, attachments)}
  end

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
