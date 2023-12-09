defmodule Directory do
  def add_total(fs, [], amount) do
    fs
    |> get_and_update_in([:total], &{&1, &1 + amount})
    |> elem(1)
  end

  def add_total(fs, current_path, amount) do
    [_ | base_path] = current_path

    fs
    |> get_and_update_in(Enum.reverse([:total | current_path]), &{&1, &1 + amount})
    |> elem(1)
    |> add_total(base_path, amount)
  end

  def add_map(map, [], amount) do
    Map.update(map, "/", amount, fn val -> val + amount end)
  end

  def add_map(map, keys, amount) do
    [_ | rest] = keys

    map
    |> Map.update(create_path_str(keys), amount, fn val -> val + amount end)
    |> add_map(rest, amount)
  end

  def create_path_str(path) do
    path
    |> Enum.reverse()
    |> Enum.reduce(fn a, b -> a <> "/" <> b end)
  end

  def create(), do: %{:total => 0}
  def create([]), do: %{:total => 0}
  def create(cmds), do: create(%{:total => 0}, [], cmds, %{})

  defp create(fs, _, [], map) do
    {fs, map}
  end

  defp create(_, _, ["$ cd /" | cmds], _) do
    create(cmds)
  end

  defp create(fs, [_ | base_path], ["$ cd .." | cmds], map) do
    create(fs, base_path, cmds, map)
  end

  defp create(fs, current_path, ["$ cd " <> dir | cmds], map) do
    create(fs, [dir | current_path], cmds, map)
  end

  defp create(fs, current_path, ["$ ls" | cmds], map) do
    create(fs, current_path, cmds, map)
  end

  defp create(fs, current_path, ["dir " <> folder | cmds], map) do
    new_map =
      map
      |> Map.put(create_path_str([folder | current_path]), 0)

    fs
    |> get_and_update_in(Enum.reverse([folder | current_path]), &{&1, %{:total => 0}})
    |> elem(1)
    |> create(current_path, cmds, new_map)
  end

  defp create(fs, current_path, [item | cmds], map) do
    [size, _] = String.split(item, " ", trim: true)
    size = String.to_integer(size)
    new_map = add_map(map, current_path, size)

    add_total(fs, current_path, size)
    |> create(current_path, cmds, new_map)
  end
end

defmodule Day7 do
  def used_disk do
    {:ok, input_str} = File.read("lib/day_7/input")

    {_, fs_map} =
      input_str
      |> String.split("\n", trim: true)
      |> Directory.create()

    IO.inspect(
      fs_map
      |> Map.filter(fn {_, val} -> val <= 100_000 end)
      |> Map.values()
      |> Enum.sum()
    )

    IO.inspect(
      fs_map
      |> Map.filter(fn {_, val} -> 70_000_000 - (Map.get(fs_map, "/") - val) >= 30_000_000 end)
      |> Map.values()
      |> Enum.min()
    )
  end
end
