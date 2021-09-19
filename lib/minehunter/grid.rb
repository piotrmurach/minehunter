# frozen_string_literal: true

require_relative "field"

module Minehunter
  # A grid with fields representation
  #
  # @api private
  class Grid
    # Track the number of flags remaining
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :flags_remaining

    # Track the number of unmined fields remaining
    #
    # @return [Integer]
    #
    # @api public
    attr_reader :unmined_fields_remaining

    # Create a Grid instance
    #
    # @param [Integer] width
    #   the number of columns
    # @param [Integer] height
    #   the number of rows
    # @param [Integer] mines_limit
    #   the total number of mines
    #
    # @api public
    def initialize(width: nil, height: nil, mines_limit: nil)
      if mines_limit >= width * height
        raise Error, "cannot have more mines than available fields"
      end

      @width = width
      @height = height
      @mines_limit = mines_limit
      @fields = []

      reset
    end

    # Reset all fields to defaults
    #
    # @api public
    def reset
      (@width * @height).times do |i|
        @fields[i] = Field.new
      end
      @unmined_fields_remaining = @width * @height - @mines_limit
      @flags_remaining = @mines_limit
    end

    # Check whether or not the grid is cleared
    #
    # @return [Boolean]
    #
    # @api public
    def cleared?
      @unmined_fields_remaining.zero?
    end

    # All fields with mines
    #
    # @return [Array<Field>]
    #
    # @api public
    def mines
      @fields.select(&:mine?)
    end

    # Move up on the grid
    #
    # @return [Integer]
    #
    # @api public
    def move_up(y)
      y.zero? ? @height - 1 : y - 1
    end

    # Move down on the grid
    #
    # @return [Integer]
    #
    # @api public
    def move_down(y)
      y == @height - 1 ? 0 : y + 1
    end

    # Move left on the grid
    #
    # @return [Integer]
    #
    # @api public
    def move_left(x)
      x.zero? ? @width - 1 : x - 1
    end

    # Move right on the grid
    #
    # @return [Integer]
    #
    # @api public
    def move_right(x)
      x == @width - 1 ? 0 : x + 1
    end

    # Find field index at a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @return [Integer]
    #
    # @api public
    def at(x, y)
      y * @width + x
    end

    # Find a field at a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @return [Field]
    #
    # @api public
    def field_at(x, y)
      @fields[at(x, y)]
    end

    # Set a mine at a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @api public
    def mine(x, y)
      field_at(x, y).mine!
    end

    # Add or remove a flag at a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @api public
    def flag(x, y)
      field = field_at(x, y)
      return unless field.cover?

      @flags_remaining += field.flag? ? 1 : -1
      field.flag
    end

    # Check whether or not there is a flag at a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @return [Boolean]
    #
    # @api public
    def flag?(x, y)
      field_at(x, y).flag?
    end

    # Fill grid with mines skipping the current position and nearby fields
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    # @param [Proc] randomiser
    #   the mine position randomiser
    #
    # @api public
    def fill_with_mines(x, y, randomiser: DEFAULT_RANDOMISER)
      limit = @mines_limit
      while limit > 0
        mine_x = randomiser[@width]
        mine_y = randomiser[@height]
        next if mine_x == x && mine_y == y
        next if fields_next_to(x, y).include?([mine_x, mine_y])

        field = field_at(mine_x, mine_y)
        next if field.mine?

        field.mine!
        limit -= 1
      end
    end

    # Enumerate fields next to a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @return [Enumerator]
    #   the coordinates for nearby fields
    #
    # @api public
    def fields_next_to(x, y)
      return to_enum(:fields_next_to, x, y) unless block_given?

      -1.upto(1) do |offset_x|
        -1.upto(1) do |offset_y|
          close_x = x + offset_x
          close_y = y + offset_y

          next if close_x == x && close_y == y
          next unless within?(close_x, close_y)

          yield(close_x, close_y)
        end
      end
    end

    # Check whether coordinates are within the grid
    #
    # return [Boolean]
    #
    # @api public
    def within?(x, y)
      x >= 0 && x < @width && y >= 0 && y < @height
    end

    # Total number of mines next to a given position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @return [Integer]
    #
    # @api public
    def count_mines_next_to(x, y)
      fields_next_to(x, y).reduce(0) do |acc, cords|
        acc += 1 if field_at(*cords).mine?
        acc
      end
    end

    # Uncover fields surrounding the position
    #
    # @param [Integer] x
    #   the x coordinate
    # @param [Integer] y
    #   the y coordinate
    #
    # @return [Boolean]
    #   whether or not uncovered a mine
    #
    # @api public
    def uncover(x, y)
      field = field_at(x, y)

      if field.mine?
        field.uncover
        uncover_mines
        return true
      end

      mine_count = count_mines_next_to(x, y)
      field.mine_count = mine_count
      flag(x, y) if field.flag?
      field.uncover
      @unmined_fields_remaining -= 1

      if mine_count.zero?
        fields_next_to(x, y) do |close_x, close_y|
          close_field = field_at(close_x, close_y)
          if close_field.cover? && !close_field.mine?
            uncover(close_x, close_y)
          end
        end
      end
      false
    end

    # Uncover all mines without a flag
    #
    # @api public
    def uncover_mines
      @fields.each do |field|
        if field.mine? && !field.flag? || field.flag? && !field.mine?
          field.wrong if field.flag?
          field.uncover
        end
      end
    end

    # Render grid
    #
    # @return [String]
    #
    # @api public
    def render(x, y, decorator: DEFAULT_DECORATOR)
      out = []

      @height.times do |field_y|
        @width.times do |field_x|
          field = field_at(field_x, field_y)
          rendered_field = field.render(decorator: decorator)

          if field_x == x && field_y == y && decorator
            bg_color = field.mine? && !field.cover? ? :on_red : :on_green
            rendered_field = decorator[rendered_field, bg_color]
          end

          out << rendered_field
        end
        out << "\n"
      end

      out.join
    end
  end # Grid
end # Minehunter
