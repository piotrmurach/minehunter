# frozen_string_literal: true

module Minehunter
  # A field on a gird representation
  #
  # @api private
  class Field
    BOMB = "*"
    COVER = "░"
    EMPTY = " "
    FLAG = "F"
    WRONG = "X"

    # Mappings of mine counts to colour names
    MINE_COUNT_TO_COLOR = {
      1 => :cyan,
      2 => :green,
      3 => :red,
      4 => :blue,
      5 => :magenta,
      6 => :yellow,
      7 => :bright_cyan,
      8 => :bright_green
    }.freeze

    # The number of mines in nearby fields
    #
    # @api public
    attr_accessor :mine_count

    # Create a Field instance
    #
    # @api public
    def initialize
      @flag = false
      @mine = false
      @cover = true
      @wrong = false
      @mine_count = 0
    end

    # Toggle flag for a covered field
    #
    # @api public
    def flag
      return unless cover?

      @flag = !@flag
    end

    # Whether or not there is a flag placed
    #
    # @return [Boolean]
    #
    # @api public
    def flag?
      @flag
    end

    # Mark as having a mine
    #
    # @api public
    def mine!
      @mine = true
    end

    # Whether or not the field has mine
    #
    # @return [Boolean]
    #
    # @api public
    def mine?
      @mine
    end

    # Uncover this field
    #
    # @api public
    def uncover
      @cover = false
    end

    # Whether or not the field has cover
    #
    # @return [Boolean]
    #
    # @api public
    def cover?
      @cover
    end

    # Mark as having wrongly placed flag
    #
    # @api public
    def wrong
      @wrong = true
    end

    # Whether or not a flag is placed wrongly
    #
    # @return [Boolean]
    #
    # @api public
    def wrong?
      @wrong
    end

    # Render the field
    #
    # @param [Proc] decorator
    #   apply style formatting
    #
    # @return [String]
    #
    # @api public
    def render(decorator: DEFAULT_DECORATOR)
      if !cover?
        if mine? then BOMB
        elsif flag? && wrong? then decorator[WRONG, :on_red]
        elsif !mine_count.zero?
          decorator[mine_count.to_s, MINE_COUNT_TO_COLOR[mine_count]]
        else EMPTY end
      elsif flag? then FLAG
      else COVER end
    end
  end # Field
end # Minehunter
