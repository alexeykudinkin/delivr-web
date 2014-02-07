
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

Travel.create(
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
    origin_address:       'Zemledelcheskaya 5/2',
    destination_address:  'Drezdenskaya 20'
  }
)