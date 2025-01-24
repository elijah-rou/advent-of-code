defmodule Stack do
  def new(), do: []

  def push(stack, element, true) do
    List.flatten([element | stack])
  end

  def push(stack, element, false) do
    List.flatten([Enum.reverse(element) | stack])
  end

  def pop([]) do
    {[], []}
  end

  def pop(stack) do
    {[hd(stack)], tl(stack)}
  end

  def pop([], n) do
    {List.duplicate(nil, n), []}
  end

  def pop(stack, n) do
    {
      Enum.take(stack, n),
      Enum.take(stack, n - length(stack))
    }
  end

  def peek([]) do
    " "
  end

  def peek(stack) do
    hd(stack)
  end

  def empty?([]), do: true
  def empty?(_), do: false
end

defmodule Day5 do
  def parse_config(crate_config) do
    levels = String.split(crate_config, "\n", trim: true)

    max_char =
      levels
      |> Enum.map(&String.length/1)
      |> Enum.max()

    crates =
      levels
      |> Enum.take(length(levels) - 1)
      |> Enum.map(&String.pad_trailing(&1, max_char))
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&tl/1)
      |> Enum.map(&Enum.take_every(&1, 4))
      |> Enum.zip_with(&Function.identity/1)

    List.to_tuple(
      crates
      |> Enum.map(fn seq -> Enum.drop_while(seq, &(&1 == 32)) end)
    )
  end

  def parse_step(step_str) do
    step_str
    |> String.split(" ", trim: true)
    |> tl
    |> Enum.take_every(2)
    |> Enum.map(&String.to_integer(&1))
  end

  def move_crates(stacks, [], _) do
    stacks
  end

  def move_crates(stacks, actions, rev_put) do
    [[amt, source, dest] | rest] = actions
    {moved_crates, new_stack_source} = Stack.pop(elem(stacks, source - 1), amt)
    new_stack_dest = Stack.push(elem(stacks, dest - 1), moved_crates, rev_put)

    new_stacks =
      stacks
      |> put_elem(source - 1, new_stack_source)
      |> put_elem(dest - 1, new_stack_dest)

    move_crates(new_stacks, rest, rev_put)
  end

  def rearrange_stacks do
    {:ok, input_str} = File.read("lib/day_5/input")
    [config, steps] = String.split(input_str, "\n\n", trim: true, parts: 2)

    stacks = parse_config(config)

    actions =
      steps
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_step/1)

    IO.inspect(stacks)

    new_stacks_9000 = move_crates(stacks, actions, false)
    new_stacks_9001 = move_crates(stacks, actions, true)

    IO.inspect(
      new_stacks_9000
      |> Tuple.to_list()
      |> Enum.map(&Stack.peek/1)
      |> List.to_string()
    )

    IO.inspect(
      new_stacks_9001
      |> Tuple.to_list()
      |> Enum.map(&Stack.peek/1)
      |> List.to_string()
    )
  end
end
