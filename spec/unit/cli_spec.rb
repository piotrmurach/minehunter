# frozen_string_literal: true

RSpec.describe Minehunter::CLI do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }

  it "prints a game on a 7x4 grid with 5 mines and quits" do
    cli = described_class.new
    input << "\n" << "q"
    input.rewind

    cli.run(%w[-c 7 -r 4 -m 5], input: input, output: output, color: true,
                                env: env, screen_width: 40, screen_height: 20)

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J",
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
      "\e[18;7H└─────────────────────────┘",
      "\e[2J",
      "\e[7;15H┌─────────┐",
      "\e[8;15H│ Flags 5 \e[8;25H│",
      "\e[9;15H├─────────┤",
      "\e[10;15H│ ░░░░░░░ \e[10;25H│",
      "\e[11;15H│ ░░░\e[42m░\e[0m░░░ \e[11;25H│",
      "\e[12;15H│ ░░░░░░░ \e[12;25H│",
      "\e[13;15H│ ░░░░░░░ \e[13;25H│",
      "\e[14;15H└─────────┘",
      "\e[2J\e[1;1H\e[?25h"
    ].join.inspect)
  end

  it "prints help information and exits" do
    cli = described_class.new

    expect {
      cli.run(%w[--help], input: input, output: output, screen_width: 40,
                          screen_height: 20)
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(0) }

    expect(output.string).to eq([
      "Usage: rspec [OPTIONS]",
      "",
      "Hunt down all the mines and uncover remaining fields",
      "",
      "Options:",
      "  -c, --cols INT    Set number of columns",
      "  -h, --help        Print usage",
      "  -l, --level NAME  Set difficulty level (permitted: easy,medium,hard)",
      "                    (default \"medium\")",
      "  -m, --mines INT   Set number of mines",
      "  -r, --rows INT    Set number of rows",
      "  -v, --version     Print version",
      "",
      "Examples:",
      "  To play the game on a 20x15 grid with 35 mines run",
      "",
      "  $ rspec -c 20 -r 15 -m 35\n"
    ].join("\n"))
  end

  it "prints version and exits" do
    cli = described_class.new

    expect {
      cli.run(%w[--version], input: input, output: output)
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(0) }

    expect(output.string).to eq("#{Minehunter::VERSION}\n")
  end

  it "prints errors when grid rows and columns aren't integers" do
    cli = described_class.new

    expect {
      cli.run(%w[--cols=a --rows=b], input: input, output: output)
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(output.string).to eq([
     "Errors:\n",
     "  1) Cannot convert value of `a` into 'int' type for '--cols' option\n",
     "  2) Cannot convert value of `b` into 'int' type for '--rows' option\n"
    ].join)
  end

  it "prints an error when the number of mines exceeds grid size and exits" do
    cli = described_class.new

    expect {
      cli.run(%w[-c 5 -r 5 -m 50], input: input, output: output)
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(output.string).to eq("Error: cannot have more mines than " \
                                "available fields\n")
  end

  it "prints an error for unknown difficulty level and exits" do
    cli = described_class.new

    expect {
      cli.run(%w[--level=unknown], input: input, output: output)
    }.to raise_error(SystemExit) { |err| expect(err.status).to eq(1) }

    expect(output.string).to eq("Error: unpermitted value `unknown` " \
                                "for '--level' option: choose from easy,\n "\
                                "      medium, hard\n")
  end
end
