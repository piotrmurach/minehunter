# frozen_string_literal: true

RSpec.describe Minehunter::CLI do
  let(:output) { StringIO.new("".dup, "w+") }
  let(:input) { StringIO.new("".dup, "w+") }
  let(:env) { {"TTY_TEST" => true} }

  it "prints a game on a 7x4 grid with 5 mines and quits" do
    cli = described_class.new
    input << "q"
    input.rewind

    cli.run(%w[-c 7 -r 4 -m 5], input: input, output: output, color: true,
                                env: env, screen_width: 40, screen_height: 20)

    expect(output.string.inspect).to eq([
      "\e[?25l\e[2J\e[1;1H\e[2K\e[1G",
      "\e[7;15H┌─────────┐",
      "\e[8;15H│ Flags 5 \e[8;25H│\e[3;1H",
      "\e[9;15H├─────────┤",
      "\e[10;15H│ \e[42m░\e[0m░░░░░░ \e[10;25H│",
      "\e[11;15H│ ░░░░░░░ \e[11;25H│",
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
