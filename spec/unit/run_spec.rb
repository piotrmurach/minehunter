# frozen_string_literal: true

RSpec.describe Minehunter, "#run" do
  it "runs the game on a 9x9 grid with 10 mines" do
    pastel = double(:pastel, method: :custom_decorator)
    game = double(:game, run: nil)
    allow(Pastel).to receive(:new).and_return(pastel)
    allow(described_class::Game).to receive(:new).and_return(game)

    described_class.run

    expect(described_class::Game).to have_received(:new)
      .with(width: 9, height: 9, mines_limit: 10, decorator: :custom_decorator)
  end
end
