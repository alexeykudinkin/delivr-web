
{
  ru: {
      i18n: {
        plural: {
          keys: [ :one, :few, :other ],
          rule: lambda { |n|
            if n == 1
              :one
            elsif [2, 3, 4].include?(n % 10) && ![12, 13, 14, 22, 23, 24].include?(n % 100)
              :few
            else
              :other
            end
          }
          #:ru => { :i18n => { :plural => { :keys => [:one, :few, :many, :other], :rule => lambda { |n| n % 10 == 1 && n % 100 != 11 ? :one : [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100) ? :few : n % 10 == 0 || [5, 6, 7, 8, 9].include?(n % 10) || [11, 12, 13, 14].include?(n % 100) ? :many : :other } } } },
        }
      }
    }
}
