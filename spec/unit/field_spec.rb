# frozen_string_literal: true

RSpec.describe Minehunter::Field do
  it "is covered and has no flag or mine by default" do
    field = described_class.new

    expect(field.flag?).to eql(false)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(true)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq("░")
  end

  it "uncovers a field without a mine" do
    field = described_class.new

    field.uncover

    expect(field.flag?).to eq(false)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(false)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq(" ")
  end

  it "uncovers a field with a mine" do
    field = described_class.new

    field.mine!
    field.uncover

    expect(field.flag?).to eq(false)
    expect(field.mine?).to eq(true)
    expect(field.cover?).to eq(false)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq("*")
  end

  it "uncovers a field with a flag but no mine" do
    field = described_class.new

    field.flag
    field.uncover

    expect(field.flag?).to eq(true)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(false)
    expect(field.wrong?).to eq(false)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq(" ")
  end

  it "uncovers a field with a flag marked as wrongly placed" do
    field = described_class.new

    field.flag
    field.wrong
    field.uncover

    expect(field.flag?).to eq(true)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(false)
    expect(field.wrong?).to eq(true)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq("X")
  end

  it "uncovers a field with the number of surrounding mines" do
    field = described_class.new

    field.mine_count = 2
    field.uncover

    expect(field.flag?).to eq(false)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(false)
    expect(field.mine_count).to eq(2)
    expect(field.render).to eq("2")
  end

  it "uncovers a field with the number of mines in custom colour" do
    field = described_class.new
    pastel = Pastel.new(enabled: true)
    decorator = pastel.method(:decorate)

    field.mine_count = 2
    field.uncover

    expect(field.render(decorator: decorator)).to eq("\e[32m2\e[0m")
  end

  it "flags a field" do
    field = described_class.new

    field.flag

    expect(field.flag?).to eq(true)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(true)
    expect(field.wrong?).to eq(false)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq("F")
  end

  it "removes flag when already placed" do
    field = described_class.new

    field.flag
    field.flag

    expect(field.flag?).to eq(false)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(true)
    expect(field.wrong?).to eq(false)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq("░")
  end

  it "doesn't flag already uncoverd field" do
    field = described_class.new

    field.uncover
    field.flag

    expect(field.flag?).to eq(false)
    expect(field.mine?).to eq(false)
    expect(field.cover?).to eq(false)
    expect(field.wrong?).to eq(false)
    expect(field.mine_count).to eq(0)
    expect(field.render).to eq(" ")
  end
end
