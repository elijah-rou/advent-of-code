defmodule Day6 do
  def find_marker(stream, buffer_len), do: find_marker(stream, buffer_len, buffer_len)

  defp find_marker(stream, buffer_len, idx) do
    marker =
      stream
      |> Enum.take(buffer_len)
      |> Enum.uniq()

    cond do
      length(marker) < buffer_len -> find_marker(tl(stream), buffer_len, idx + 1)
      true -> {idx, List.to_string(marker)}
    end
  end

  def descramble do
    {:ok, input_str} = File.read("lib/day_6/input")
    marker_start = find_marker(input_str |> String.to_charlist(), 4)
    marker_message = find_marker(input_str |> String.to_charlist(), 14)
    IO.inspect({marker_start, marker_message})
  end
end
