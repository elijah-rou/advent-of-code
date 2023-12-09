defmodule Day2 do
  def strategy_1([opponent_move, my_move]) do
    move = %{
      "A" => :rock,
      "B" => :paper,
      "C" => :scissors,
      "X" => :rock,
      "Y" => :paper,
      "Z" => :scissors
    }

    {move[opponent_move], move[my_move]}
  end

  def strategy_2([opponent_move, game_outcome]) do
    state = %{
      "X" => :lose,
      "Y" => :draw,
      "Z" => :win
    }

    move = %{
      "A" => :rock,
      "B" => :paper,
      "C" => :scissors
    }

    case {move[opponent_move], state[game_outcome]} do
      {:rock, :lose} -> {:rock, :scissors}
      {:rock, :draw} -> {:rock, :rock}
      {:rock, :win} -> {:rock, :paper}
      {:paper, :lose} -> {:paper, :rock}
      {:paper, :draw} -> {:paper, :paper}
      {:paper, :win} -> {:paper, :scissors}
      {:scissors, :lose} -> {:scissors, :paper}
      {:scissors, :draw} -> {:scissors, :scissors}
      {:scissors, :win} -> {:scissors, :rock}
    end
  end

  def play_game({move_1, move_2}) do
    case {move_1, move_2} do
      {:rock, :rock} -> 4
      {:rock, :paper} -> 8
      {:rock, :scissors} -> 3
      {:paper, :rock} -> 1
      {:paper, :paper} -> 5
      {:paper, :scissors} -> 9
      {:scissors, :rock} -> 7
      {:scissors, :paper} -> 2
      {:scissors, :scissors} -> 6
    end
  end

  def follow_strat do
    {:ok, input_str} = File.read("lib/day_2/input")

    games =
      String.split(input_str, "\n", trim: true)
      |> Enum.map(&String.split(&1, " ", trim: true))

    strat_1 =
      games
      |> Enum.map(&strategy_1/1)
      |> Enum.map(&play_game/1)
      |> Enum.sum()

    strat_2 =
      games
      |> Enum.map(&strategy_2/1)
      |> Enum.map(&play_game/1)
      |> Enum.sum()

    IO.inspect({strat_1, strat_2})
  end
end
