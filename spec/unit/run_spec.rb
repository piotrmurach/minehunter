# frozen_string_literal: true

RSpec.describe Minehunter, "#run" do
  it "runs the game by invoking the command line interface" do
    cli = double(:cli, run: nil)
    allow(described_class::CLI).to receive(:new).and_return(cli)

    described_class.run

    expect(cli).to have_received(:run)
  end
end
