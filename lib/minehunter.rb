# frozen_string_literal: true

require_relative "minehunter/cli"

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
    CLI.new.run
  end
end # Minehunter
