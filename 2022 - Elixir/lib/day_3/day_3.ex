defmodule Day3 do
  def find_common_item(str) do
    string_half = div(String.length(str), 2)

    first =
      String.slice(str, 0, string_half)
      |> String.to_charlist()
      |> MapSet.new()

    second =
      String.slice(str, string_half, String.length(str))
      |> String.to_charlist()
      |> MapSet.new()

    MapSet.intersection(first, second) |> MapSet.to_list()
  end

  def find_common_badge(str_list) do
    str_list
    |> Enum.map(&String.to_charlist(&1))
    |> Enum.map(&MapSet.new(&1))
    |> Enum.reduce(&MapSet.intersection(&1, &2))
    |> MapSet.to_list()
  end

  def calc_prios do
    {:ok, input_str} = File.read("lib/day_3/input")

    # Create ASCII to priority maps
    # 1-26
    lowercase_priorities = Enum.into(97..122, %{}, &{&1, &1 - 96})
    # 27-52
    uppercase_priorities = Enum.into(65..90, %{}, &{&1, &1 - 38})
    priorities = Map.merge(lowercase_priorities, uppercase_priorities)

    common_item_prio =
      Enum.concat(
        String.split(input_str, "\n", trim: true)
        |> Enum.map(&find_common_item(&1))
      )
      |> Enum.map(&priorities[&1])
      |> Enum.sum()

    common_badge_prio =
      Enum.concat(
        String.split(input_str, "\n", trim: true)
        |> Enum.chunk_every(3)
        |> Enum.map(&find_common_badge(&1))
      )
      |> Enum.map(&priorities[&1])
      |> Enum.sum()

    IO.inspect({common_item_prio, common_badge_prio})
  end
end
