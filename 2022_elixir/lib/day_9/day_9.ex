defmodule Day9 do
  def jump(rope_jumps, knots) do
    positions = Tuple.duplicate({0, 0}, knots)
    jump(positions, rope_jumps, [], knots)
  end

  def jump(_, [], visited, _) do
    visited
  end

  def jump(positions, [[direction, steps] | rest], visited, knots) do
    {new_positions, visits} =
      move(positions, direction, String.to_integer(steps), [], knots, 0, {})

    jump(new_positions, rest, [visits | visited], knots)
  end

  def check_distance(new_pos, old_pos, tail_pos) do
    cond do
      # left
      elem(new_pos, 0) == elem(tail_pos, 0) - 2 -> old_pos
      # right
      elem(new_pos, 0) == elem(tail_pos, 0) + 2 -> old_pos
      # up
      elem(new_pos, 1) == elem(tail_pos, 1) - 2 -> old_pos
      # down
      elem(new_pos, 1) == elem(tail_pos, 1) + 2 -> old_pos
      true -> tail_pos
    end
  end

  def move(positions, _, 0, visits, _, _, _) do
    {positions, visits}
  end

  def move(positions, direction, steps, visits, knots, 0, _) do
    head_pos = elem(positions, 0)

    new_pos =
      case direction do
        "U" -> {elem(head_pos, 0), elem(head_pos, 1) + 1}
        "D" -> {elem(head_pos, 0), elem(head_pos, 1) - 1}
        "L" -> {elem(head_pos, 0) - 1, elem(head_pos, 1)}
        "R" -> {elem(head_pos, 0) + 1, elem(head_pos, 1)}
      end

    tail_pos = elem(positions, 1)
    new_tail_pos = check_distance(new_pos, head_pos, tail_pos)

    positions =
      positions
      |> put_elem(0, new_pos)
      |> put_elem(1, new_tail_pos)

    move(positions, direction, steps, visits, knots, 1, tail_pos)
  end

  def move(positions, direction, steps, visits, knots, idx, old_pos) do
    cond do
      idx == knots - 1 ->
        visits = [elem(positions, idx) | visits]
        move(positions, direction, steps - 1, visits, knots, 0, {})

      true ->
        head_pos = elem(positions, idx)
        tail_pos = elem(positions, idx + 1)

        new_tail_pos = check_distance(head_pos, old_pos, tail_pos)

        positions =
          positions
          |> put_elem(idx + 1, new_tail_pos)

        move(positions, direction, steps, visits, knots, idx + 1, tail_pos)
    end
  end

  def ropin do
    {:ok, input_str} = File.read("lib/day_9/input")

    rope_jumps =
      input_str
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, " "))

    jump(rope_jumps, 2)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
    |> IO.inspect()

    jump(rope_jumps, 10)
    |> Enum.reverse()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
    |> IO.inspect()
  end
end
