# frozen_string_literal: true

module Minehunter
  # An intro screen content
  #
  # @api private
  class Intro
    INTRO = [
      " ,-*",
      "(_) Minehunter",
      "",
      "Movement:",
      "     [↑]        [w]",
      "  [←][↓][→]  [a][s][d]",
      "",
      "Actions:",
      "  f - toggle flag",
      "  space - uncover field",
      "  r - restart game",
      "  q - quit game",
      "",
      "Press any key to start!"
    ].freeze

    # The maximum intro screen content width
    #
    # @return [Integer]
    #
    # @api public
    def self.width
      @width ||= INTRO.max_by(&:length).size
    end

    # The intro screen content height
    #
    # @return [Integer]
    #
    # @api public
    def self.height
      @height ||= INTRO.size
    end

    # Render intro screen content
    #
    # @return [String]
    #
    # @api public
    def self.render
      INTRO.join("\n")
    end
  end # SplashScreen
end # Minehunter
