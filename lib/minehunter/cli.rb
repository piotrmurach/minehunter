# frozen_string_literal: true

require "pastel"
require "tty-option"
require "tty-screen"

require_relative "game"
require_relative "version"

module Minehunter
  # The main interface to the game
  #
  # @api public
  class CLI
    include TTY::Option

    LEVELS = {
      "easy" => {width: 9, height: 9, mines: 10},
      "medium" => {width: 16, height: 16, mines: 40},
      "hard" => {width: 30, height: 16, mines: 99}
    }.freeze

    usage do
      no_command

      desc "Hunt down all the mines and uncover remaining fields"

      example "To play the game on a 20x15 grid with 35 mines run"

      example "$ #{program} -c 20 -r 15 -m 35"
    end

    option :width do
      short "-c"
      long "--cols INT"
      desc "Set number of columns"
      convert :int
    end

    option :height do
      short "-r"
      long "--rows INT"
      desc "Set number of rows"
      convert :int
    end

    option :level do
      default "medium"
      short "-l"
      long "--level NAME"
      desc "Set difficulty level"
      permit %w[easy medium hard]
    end

    option :mines do
      short "-m"
      long "--mines INT"
      desc "Set number of mines"
      convert :int
    end

    flag :help do
      short "-h"
      long "--help"
      desc "Print usage"
    end

    flag :version do
      short "-v"
      long "--version"
      desc "Print version"
    end

    # Run the game
    #
    # @param [Array<String>] argv
    #   the command line parameters
    # @param [IO] input
    #   the input stream, defaults to stdin
    # @param [IO] output
    #   the output stream, defaults to stdout
    # @param [Hash] env
    #   the environment variables
    # @param [Boolean] color
    #   whether or not to style the game
    # @param [Integer] screen_width
    #   the terminal screen width
    # @param [Integer] screen_height
    #   the terminal screen height
    #
    # @api public
    def run(argv = ARGV, input: $stdin, output: $stdout, env: {}, color: nil,
            screen_width: TTY::Screen.width, screen_height: TTY::Screen.height)
      parse(argv)

      if params[:help]
        output.print help
        exit
      elsif params[:version]
        output.puts VERSION
        exit
      elsif params.errors.any?
        output.puts params.errors.summary
        exit 1
      else
        level = LEVELS[params[:level]]
        decorator = Pastel.new(enabled: color).method(:decorate)
        game = Game.new(
          input: input,
          output: output,
          env: env,
          width: params[:width] || level[:width],
          height: params[:height] || level[:height],
          screen_width: screen_width,
          screen_height: screen_height,
          mines_limit: params[:mines] || level[:mines],
          decorator: decorator
        )
        game.run
      end
    rescue Minehunter::Error => err
      output.puts "Error: #{err}"
      exit 1
    end
  end # CLI
end # Minehunter
