defmodule ElixirLatex.Attachment do
  @type encoding :: :binary | :base64
  @type body :: iodata | nil
  @type filename :: binary | nil
  @type extension :: atom | binary | nil
  @type mimetype :: binary | nil

  defstruct body: nil, encoding: :binary, filename: nil, extension: nil, mimetype: nil

  @pattern ~r/^data:([a-z]+\/[a-z]+)(;base64)?,?/

  def from_data_url(data_url) when is_binary(data_url) do
    case Regex.scan(@pattern, data_url) do
      [[match, mimetype, ";base64"]] ->
        base64 = remove_match(data_url, match)
        {:ok, binary} = Base.decode64(base64)

        %__MODULE__{
          body: binary,
          extension: get_extension(mimetype),
          mimetype: mimetype,
          filename: random_filename()
        }

      [[match, mimetype]] ->
        uri_encoded = remove_match(data_url, match)
        binary = URI.decode(uri_encoded)

        %__MODULE__{
          body: binary,
          extension: get_extension(mimetype),
          mimetype: mimetype,
          filename: random_filename()
        }
    end
  end

  defp remove_match(data_url, match) do
    data_range = Range.new(String.length(match), -1)
    String.slice(data_url, data_range)
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
