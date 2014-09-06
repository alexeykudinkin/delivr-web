roots = {
  mk: {
    name:   'Mike Krinkin',
    phone:  '79052168692',
    email:  'mike@delivr.ru',

    role:   Users::Roles::Role.as("Admin"),

    password:               'qwerty',
    password_confirmation:  'qwerty'
  },

  ak: {
    name:   'Alexey Kudinkin',
    phone:  '79117483835',
    email:  'alexey@delivr.ru',

    role:   Users::Roles::Role.as("Admin"),

    password:               'qwerty',
    password_confirmation:  'qwerty'
  }
}

Users::Customer.create!(roots[:mk])
Users::Customer.create!(roots[:ak])
