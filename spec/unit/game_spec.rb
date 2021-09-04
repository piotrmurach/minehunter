# frozen_string_literal: true

RSpec.describe Minehunter::Game do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }
  let(:pastel) { Pastel.new(enabled: true) }
  let(:decorator) { pastel.method(:decorate) }

  it "quits game immediately with 'q' key" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 10   │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "places a flag with 'f' key and quits with Ctrl+X" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "f" << ?\C-x
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 10   │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 9    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42mF\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers a field with a space key and quits" do
    seed = [2, 2, 3, 3, 4, 4].to_enum
    randomiser = ->(_val) { seed.next }
    game = described_class.new(width: 10, height: 5, mines_limit: 3,
                               input: input, output: output, env: env,
                               decorator: decorator, randomiser: randomiser)

    input << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 3    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 3    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m \e[0m          │\n",
      "│  \e[36m1\e[0m\e[36m1\e[0m\e[36m1\e[0m       │\n",
      "│  \e[36m1\e[0m░\e[32m2\e[0m\e[36m1\e[0m      │\n",
      "│  \e[36m1\e[0m\e[32m2\e[0m░\e[32m2\e[0m\e[36m1\e[0m     │\n",
      "│   \e[36m1\e[0m░░\e[36m1\e[0m     │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers an entire grid with no mines and wins" do
    game = described_class.new(width: 10, height: 5, mines_limit: 0,
                               input: input, output: output, env: env,
                               decorator: decorator)

    input << "\n" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 0    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ WINNER     │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m \e[0m          │\n",
      "│            │\n",
      "│            │\n",
      "│            │\n",
      "│            │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers a field with a mine and loses the game" do
    seed = [1, 0].to_enum
    randomiser = ->(_val) { seed.next }
    game = described_class.new(width: 10, height: 5, mines_limit: 1,
                               input: input, output: output, env: env,
                               decorator: decorator, randomiser: randomiser)

    input << " " << "l" << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 1    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 1    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m\e[36m1\e[0m\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 1    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[36m1\e[0m\e[42m░\e[0m░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ GAME OVER  │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[36m1\e[0m\e[41m*\e[0m░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "is unable to uncover field with a flag" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "g" << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 10   │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 9    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42mF\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 9    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42mF\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  context "when navigating around a grid" do
    {
      "arrow" => "\e[B\e[C\e[A\e[D",
      "'hjkl'" => "jlkh",
      "'wasd'" => "sdwa"
    }.each do |name, input_sequence|
      it "navigates around a grid with #{name} keys and quits" do
        game = described_class.new(width: 10, height: 5, mines_limit: 10,
                                   input: input, output: output, env: env,
                                   decorator: decorator)
        input << input_sequence << "q"
        input.rewind

        game.run

        expect(output.string.inspect).to eq([
          "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
          "┌────────────┐\n",
          "│ Flags 10   │\n\e[3;1H",
          "├────────────┤\n",
          "│ \e[42m░\e[0m░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "└────────────┘\n",
          "\e[1;1H",

          "\e[2K\e[1G",
          "┌────────────┐\n",
          "│ Flags 10   │\n\e[3;1H",
          "├────────────┤\n",
          "│ ░░░░░░░░░░ │\n",
          "│ \e[42m░\e[0m░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "└────────────┘\n",
          "\e[1;1H",

          "\e[2K\e[1G",
          "┌────────────┐\n",
          "│ Flags 10   │\n\e[3;1H",
          "├────────────┤\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░\e[42m░\e[0m░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "└────────────┘\n",
          "\e[1;1H",

          "\e[2K\e[1G",
          "┌────────────┐\n",
          "│ Flags 10   │\n\e[3;1H",
          "├────────────┤\n",
          "│ ░\e[42m░\e[0m░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "└────────────┘\n",
          "\e[1;1H",

          "\e[2K\e[1G",
          "┌────────────┐\n",
          "│ Flags 10   │\n\e[3;1H",
          "├────────────┤\n",
          "│ \e[42m░\e[0m░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "│ ░░░░░░░░░░ │\n",
          "└────────────┘\n",
          "\e[2J\e[1;1H\e[?25h"
        ].join.inspect)
      end
    end
  end

  it "resets the game with 'r' key" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               input: input, output: output, env: env,
                               decorator: decorator)

    input << "f" << "r" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 10   │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 9    │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42mF\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[1;1H",

      "\e[2K\e[1G",
      "┌────────────┐\n",
      "│ Flags 10   │\n\e[3;1H",
      "├────────────┤\n",
      "│ \e[42m░\e[0m░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "│ ░░░░░░░░░░ │\n",
      "└────────────┘\n",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end
end
