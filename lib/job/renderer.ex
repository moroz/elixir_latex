defmodule ElixirLatex.Renderer do
  alias ElixirLatex.Job
  alias ElixirLatex.Attachment

  defp working_directory do
    Application.get_env(:elixir_latex, :working_directory, "/tmp")
  end

  defp job_directory(job_name) do
    Path.join(working_directory(), job_name)
  end

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

  defp source_filename(job_name) do
    Path.join(job_directory(job_name), "main.tex")
  end

  def write_source(%Job{job_name: job_name}, source) do
    File.write(source_filename(job_name), source)
  end

  def render_to_pdf(%Job{job_name: job_name} = job, source) do
    :ok = create_job_directory(job_name)
    :ok = write_attachments(job)
    :ok = write_source(job, source)
  end
end
