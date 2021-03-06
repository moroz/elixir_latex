defmodule ElixirLatex.Attachment do
  @type body :: iodata | nil
  @type filename :: binary | nil
  @type extension :: atom | binary | nil
  @type mimetype :: binary | nil

  @type t :: %__MODULE__{
          body: body,
          filename: filename,
          extension: extension,
          mimetype: mimetype
        }

  defstruct body: nil, filename: nil, extension: nil, mimetype: nil

  @pattern ~r/^data:([a-z]+\/[a-z]+)(;base64)?,?/

  def from_data_url(data_url) when is_binary(data_url) do
    with {:ok, mimetype, binary} <- parse_data_url(data_url) do
      %__MODULE__{
        body: binary,
        extension: get_extension(mimetype),
        mimetype: mimetype,
        filename: random_filename()
      }
    end
  end

  @spec is_valid_data_url(data_url :: term) :: boolean
  def is_valid_data_url(data_url) when is_binary(data_url) do
    parse_data_url(data_url) != :error
  end

  def is_valid_data_url(_), do: false

  @spec parse_data_url(data_url :: binary) :: {:ok, binary, binary} | :error
  def parse_data_url(data_url) when is_binary(data_url) do
    case Regex.scan(@pattern, data_url) do
      [[match, mimetype, ";base64"]] ->
        base64 = remove_match(data_url, match)
        {:ok, binary} = Base.decode64(base64)
        {:ok, mimetype, binary}

      [[match, mimetype]] ->
        uri_encoded = remove_match(data_url, match)
        binary = URI.decode(uri_encoded)
        {:ok, mimetype, binary}

      _ ->
        :error
    end
  end

  defp remove_match(data_url, match) do
    data_range = Range.new(String.length(match), -1)

    String.slice(data_url, data_range)
    |> String.trim_trailing()
  end

  def random_filename do
    :crypto.strong_rand_bytes(10)
    |> Base.encode16(case: :lower)
  end

  def get_extension(mimetype) do
    mimetype
    |> MIME.extensions()
    |> List.first()
  end
end
