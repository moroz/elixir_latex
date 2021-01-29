defmodule ElixirLatex.Renderer do
  alias ElixirLatex.Job
  alias ElixirLatex.Attachment

  @xelatexoptions ["-halt-on-error", "-interaction=nonstopmode"]

  defp working_directory do
    Application.get_env(:elixir_latex, :working_directory, "/tmp")
  end

  defp job_directory(job_name) when is_binary(job_name) do
    Path.join(working_directory(), job_name)
  end

  defp job_directory(%Job{job_name: job_name}), do: job_directory(job_name)

  defp create_job_directory(job_name) do
    job_name
    |> job_directory()
    |> File.mkdir_p()
  end

  def write_attachments(%Job{job_name: job_name, attachments: attachments}) do
    base_directory = job_directory(job_name)

    for {_, attachment} <- attachments do
      write_attachment(attachment, base_directory)
    end

    :ok
  end

  def write_attachment(
        %Attachment{filename: filename, extension: extension, body: body},
        base_directory
      ) do
    path = Path.join(base_directory, filename <> "." <> to_string(extension))
    File.write!(path, body)
  end

  defp source_filename(job) do
    Path.join(job_directory(job), "main.tex")
  end

  defp target_filename(job) do
    Path.join(job_directory(job), "main.pdf")
  end

  defp resolve_executable(%Job{renderer: path}) when is_binary(path), do: path

  defp resolve_executable(%Job{renderer: atom}) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> System.find_executable()
  end

  defp compile(job) do
    System.cmd(resolve_executable(job), @xelatexoptions ++ [source_filename(job)],
      cd: job_directory(job)
    )
  end

  defp clean_up(job) do
    File.rm_rf(job_directory(job))
  end

  def write_source(%Job{body: body} = job) do
    File.write(source_filename(job), body)
  end

  def render_to_pdf(%Job{job_name: job_name} = job) do
    :ok = create_job_directory(job_name)
    :ok = write_attachments(job)
    :ok = write_source(job)

    case compile(job) do
      {_, 0} ->
        {:ok, pdf} = File.read(target_filename(job))
        clean_up(job)
        {:ok, pdf}

      {error, 1} ->
        clean_up(job)
        {:error, error}
    end
  end
end
