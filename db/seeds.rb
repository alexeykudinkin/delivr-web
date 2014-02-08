
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
        address: 'Zemledelcheskaya 5/2'
      }),
    destination:
      Travels::Places::Destination.new({
        address: 'Drezdenskaya 20'
      })
  }
)