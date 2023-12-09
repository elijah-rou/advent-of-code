defmodule Day8 do
  def line_to_ints(line) do
    line
    |> String.to_charlist()
    |> Enum.map(&(&1 - 48))
  end

  def visible?(tree_map, tree_height, row, col, num_rows, num_cols, greedy_direction) do
    visible =
      case greedy_direction do
        nil -> true
        _ -> tree_height > tree_map |> elem(row) |> elem(col)
      end

    cond do
      row == 0 or col == 0 or row + 1 == num_rows or col + 1 == num_cols ->
        visible

      !visible ->
        false

      true ->
        case greedy_direction do
          :north ->
            visible?(tree_map, tree_height, row - 1, col, num_rows, num_cols, :north)

          :south ->
            visible?(tree_map, tree_height, row + 1, col, num_rows, num_cols, :south)

          :east ->
            visible?(tree_map, tree_height, row, col - 1, num_rows, num_cols, :east)

          :west ->
            visible?(tree_map, tree_height, row, col + 1, num_rows, num_cols, :west)

          nil ->
            visible?(tree_map, tree_height, row - 1, col, num_rows, num_cols, :north) or
              visible?(tree_map, tree_height, row + 1, col, num_rows, num_cols, :south) or
              visible?(tree_map, tree_height, row, col - 1, num_rows, num_cols, :east) or
              visible?(tree_map, tree_height, row, col + 1, num_rows, num_cols, :west)
        end
    end
  end

  def score(tree_map, tree_height, row, col, num_rows, num_cols, greedy_direction, current) do
    visible =
      case greedy_direction do
        nil -> true
        _ -> tree_height > tree_map |> elem(row) |> elem(col)
      end

    cond do
      row == 0 or col == 0 or row + 1 == num_rows or col + 1 == num_cols ->
        current

      !visible ->
        current

      true ->
        case greedy_direction do
          :north ->
            score(tree_map, tree_height, row - 1, col, num_rows, num_cols, :north, current + 1)

          :south ->
            score(tree_map, tree_height, row + 1, col, num_rows, num_cols, :south, current + 1)

          :east ->
            score(tree_map, tree_height, row, col - 1, num_rows, num_cols, :east, current + 1)

          :west ->
            score(tree_map, tree_height, row, col + 1, num_rows, num_cols, :west, current + 1)

          nil ->
            score(tree_map, tree_height, row - 1, col, num_rows, num_cols, :north, current + 1) *
              score(tree_map, tree_height, row + 1, col, num_rows, num_cols, :south, current + 1) *
              score(tree_map, tree_height, row, col - 1, num_rows, num_cols, :east, current + 1) *
              score(tree_map, tree_height, row, col + 1, num_rows, num_cols, :west, current + 1)
        end
    end
  end

  def get_visible(tree_map, num_rows, num_cols) do
    for {trees, row} <- tree_map |> Tuple.to_list() |> Enum.with_index() do
      for {tree_height, col} <- trees |> Tuple.to_list() |> Enum.with_index() do
        visible?(tree_map, tree_height, row, col, num_rows, num_cols, nil)
      end
    end
  end

  def get_sight_score(tree_map, num_rows, num_cols) do
    for {trees, row} <- tree_map |> Tuple.to_list() |> Enum.with_index() do
      for {tree_height, col} <- trees |> Tuple.to_list() |> Enum.with_index() do
        score(tree_map, tree_height, row, col, num_rows, num_cols, nil, 0)
      end
    end
  end

  def grid_to_map(grid) do
    grid
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  def quadcopter do
    {:ok, input_str} = File.read("lib/day_8/input")

    viz_grid =
      input_str
      |> String.split("\n", trim: true)
      |> Enum.map(&line_to_ints(&1))

    {num_rows, num_cols} = {length(viz_grid), length(List.first(viz_grid))}

    tree_grid =
      viz_grid
      |> grid_to_map

    tree_grid
    |> get_visible(num_rows, num_cols)
    |> List.flatten()
    |> Enum.count(fn viz? -> viz? == true end)
    |> IO.inspect()

    tree_grid
    |> get_sight_score(num_rows, num_cols)
    |> List.flatten()
    |> Enum.max()
    |> IO.inspect()
  end
end
