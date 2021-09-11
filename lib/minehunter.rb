# frozen_string_literal: true

require "pastel"
require "tty-screen"

require_relative "minehunter/game"
require_relative "minehunter/version"

module Minehunter
  class Error < StandardError; end

  # Apply no styling
  DEFAULT_DECORATOR = ->(str, *_colors) { str }

  # Random number generator
  GENERATOR = Random.new

  # Generate random number less than max
  DEFAULT_RANDOMISER = ->(max) { GENERATOR.rand(max) }

  # Start the game
  #
  # @api public
  def self.run
    decorator = Pastel.new.method(:decorate)
    Game.new(width: 9, height: 9, mines_limit: 10,
             screen_width: TTY::Screen.width,
             screen_height: TTY::Screen.height,
             decorator: decorator).run
  end
end # Minehunter
