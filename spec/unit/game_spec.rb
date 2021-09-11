# frozen_string_literal: true

RSpec.describe Minehunter::Game do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }
  let(:pastel) { Pastel.new(enabled: true) }
  let(:decorator) { pastel.method(:decorate) }

  it "quits game immediately with 'q' key" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "places a flag with 'f' key and quits with Ctrl+X" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "f" << ?\C-x
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42mF\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers a field with a space key and quits" do
    seed = [2, 2, 3, 3, 4, 4].to_enum
    randomiser = ->(_val) { seed.next }
    game = described_class.new(width: 10, height: 5, mines_limit: 3,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator, randomiser: randomiser)

    input << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 3    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 3    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m \e[0m          \e[9;27H│",
      "\e[10;14H│  \e[36m1\e[0m\e[36m1\e[0m\e[36m1\e[0m       \e[10;27H│",
      "\e[11;14H│  \e[36m1\e[0m░\e[32m2\e[0m\e[36m1\e[0m      \e[11;27H│",
      "\e[12;14H│  \e[36m1\e[0m\e[32m2\e[0m░\e[32m2\e[0m\e[36m1\e[0m     ",
      "\e[12;27H│",
      "\e[13;14H│   \e[36m1\e[0m░░\e[36m1\e[0m     \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers an entire grid with no mines and wins" do
    game = described_class.new(width: 10, height: 5, mines_limit: 0,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)

    input << "\n" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 0    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ WINNER     \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m \e[0m          \e[9;27H│",
      "\e[10;14H│            \e[10;27H│",
      "\e[11;14H│            \e[11;27H│",
      "\e[12;14H│            \e[12;27H│",
      "\e[13;14H│            \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers a field with a mine and loses the game" do
    seed = [1, 0].to_enum
    randomiser = ->(_val) { seed.next }
    game = described_class.new(width: 10, height: 5, mines_limit: 1,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator, randomiser: randomiser)

    input << " " << "l" << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 1    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 1    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m\e[36m1\e[0m\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 1    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[36m1\e[0m\e[42m░\e[0m░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ GAME OVER  \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[36m1\e[0m\e[41m*\e[0m░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "is unable to uncover field with a flag" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "g" << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42mF\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42mF\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
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
                                   screen_width: 40, screen_height: 20,
                                   input: input, output: output, env: env,
                                   decorator: decorator)
        input << input_sequence << "q"
        input.rewind

        game.run

        expect(output.string.inspect).to eq([
          "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ \e[42m░\e[0m░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░\e[42m░\e[0m░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░\e[42m░\e[0m░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[2J\e[1;1H\e[?25h"
        ].join.inspect)
      end
    end
  end

  it "resets the game with 'r' key" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)

    input << "f" << "r" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42mF\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ \e[42m░\e[0m░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end
end
