# frozen_string_literal: true

RSpec.describe Minehunter::Grid do
  context "#reset" do
    it "resets all fields back to default" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 4)

      grid.mine(1, 1)
      grid.mine(2, 2)
      grid.flag(3, 3)

      expect(grid.mines.size).to eq(2)
      expect(grid.flags_remaining).to eq(3)
      expect(grid.field_at(1, 1).mine?).to eq(true)
      expect(grid.flag?(3, 3)).to eq(true)

      grid.reset

      expect(grid.mines.size).to eq(0)
      expect(grid.flags_remaining).to eq(4)
      expect(grid.field_at(1, 1).mine?).to eq(false)
      expect(grid.flag?(3, 3)).to eq(false)
    end
  end

  context "#move_up" do
    it "moves up inside grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_up(2)).to eq(1)
    end

    it "moves up from the top to the bottom of grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_up(0)).to eq(4)
    end
  end

  context "#move_down" do
    it "moves down inside grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_down(1)).to eq(2)
    end

    it "moves down from the bottom to the top of grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_down(4)).to eq(0)
    end
  end

  context "#move_left" do
    it "moves left inside grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_left(2)).to eq(1)
    end

    it "moves left from left side to right side of grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_left(0)).to eq(9)
    end
  end

  context "#move_right" do
    it "moves right inside grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_right(1)).to eq(2)
    end

    it "moves right from right side to left side of grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      expect(grid.move_right(9)).to eq(0)
    end
  end

  context "#fill_with_mines" do
    it "fills grid with required amount of mines" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 6)
      expect(grid.mines.size).to eq(0)

      grid.fill_with_mines(0, 0)

      expect(grid.mines.size).to eq(6)
      expect(grid.field_at(0, 0).mine?).to eq(false)
    end

    it "fills the last grid column and row with mines" do
      grid = described_class.new(width: 3, height: 3, mines_limit: 8)
      expect(grid.mines.size).to eq(0)

      grid.fill_with_mines(0, 0)

      expect(grid.mines.size).to eq(8)
    end

    it "uses custom random number generator" do
      grid = described_class.new(width: 10, height: 10, mines_limit: 3)
      seed = [1, 1, 2, 2, 3, 3].to_enum
      randomiser = ->(_) { seed.next }

      grid.fill_with_mines(0, 0, randomiser: randomiser)

      expect(grid.mines).to eq([grid.field_at(1, 1),
                                grid.field_at(2, 2),
                                grid.field_at(3, 3)])
    end

    it "doesn't place more mines than available fields" do
      expect {
        described_class.new(width: 10, height: 5, mines_limit: 51)
      }.to raise_error(Minehunter::Error,
                       "cannot have more mines than available fields")
    end
  end

  context "#fields_next_to" do
    it "iterates over nearby fields when at the top left corner position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(0,0)|(1,0)|
      # |(0,1)|(1,1)|
      nearby_fields = [[0, 1], [1, 0], [1, 1]]

      expect { |b|
        grid.fields_next_to(0, 0, &b)
      }.to yield_successive_args(*nearby_fields)
      expect(grid.fields_next_to(0, 0).to_a).to eq(nearby_fields)
    end

    it "iterates over nearby fields when at the top right corner position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(8,0)|(9,0)|
      # |(8,1)|(9,1)|
      nearby_fields = [[8, 0], [8, 1], [9, 1]]

      expect { |b|
        grid.fields_next_to(9, 0, &b)
      }.to yield_successive_args(*nearby_fields)
      expect(grid.fields_next_to(9, 0).to_a).to eq(nearby_fields)
    end

    it "iterates over nearby fields when at the bottom right corner position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(8,3)|(9,3)|
      # |(8,4)|(9,4)|
      nearby_fields = [[8, 3], [8, 4], [9, 3]]

      expect { |b|
        grid.fields_next_to(9, 4, &b)
      }.to yield_successive_args(*nearby_fields)
      expect(grid.fields_next_to(9, 4).to_a).to eq(nearby_fields)
    end

    it "iterates over nearby fields when at the bottom left corner position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(0,3)|(1,3)|
      # |(0,4)|(1,4)|
      nearby_fields = [[0, 3], [1, 3], [1, 4]]

      expect { |b|
        grid.fields_next_to(0, 4, &b)
      }.to yield_successive_args(*nearby_fields)
      expect(grid.fields_next_to(0, 4).to_a).to eq(nearby_fields)
    end

    it "iterates over nearby fields when at the center position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(3,1)|(4,1)|(5,1)|
      # |(3,2)|(4,2)|(5,2)|
      # |(3,3)|(4,3)|(5,3)|
      nearby_fields = [[3, 1], [3, 2], [3, 3], [4, 1],
                       [4, 3], [5, 1], [5, 2], [5, 3]]

      expect { |b|
        grid.fields_next_to(4, 2, &b)
      }.to yield_successive_args(*nearby_fields)
      expect(grid.fields_next_to(4, 2).to_a).to eq(nearby_fields)
    end
  end

  context "#count_mines_next_to" do
    it "counts no mines in nearby fields" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)

      expect(grid.count_mines_next_to(2, 2)).to eq(0)
    end

    it "counts three mines in nearby fields" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(8,3)|(9,3)|
      # |(8,4)|(9,4)|
      grid.mine(8, 3)
      grid.mine(9, 3)
      grid.mine(8, 4)

      expect(grid.count_mines_next_to(9, 4)).to eq(3)
    end

    it "counts maximum number of mines in nearby fields" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 10)
      # |(1,1)|(2,1)|(3,1)|
      # |(1,2)|(2,2)|(3,2)|
      # |(1,3)|(2,3)|(3,3)|
      grid.mine(1, 1)
      grid.mine(2, 1)
      grid.mine(3, 1)
      grid.mine(3, 2)
      grid.mine(3, 3)
      grid.mine(2, 3)
      grid.mine(1, 3)
      grid.mine(1, 2)

      expect(grid.count_mines_next_to(2, 2)).to eq(8)
    end
  end

  context "#uncover" do
    it "uncovers an empty field with three nearby mines" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 10)
      # |(1,1)|(2,1)|(3,1)|
      # |(1,2)|(2,2)|(3,2)|
      # |(1,3)|(2,3)|(3,3)|
      grid.mine(1, 1)
      grid.mine(3, 1)
      grid.mine(3, 3)

      expect(grid.uncover(2, 2)).to eq(false)
      expect(grid.field_at(2, 2).mine_count).to eq(3)
      expect(grid.unmined_fields_remaining).to eq(39)
      expect(grid.cleared?).to eq(false)
      expect(grid.render(2, 2)).to eq([
        "░░░░░░░░░░\n",
        "░░░░░░░░░░\n",
        "░░3░░░░░░░\n",
        "░░░░░░░░░░\n",
        "░░░░░░░░░░\n"
      ].join)
    end

    it "uncovers an empty field and all nearby fields" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      # |(0,0)|(1,0)|(2,0)|(3,0)|
      # |(0,1)|(1,1)|(2,1)|(3,1)|
      # |(0,2)|(1,2)|(2,2)|(3,2)|
      # |(0,3)|(1,3)|(2,3)|(3,3)|
      # |(0,4)|(1,4)|(2,4)|(3,4)|

      grid.mine(1, 4)
      grid.mine(3, 0)
      grid.mine(3, 3)

      expect(grid.uncover(1, 1)).to eq(false)
      expect(grid.field_at(1, 1).mine_count).to eq(0)
      expect(grid.unmined_fields_remaining).to eq(35)
      expect(grid.cleared?).to eq(false)
      expect(grid.render(1, 1)).to eq([
        "  1░░░░░░░\n",
        "  1░░░░░░░\n",
        "  1░░░░░░░\n",
        "112░░░░░░░\n",
        "░░░░░░░░░░\n"
      ].join)
    end

    it "uncovers an empty field and an entire grid" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 1)

      grid.mine(9, 4)

      expect(grid.uncover(1, 1)).to eq(false)
      expect(grid.field_at(8, 3).mine_count).to eq(1)
      expect(grid.unmined_fields_remaining).to eq(0)
      expect(grid.cleared?).to eq(true)
      expect(grid.render(1, 1)).to eq([
        "          \n",
        "          \n",
        "          \n",
        "        11\n",
        "        1░\n"
      ].join)
    end

    it "uncovers a mine and all the remaining mines without a flag" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 5)

      grid.mine(1, 1)
      grid.mine(3, 0)
      grid.mine(4, 4)
      grid.mine(6, 2)
      grid.mine(8, 3)

      grid.flag(3, 0)
      grid.flag(4, 4)

      expect(grid.uncover(1, 1)).to eq(true)
      expect(grid.unmined_fields_remaining).to eq(45)
      expect(grid.cleared?).to eq(false)
      expect(grid.flags_remaining).to eq(3)
      expect(grid.render(1, 1)).to eq([
        "░░░F░░░░░░\n",
        "░*░░░░░░░░\n",
        "░░░░░░*░░░\n",
        "░░░░░░░░*░\n",
        "░░░░F░░░░░\n"
      ].join)
    end

    it "uncovers a mine and marks wrongly placed flags as X" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 5)

      grid.mine(1, 1)
      grid.mine(3, 0)
      grid.mine(4, 4)
      grid.mine(6, 2)
      grid.mine(8, 3)

      grid.flag(1, 2)
      grid.flag(3, 0)
      grid.flag(4, 4)
      grid.flag(6, 3)
      grid.flag(8, 2)

      expect(grid.uncover(1, 1)).to eq(true)
      expect(grid.unmined_fields_remaining).to eq(45)
      expect(grid.cleared?).to eq(false)
      expect(grid.flags_remaining).to eq(0)
      expect(grid.render(1, 1)).to eq([
        "░░░F░░░░░░\n",
        "░*░░░░░░░░\n",
        "░X░░░░*░X░\n",
        "░░░░░░X░*░\n",
        "░░░░F░░░░░\n"
      ].join)
    end

    it "cleares flags from uncovered areas" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)

      grid.mine(1, 4)
      grid.mine(5, 1)
      grid.mine(3, 3)

      grid.flag(0, 0)
      grid.flag(3, 4)
      grid.flag(5, 2)

      expect(grid.uncover(1, 1)).to eq(false)
      expect(grid.unmined_fields_remaining).to eq(29)
      expect(grid.cleared?).to eq(false)
      expect(grid.flags_remaining).to eq(1)
      expect(grid.render(1, 1)).to eq([
        "    1░░░░░\n",
        "    1░░░░░\n",
        "  112F░░░░\n",
        "112░░░░░░░\n",
        "░░░F░░░░░░\n"
      ].join)
    end
  end

  context "#render" do
    let(:pastel) { Pastel.new(enabled: true) }

    it "renders grid without the highlighted current position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)

      expect(grid.render(1, 1)).to eq([
       "░░░░░░░░░░\n",
       "░░░░░░░░░░\n",
       "░░░░░░░░░░\n",
       "░░░░░░░░░░\n",
       "░░░░░░░░░░\n"
      ].join)
    end

    it "renders grid with the highlighted current position" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      decorator = pastel.method(:decorate)

      expect(grid.render(1, 1, decorator: decorator)).to eq([
       "░░░░░░░░░░\n",
       "░\e[42m░\e[0m░░░░░░░░\n",
       "░░░░░░░░░░\n",
       "░░░░░░░░░░\n",
       "░░░░░░░░░░\n"
      ].join)
    end

    it "renders grid with the highlighted current position on uncovered area" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)
      decorator = pastel.method(:decorate)

      grid.mine(1, 4)
      grid.mine(5, 1)
      grid.mine(3, 3)

      grid.uncover(1, 1)

      expect(grid.render(1, 1, decorator: decorator)).to eq([
        "    \e[36m1\e[0m░░░░░\n",
        " \e[42m \e[0m  \e[36m1\e[0m░░░░░\n",
        "  \e[36m1\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░░\n",
        "\e[36m1\e[0m\e[36m1\e[0m\e[32m2\e[0m░░░░░░░\n",
        "░░░░░░░░░░\n"
      ].join)
    end

    it "renders grid with uncovered area" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 3)

      grid.mine(1, 4)
      grid.mine(5, 1)
      grid.mine(3, 3)

      grid.uncover(1, 1)

      expect(grid.render(1, 1)).to eq([
        "    1░░░░░\n",
        "    1░░░░░\n",
        "  112░░░░░\n",
        "112░░░░░░░\n",
        "░░░░░░░░░░\n"
      ].join)
    end

    it "renders all placed flags exceeding the limit" do
      grid = described_class.new(width: 10, height: 5, mines_limit: 7)

      grid.flag(1, 1)
      grid.flag(2, 4)
      grid.flag(4, 2)
      grid.flag(5, 0)
      grid.flag(6, 1)
      grid.flag(7, 3)
      grid.flag(8, 1)
      grid.flag(9, 4)

      grid.flag(0, 0)
      grid.flag(0, 0)

      expect(grid.flags_remaining).to eq(-1)
      expect(grid.render(1, 1)).to eq([
        "░░░░░F░░░░\n",
        "░F░░░░F░F░\n",
        "░░░░F░░░░░\n",
        "░░░░░░░F░░\n",
        "░░F░░░░░░F\n"
      ].join)
    end
  end
end
