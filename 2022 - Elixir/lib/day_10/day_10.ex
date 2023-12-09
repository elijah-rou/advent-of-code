defmodule Assembly do
  def execute(register, pending_instr) do
    execs = Enum.reverse(pending_instr)

    case execs do
      [] -> {register, []}
      [nil | _] -> {register, execs |> tl |> Enum.reverse()}
      [val | _] -> {register + val, execs |> tl |> Enum.reverse()}
    end
  end

  def can_draw?(register, clock) do
    register == rem(clock - 1, 40) or
      register - 1 == rem(clock - 1, 40) or
      register + 1 == rem(clock - 1, 40)
  end

  def draw_pixel(register, clock) do
    br =
      cond do
        clock in [40, 80, 120, 160, 200, 240] -> "\n"
        true -> ""
      end

    cond do
      can_draw?(register, clock) -> "#"
      true -> "."
    end <> br
  end

  def read(instructions) do
    read(instructions, 1, 1, [], [], "")
  end

  defp read([], _, _, [], signal_strengths, crt_print) do
    {Enum.reverse(signal_strengths), crt_print}
  end

  defp read(["noop" | cmds], clock, register, pending_instr, signal_strengths, crt_print) do
    new_instr = [nil | pending_instr]
    {new_register, new_instr} = execute(register, new_instr)

    read(
      cmds,
      clock + 1,
      new_register,
      new_instr,
      [clock * register | signal_strengths],
      crt_print <> draw_pixel(register, clock)
    )
  end

  defp read(["addx " <> amt | cmds], clock, register, pending_instr, signal_strengths, crt_print) do
    new_instr = [String.to_integer(amt), nil | pending_instr]
    {new_register, new_instr} = execute(register, new_instr)

    read(
      cmds,
      clock + 1,
      new_register,
      new_instr,
      [clock * register | signal_strengths],
      crt_print <> draw_pixel(register, clock)
    )
  end

  defp read([], clock, register, pending_instr, signal_strengths, crt_print) do
    {new_register, new_instr} = execute(register, pending_instr)

    read(
      [],
      clock + 1,
      new_register,
      new_instr,
      [clock * register | signal_strengths],
      crt_print <> draw_pixel(register, clock)
    )
  end
end

defmodule Day10 do
  def tinker do
    {:ok, input_str} = File.read("lib/day_10/input")

    output =
      input_str
      |> String.split("\n", trim: true)
      |> Assembly.read()

    output
    |> elem(0)
    |> Enum.drop(19)
    |> Enum.take_every(40)
    |> Enum.take(6)
    |> Enum.sum()
    |> IO.inspect()

    output
    |> elem(1)
    |> IO.puts()
  end
end
