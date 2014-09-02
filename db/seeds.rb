#
# Seed in following data only unless inside PRODUCTION environment
#

require File.expand_path('../seeds/roles', __FILE__)
require File.expand_path('../seeds/roots', __FILE__)


unless Rails.env.production?

  # First trip!

  # Travels::Travel.create(
  #   {
  #     customer:             akudinkin,
  #     performer:            aopeykin,
  #
  #     origin:
  #       Travels::Places::Origin.new({
  #         address:      'Zemledelcheskaya 5/2',
  #         coordinates:  '(59.99083095027031, 30.324325561523438)'
  #       }),
  #
  #     destinations:
  #       [ Travels::Places::Destination.new({
  #           address:      'Drezdenskaya 20',
  #           coordinates:  '(60.01398209301588, 30.336427688598633)',
  #
  #           items:
  #             [ Item.new({
  #                   name:         'shitpack',
  #                   description:  'the most valuable thing!',
  #                   weight:       1000, # one kilo of picked shit
  #               }) ]
  #         })
  #       ]
  #   }
  # )

end
