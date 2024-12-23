defmodule MonkeyBusiness do
  def get_op(op_str) do
    op =
      op_str
      |> String.split(" ")

    amt = op |> tl |> hd
    %{:op => hd(op), :amt => amt}
  end

  def prep_items(items) do
    items
    |> String.split(", ", trim: true)
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
  end

  def prep_monkeys(monkey_list) do
    prep_monkeys(monkey_list, %{}, [])
  end

  defp prep_monkeys([], monkeys, monkey_order) do
    {monkeys, Enum.reverse(monkey_order)}
  end

  defp prep_monkeys(
         [
           "Monkey " <> monkey_name,
           "  Starting items: " <> starting_items,
           "  Operation: new = old " <> op,
           "  Test: divisible by " <> test_div,
           "    If true: throw to monkey " <> true_monkey,
           "    If false: throw to monkey " <> false_monkey
           | tail
         ],
         monkeys,
         monkey_order
       ) do
    name = String.to_atom(String.at(monkey_name, 0))
    {div_amt, _} = test_div |> Integer.parse()

    monkey = %{
      "items" => prep_items(starting_items),
      "op" => get_op(op),
      "test_div" => div_amt,
      "true_monkey" => true_monkey |> String.to_atom(),
      "false_monkey" => false_monkey |> String.to_atom()
    }

    prep_monkeys(tail, Map.update(monkeys, name, monkey, fn _ -> monkey end), [
      name | monkey_order
    ])
  end

  defp fling_items(monkey_name, monkeys, [current | next], part) do
    monkey = Map.get(monkeys, monkey_name)
    op = Map.get(monkey, "op")
    operation = Map.get(op, :op)
    divisible_product =
      monkeys
      |> Map.values
      |> Enum.map(&Map.get(&1, "test_div"))
      |> Enum.reduce(fn x, y -> x*y end)

    amt =
      case Map.get(op, :amt) do
        "old" -> current
        _ -> Integer.parse(Map.get(op, :amt)) |> elem(0)
      end

    new_amt =
      case operation do
        "*" -> current * amt
        _ -> current + amt
      end
    new_amt =
      case part do
        :part1 -> rem(div(new_amt, 3), divisible_product)
        _ -> rem(new_amt, divisible_product)
      end

    next_monkey_name =
      cond do
        rem(new_amt, Map.get(monkey, "test_div")) == 0 -> Map.get(monkey, "true_monkey")
        true -> Map.get(monkey, "false_monkey")
      end

    next_monkey =
      Map.get(monkeys, next_monkey_name)
      |> Map.update("items", [new_amt], fn old_items_rev ->
        old_items = old_items_rev |> Enum.reverse()
        new_items = [new_amt | old_items]
        Enum.reverse(new_items)
      end)

    angry_monkey =
      monkey
      |> Map.update("items", Map.get(monkey, "items"), fn old_items -> tl(old_items) end)

    new_monkeys =
      monkeys
      |> Map.put(monkey_name, angry_monkey)
      |> Map.put(next_monkey_name, next_monkey)

    fling_items(monkey_name, new_monkeys, next, part)
  end

  defp fling_items(_, monkeys, [], _) do
    monkeys
  end

  def shenanigans(monkeys, monkey_order, i, part) do
    shenanigans(monkeys, monkey_order, monkey_order, i - 1, Map.from_keys(monkey_order, 0), part)
  end

  defp shenanigans(monkeys, _, [], 0, acc, _) do
    {monkeys, acc}
  end

  defp shenanigans(monkeys, monkey_order, [], i, acc, part) do
    shenanigans(monkeys, monkey_order, monkey_order, i - 1, acc, part)
  end

  defp shenanigans(monkeys, monkey_order, [current_monkey | rest], i, acc, part) do
    monkey = Map.get(monkeys, current_monkey)
    items = Map.get(monkey, "items")
    new_monkeys = fling_items(current_monkey, monkeys, items, part)

    new_acc =
      Map.update(acc, current_monkey, length(items), fn old_acc -> old_acc + length(items) end)

    shenanigans(new_monkeys, monkey_order, rest, i, new_acc, part)
  end
end

defmodule Day11 do

  def monkey_business(inspections) do
    inspections
    |> Map.values()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.reduce(fn x, y -> x * y end)
    |> IO.inspect()
  end
  def monkey_around do
    {:ok, input_str} = File.read("lib/day_11/input")

    {monkeys, monkey_order} =
      input_str
      |> String.split("\n", trim: true)
      |> MonkeyBusiness.prep_monkeys()

    {_, inspections_1} = MonkeyBusiness.shenanigans(monkeys, monkey_order, 20, :part1)
    {_, inspections_2} = MonkeyBusiness.shenanigans(monkeys, monkey_order, 10000, :part2)

    {monkey_business(inspections_1), monkey_business(inspections_2)}
  end
end
