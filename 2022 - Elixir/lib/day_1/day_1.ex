defmodule Day1 do
  def calculate_macros do
    {:ok, input_str} = File.read("lib/day_1/input")

    elf_snax =
      input_str
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))
      |> Enum.map(fn list -> Enum.map(list, &String.to_integer(&1)) end)

    calorie_totals = Enum.map(elf_snax, &Enum.sum(&1))
    max = Enum.max(calorie_totals)
    argmax = Enum.find_index(calorie_totals, &(&1 == max))
    IO.inspect({max, argmax})
    calorie_totals
  end

  def max_n(itr, n) do
    itr
    |> Enum.sort()
    |> Enum.take(-n)
  end

  def calculate_top_3 do
    top_3 =
      calculate_macros()
      |> max_n(3)
      |> Enum.sum()

    IO.inspect(top_3)
  end
end
