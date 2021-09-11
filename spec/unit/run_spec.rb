# frozen_string_literal: true

RSpec.describe Minehunter, "#run" do
  it "runs the game on a 9x9 grid with 10 mines" do
    pastel = double(:pastel, method: :custom_decorator)
    game = double(:game, run: nil)
    allow(Pastel).to receive(:new).and_return(pastel)
    allow(TTY::Screen).to receive(:width).and_return(40)
    allow(TTY::Screen).to receive(:height).and_return(20)
    allow(described_class::Game).to receive(:new).and_return(game)

    described_class.run

    expect(described_class::Game).to have_received(:new)
      .with(width: 9, height: 9, mines_limit: 10,
            screen_width: 40, screen_height: 20,
            decorator: :custom_decorator)
  end
end
