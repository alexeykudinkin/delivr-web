
# First trip!

akudinkin =
  Users::Customer.create(
    {
      name:   'Alexey Kudinkin',
      phone:  '79117483835',

      password:               'qwerty',
      password_confirmation:  'qwerty'
    }
  )

aopeykin =
  Users::Performer.create(
    {
      name:     'Alexander Opeykin',
      phone:    '79312782160',

      password:               'qwerty',
      password_confirmation:  'qwerty'
    }
  )

Travels::Travel.create(
  {
    items:
      [ Item.new(
          {
            name:         'shitpack',
            description:  'the most valuable thing!',
            weight:       1000  # one kilo of picked shit
          }
        ) ],
    customer:             akudinkin,
    performer:            aopeykin,
    origin:
      Travels::Places::Origin.new({
        address:      'Zemledelcheskaya 5/2',
        coordinates:  '(59.99083095027031, 30.324325561523438)'
      }),
    destination:
      Travels::Places::Destination.new({
        address:      'Drezdenskaya 20',
        coordinates:  '(60.01398209301588, 30.336427688598633)'
      })
  }
)