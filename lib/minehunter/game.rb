# frozen_string_literal: true

require "tty-box"
require "tty-cursor"
require "tty-reader"

require_relative "grid"
require_relative "intro"

module Minehunter
  # Responsible for playing mine hunting game
  #
  # @api public
  class Game
    # The keys to exit game
    #
    # @api private
    EXIT_KEYS = [?\C-x, "q"].freeze

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
    # @param [Integer] screen_width
    #   the terminal screen width
    # @param [Integer] screen_height
    #   the terminal screen height
    # @param [Pastel] decorator
    #   the decorator for styling
    # @param [Proc] randomiser
    #   the random number generator
    #
    # @api public
    def initialize(input: $stdin, output: $stdout, env: {},
                   width: nil, height: nil, mines_limit: nil,
                   screen_width: nil, screen_height: nil,
                   decorator: DEFAULT_DECORATOR, randomiser: DEFAULT_RANDOMISER)
      @output = output
      @width = width
      @top = (screen_height - height - 4) / 2
      @left = (screen_width - width - 4) / 2
      @pos_x = (width - 1) / 2
      @pos_y = (height - 1) / 2
      @decorator = decorator
      @randomiser = randomiser
      @box = TTY::Box
      @cursor = TTY::Cursor
      @reader = TTY::Reader.new(input: input, output: output, env: env,
                                interrupt: :exit)
      @grid = Grid.new(width: width, height: height, mines_limit: mines_limit)
      @intro = Intro
      @intro_top = (screen_height - @intro.height - 2) / 2
      @intro_left = (screen_width - @intro.width - 4) / 2

      reset
    end

    # Reset game
    #
    # @api public
    def reset
      @curr_x = @pos_x
      @curr_y = @pos_y
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
      @output.print cursor.hide + cursor.clear_screen + render_intro_box
      pressed_key = @reader.read_keypress
      keyctrl_x if EXIT_KEYS.include?(pressed_key)

      @output.print cursor.clear_screen
      @reader.subscribe(self)

      until @stop
        @output.print cursor.move_to(0, 0) + cursor.clear_line +
                      render_status_box +
                      cursor.move_to(0, 2) + render_grid_box
        @reader.read_keypress
      end
    ensure
      @output.print cursor.show
    end

    # Render box with intro
    #
    # @return [String]
    #
    # @api private
    def render_intro_box
      @box.frame(
        @intro.render,
        top: @intro_top,
        left: @intro_left,
        padding: [0, 1]
      )
    end

    # Render box with status message
    #
    # @return [String]
    #
    # @api private
    def render_status_box
      @box.frame(
        status,
        top: @top,
        left: @left,
        width: @width + 4,
        padding: [0, 1],
        border: {bottom: false}
      )
    end

    # Render box with grid
    #
    # @return [String]
    #
    # @api private
    def render_grid_box
      @box.frame(
        render_grid,
        top: @top + 2,
        left: @left,
        padding: [0, 1],
        border: {
          top_left: :divider_right,
          top_right: :divider_left
        }
      )
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
