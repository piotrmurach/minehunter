# Minehunter

[![Gem Version](https://badge.fury.io/rb/minehunter.svg)][gem]
[![Actions CI](https://github.com/piotrmurach/minehunter/workflows/CI/badge.svg?branch=master)][gh_actions_ci]
[![Build status](https://ci.appveyor.com/api/projects/status/6jnp11d5jpcvua4j?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/bce6981d523e678029e7/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/minehunter/badge.svg)][coverage]

[gem]: https://badge.fury.io/rb/minehunter
[gh_actions_ci]: https://github.com/piotrmurach/minehunter/actions?query=workflow%3ACI
[appveyor]: https://ci.appveyor.com/project/piotrmurach/minehunter
[codeclimate]: https://codeclimate.com/github/piotrmurach/minehunter/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/minehunter

> Terminal mine hunting game built with [TTY toolkit components](https://ttytoolkit.org/components/).

Minehunter is a terminal puzzle game inspired by the classic "Minesweeper".

To win a game, a player needs to uncover all the fields inside the grid that don't contain mines. Uncovering a field with a mine immediately ends the game. When an uncovered field has no mine present, it can either be empty or show a number. The number specifies how many mines are in surrounding fields. Armed with this knowledge, the player can deduce fields safe to uncover and use a flag to mark the ones that hide a mine. The number of available flags matches the number of the randomly placed mines. But, the player is not required to use any flags to win the game.

There are three preconfigured difficulty levels:

* Easy - 9x9 with 10 mines
* Medium - 16x16 with 40 mines
* Hard - 32x32 with 99 mines

The player can also create a custom grid with an arbitrary number of mines.

Here is an example of playing on a 20x10 grid with 30 mines:

![Playing Minehunter](https://github.com/piotrmurach/minehunter/raw/master/assets/minehunter_custom_grid_play.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "minehunter"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install minehunter

## Usage

To start the game, run:

```shell
$ minehunter
```

Alternatively, run an alias:

```shell
$ minehunt
```

To change difficulty level use `--level` or `-l` option with `easy`, `medium` or `hard`:

```shell
$ minehunter --level easy
```

To customise the number of grid columns use  `--cols` or `-c` option. Likewise, specify  `--rows` or `-r` option to set the number of grid rows. For example, to play a game on a grid with `20` columns and `15` rows do:

```shell
$ minehunter --cols 20 --rows 15
```

Use `--mines` or `-m` option to set number of mines to be randomly placed on a grid:

```shell
$ minehunter --mines 25
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/minehunter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/piotrmurach/minehunter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [GNU Affero General Public License v3.0](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Minehunter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/minehunter/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2021 Piotr Murach. See [LICENSE.txt](LICENSE.txt) for further details.
