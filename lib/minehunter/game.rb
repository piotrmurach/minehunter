# frozen_string_literal: true

require "tty-cursor"
require "tty-reader"

require_relative "grid"

module Minehunter
  # Responsible for playing mine hunting game
  #
  # @api public
  class Game
    # The terminal cursor clearing and positioning
    #
    # @api public
    attr_reader :cursor

    # Create a Game instance
    #
    # @param [IO] input
    #   the input stream, defaults to stdin
    # @param [IO] output
    #   the output stream, defaults to stdout
    # @param [Hash] env
    #   the environment variables
    # @param [Integer] width
    #   the number of columns
    # @param [Integer] height
    #   the number of rows
    # @param [Integer] mines_limit
    #   the total number of mines
    # @param [Pastel] decorator
    #   the decorator for styling
    # @param [Proc] randomiser
    #   the random number generator
    #
    # @api public
    def initialize(input: $stdin, output: $stdout, env: {},
                   width: nil, height: nil, mines_limit: nil,
                   decorator: DEFAULT_DECORATOR, randomiser: DEFAULT_RANDOMISER)
      @output = output
      @decorator = decorator
      @randomiser = randomiser
      @cursor = TTY::Cursor
      @reader = TTY::Reader.new(input: input, output: output, env: env,
                                interrupt: :exit)
      @grid = Grid.new(width: width, height: height, mines_limit: mines_limit)
      reset
    end

    # Reset game
    #
    # @api public
    def reset
      @curr_x = 0
      @curr_y = 0
      @first_uncover = true
      @lost = false
      @stop = false
      @grid.reset
    end

    # Check whether or not the game is finished
    #
    # @return [Boolean]
    #
    # @api public
    def finished?
      @lost || @grid.cleared?
    end

    # Start the game
    #
    # @api public
    def run
      @output.print cursor.hide
      @output.print cursor.clear_screen
      @reader.subscribe(self)

      until @stop
        @output.print cursor.move_to(0, 0) + cursor.clear_line + status +
                      cursor.move_to(0, 1) + render_grid
        @reader.read_keypress
      end
    ensure
      @output.print cursor.show
    end

    # Status message
    #
    # @return [String]
    #
    # @api public
    def status
      if @lost
        "GAME OVER"
      elsif @grid.cleared?
        "WINNER"
      else
        "Flags #{@grid.flags_remaining}"
      end
    end

    # Render grid with current position marker
    #
    # @api private
    def render_grid
      @grid.render(@curr_x, @curr_y, decorator: @decorator)
    end

    # Control game movement and actions
    #
    # @param [TTY::Reader::KeyEvent] event
    #   the keypress event
    #
    # @api private
    def keypress(event)
      case event.value.to_sym
      when :h, :a then keyleft
      when :l, :d then keyright
      when :j, :s then keydown
      when :k, :w then keyup
      when :f, :g then flag
      when :r then reset
      when :q then keyctrl_x
      end
    end

    # Place a flag
    #
    # @api private
    def flag
      return if finished?

      @grid.flag(@curr_x, @curr_y) unless finished?
    end

    # Quit game
    #
    # @api private
    def keyctrl_x(*)
      @output.print cursor.clear_screen
      @output.print cursor.move_to(0, 0)
      @stop = true
    end

    # Uncover a field
    #
    # @api private
    def keyspace(*)
      return if @grid.flag?(@curr_x, @curr_y)

      if @first_uncover
        @grid.fill_with_mines(@curr_x, @curr_y, randomiser: @randomiser)
        @first_uncover = false
      end
      @lost = @grid.uncover(@curr_x, @curr_y)
    end
    alias keyenter keyspace
    alias keyreturn keyspace

    # Move cursor up
    #
    # @api private
    def keyup(*)
      return if finished?

      @curr_y = @grid.move_up(@curr_y)
    end

    # Move cursor down
    #
    # @api private
    def keydown(*)
      return if finished?

      @curr_y = @grid.move_down(@curr_y)
    end

    # Move cursor left
    #
    # @api private
    def keyleft(*)
      return if finished?

      @curr_x = @grid.move_left(@curr_x)
    end

    # Move cursor right
    #
    # @api private
    def keyright(*)
      return if finished?

      @curr_x = @grid.move_right(@curr_x)
    end
  end # Game
end # Minehunter
