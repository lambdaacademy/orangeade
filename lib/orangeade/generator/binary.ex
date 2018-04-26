defmodule Orangeade.Generator.Binary do
  @moduledoc """
  Provides a function for creating a stream of binaries.
  """

  alias Orangeade.Generator.BoundNatural

  @doc """
  Given a binary byte size limit creates a stream of binaries.

  ## Examples

      iex(1)> s = Orangeade.Generator.Binary.stream(byte_size_limit: 5)
      [<<1>> | #Function<0.77151006/0 in Orangeade.Generator.Binary.do_stream/1>]

      iex(2)> Caffeine.Stream.take(s, 5)
      [<<1>>, "|\e", <<14, 197, 240, 127>>, "", <<162, 201, 164, 35>>]

  """
  @spec stream(byte_size_limit: non_neg_integer) :: Caffeine.Stream.t()
  def stream(byte_size_limit: l) do
    do_stream(
      byte_size: BoundNatural.stream(limit: l),
      fill: BoundNatural.stream(limit: 256)
    )
  end

  defp do_stream(
         byte_size: byte_size_stream,
         fill: number_stream
       ) do
    {number_list, reduced_number_stream} =
      drain_numbers(Caffeine.Stream.head(byte_size_stream), number_stream)

    rest = fn ->
      do_stream(
        byte_size: Caffeine.Stream.tail(byte_size_stream),
        fill: reduced_number_stream
      )
    end

    Caffeine.Stream.construct(list_to_binary(number_list), rest)
  end

  defp drain_numbers(n, number_stream) do
    {Caffeine.Stream.take(number_stream, n), reduce_stream(n, number_stream)}
  end

  defp reduce_stream(0, reduced_stream) do
    reduced_stream
  end

  defp reduce_stream(i, stream) do
    reduce_stream(i - 1, Caffeine.Stream.tail(stream))
  end

  defp list_to_binary(list) do
    IO.iodata_to_binary(list)
  end
end
