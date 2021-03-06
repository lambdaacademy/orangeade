defmodule Orangeade.Generator.PrintableASCIICharlist do
  @moduledoc """
  Provides a function for creating a stream of ASCII charlists.
  """

  alias Orangeade.Generator.BoundNatural
  alias Orangeade.Generator.PrintableASCIICharacter

  @doc """
  Creates a stream of ASCII charlists of default length of 30.

  ## Examples

      iex(1)> s = Orangeade.Generator.PrintableASCIICharlist.stream()
      ['!' |
      #Function<0.59794914/0 in Orangeade.Generator.PrintableASCIICharlist.do_stream/1>]

      iex(2)> Caffeine.Stream.take(s, 10)
      ['!', 'he@E@?l{$w@7$O:!2[:-LI', 'BG@[&!^7:gp]f% W4S8qjgve,s@#$',
      '}vul?B;(GLGZ_J9Ha>!B', '%8#T]6q^iD[hY"kJM\\-8u4?,-J_:W',
      'V/L=Z]Pi$}deD-.a>wR-', '@u\\O>/0c&Itkh', '!h=rg2/N9r{81&}"74',
      '=^IVK>#<;<mBar#:CnC', '0m\\?6GLeXs$%:c']

  """

  @spec stream() :: Caffeine.Stream.t()
  def stream do
    stream(max_word_length: 30)
  end

  @doc """
  Creates a stream of ASCII charlists of given length.

  ## Examples

     iex(1)> s = Orangeade.Generator.PrintableASCIICharlist.stream(max_word_length: 5)
     ['!' |
     #Function<0.59794914/0 in Orangeade.Generator.PrintableASCIICharlist.do_stream/1>]

     iex(2)> Caffeine.Stream.take(s, 10)
     ['!', 'he', '@E@?', [], 'l{$w', [], '@7$', 'O:!', '2[:-', 'LIBG']

  """
  @spec stream(max_word_length: non_neg_integer) :: Caffeine.Stream.t()
  def stream(max_word_length: l) do
    do_stream(
      length: BoundNatural.stream(limit: l),
      fill: PrintableASCIICharacter.stream()
    )
  end

  defp do_stream(length: length_stream, fill: charlist_stream) do
    {head, reduced_charlist_stream} =
      drain_chars(Caffeine.Stream.head(length_stream), charlist_stream)

    rest = fn ->
      do_stream(
        length: Caffeine.Stream.tail(length_stream),
        fill: reduced_charlist_stream
      )
    end

    Caffeine.Stream.construct(head, rest)
  end

  defp drain_chars(n, charlist_stream) do
    {Caffeine.Stream.take(charlist_stream, n), reduce_stream(n, charlist_stream)}
  end

  defp reduce_stream(0, reduced_stream) do
    reduced_stream
  end

  defp reduce_stream(i, stream) do
    reduce_stream(i - 1, Caffeine.Stream.tail(stream))
  end
end
