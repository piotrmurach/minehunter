# frozen_string_literal: true

RSpec.describe Minehunter::Game do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }
  let(:pastel) { Pastel.new(enabled: true) }
  let(:decorator) { pastel.method(:decorate) }
  let(:intro) {
    [
      "\e[3;7H┌─────────────────────────┐",
      "\e[4;7H│  ,-*                    \e[4;33H│",
      "\e[5;7H│ (_) Minehunter          \e[5;33H│",
      "\e[6;7H│                         \e[6;33H│",
      "\e[7;7H│ Movement:               \e[7;33H│",
      "\e[8;7H│      [↑]        [w]     \e[8;33H│",
      "\e[9;7H│   [←][↓][→]  [a][s][d]  \e[9;33H│",
      "\e[10;7H│                         \e[10;33H│",
      "\e[11;7H│ Actions:                \e[11;33H│",
      "\e[12;7H│   f - toggle flag       \e[12;33H│",
      "\e[13;7H│   space - uncover field \e[13;33H│",
      "\e[14;7H│   r - restart game      \e[14;33H│",
      "\e[15;7H│   q - quit game         \e[15;33H│",
      "\e[16;7H│                         \e[16;33H│",
      "\e[17;7H│ Press any key to start! \e[17;33H│",
      "\e[18;7H└─────────────────────────┘"
    ].join
  }

  it "quits game immediately with 'q' key" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "\n" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
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
    input << "\n" << "f" << ?\C-x
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42mF\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers a field with a space key and quits with ESC" do
    seed = [1, 1, 2, 3, 3, 4].to_enum
    randomiser = ->(_val) { seed.next }
    game = described_class.new(width: 10, height: 5, mines_limit: 3,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator, randomiser: randomiser)

    input << "\n" << " " << "\e"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 3    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 3    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░\e[36m1\e[0m        \e[9;27H│",
      "\e[10;14H│ ░░\e[36m1\e[0m        \e[10;27H│",
      "\e[11;14H│ ░░\e[32m2\e[0m\e[36m1\e[0m\e[42m \e[0m      \e[11;27H│",
      "\e[12;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m      \e[12;27H│",
      "\e[13;14H│ ░░░░\e[36m1\e[0m      \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers an entire grid with no mines and wins" do
    game = described_class.new(width: 10, height: 5, mines_limit: 0,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)

    input << "\n" << "\n" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 0    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ WINNER     \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│            \e[9;27H│",
      "\e[10;14H│            \e[10;27H│",
      "\e[11;14H│     \e[42m \e[0m      \e[11;27H│",
      "\e[12;14H│            \e[12;27H│",
      "\e[13;14H│            \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "uncovers a field with a mine and loses the game" do
    seed = [2, 2, 4, 0, 6, 2, 4, 4].to_enum
    randomiser = ->(_val) { seed.next }
    game = described_class.new(width: 10, height: 5, mines_limit: 4,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator, randomiser: randomiser)

    input << "\n" << " " << "l" << "l" << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 4    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 4    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░\e[36m1\e[0m\e[42m \e[0m\e[36m1\e[0m░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 4    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░\e[36m1\e[0m \e[42m\e[36m1\e[0m\e[0m░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 4    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░\e[36m1\e[0m \e[36m1\e[0m\e[42m░\e[0m░░░ \e[11;27H│",
      "\e[12;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ GAME OVER  \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░*░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[10;27H│",
      "\e[11;14H│ ░░*\e[36m1\e[0m \e[36m1\e[0m\e[41m*\e[0m░░░ \e[11;27H│",
      "\e[12;14H│ ░░░\e[32m2\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░*░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "is unable to uncover field with a flag" do
    game = described_class.new(width: 10, height: 5, mines_limit: 10,
                               screen_width: 40, screen_height: 20,
                               input: input, output: output, env: env,
                               decorator: decorator)
    input << "\n" << "g" << " " << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42mF\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42mF\e[0m░░░░░ \e[11;27H│",
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
        input << "\n" << input_sequence << "q"
        input.rewind

        game.run

        expect(output.string.inspect).to eq([
          "\e[?25l\e[2J#{intro}",
          "\e[2J\e[1;1H\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░░░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░\e[42m░\e[0m░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░░\e[42m░\e[0m░░░░ \e[11;27H│",
          "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
          "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
          "\e[14;14H└────────────┘",
          "\e[1;1H",

          "\e[2K\e[1G",
          "\e[6;14H┌────────────┐",
          "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
          "\e[8;14H├────────────┤",
          "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
          "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
          "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
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

    input << "\n" << "f" << "r" << "q"
    input.rewind

    game.run

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J#{intro}",
      "\e[2J\e[1;1H\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 9    \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42mF\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[1;1H",

      "\e[2K\e[1G",
      "\e[6;14H┌────────────┐",
      "\e[7;14H│ Flags 10   \e[7;27H│\e[3;1H",
      "\e[8;14H├────────────┤",
      "\e[9;14H│ ░░░░░░░░░░ \e[9;27H│",
      "\e[10;14H│ ░░░░░░░░░░ \e[10;27H│",
      "\e[11;14H│ ░░░░\e[42m░\e[0m░░░░░ \e[11;27H│",
      "\e[12;14H│ ░░░░░░░░░░ \e[12;27H│",
      "\e[13;14H│ ░░░░░░░░░░ \e[13;27H│",
      "\e[14;14H└────────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end
end
