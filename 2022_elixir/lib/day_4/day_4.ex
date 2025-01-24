defmodule Day4 do
  def spaceship(x, y) do
    cond do
      x == y -> :eq
      x > y -> :gt
      x < y -> :lt
    end
  end

  def get_limits(range_1, range_2) do
    {
      String.split(range_1, "-", trim: true)
      |> Enum.map(&String.to_integer(&1)),
      String.split(range_2, "-", trim: true)
      |> Enum.map(&String.to_integer(&1))
    }
  end

  def range_subsumed([range_1, range_2]) do
    {[start_1, end_1], [start_2, end_2]} = get_limits(range_1, range_2)

    case {spaceship(start_1, start_2), spaceship(end_1, end_2)} do
      {:lt, :lt} -> 0
      {:gt, :gt} -> 0
      _ -> 1
    end
  end

  def range_overlap([range_1, range_2]) do
    {[start_1, end_1], [start_2, end_2]} = get_limits(range_1, range_2)

    case {spaceship(end_1, start_2), spaceship(end_2, start_1)} do
      {:gt, :lt} -> 0
      {:lt, :gt} -> 0
      _ -> 1
    end
  end

  def common_ranges do
    {:ok, input_str} = File.read("lib/day_4/input")

    ranges =
      String.split(input_str, "\n", trim: true)
      |> Enum.map(&String.split(&1, ",", trim: true))

    subsumed =
      ranges
      |> Enum.map(&range_subsumed(&1))
      |> Enum.sum()

    overlapped =
      ranges
      |> Enum.map(&range_overlap(&1))
      |> Enum.sum()

    IO.inspect({subsumed, overlapped})
  end
end
