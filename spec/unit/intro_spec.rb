# frozen_string_literal: true

RSpec.describe Minehunter::Intro do
  it "renders intro screen content" do
    expect(described_class.render).to eq([
       "     ,-*",
       "    (_) Minehunter",
       "",
       "Movement",
       "     [↑]        [w]",
       "  [←][↓][→]  [a][s][d]",
       "",
       "Actions",
       "  Toggle Flag  f",
       "  Uncover      space",
       "  Restart      r",
       "  Quit         q",
       "",
       "Press any key to start!"
    ].join("\n"))
  end

  it "calculates maximum intro screen content width" do
    expect(described_class.width).to eq("Press any key to start!".size)
  end

  it "calculates intro screen content height" do
    expect(described_class.height).to eq(14)
  end
end
