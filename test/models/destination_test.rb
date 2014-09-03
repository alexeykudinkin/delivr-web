require 'test_helper'

class DestinationTest < ActiveSupport::TestCase

  test "create destination" do
    assert_difference "Travels::Places::Destination.all.count", 1, "Gotcha! Destination should be created" do
      Travels::Places::Destination.create({
        items: [
          Item.create({ name: "Bouquet", weight: 3.kilo, travel: @travel }),
          Item.create({ name: "Pizza",   weight: 1.kilo, travel: @travel })
        ],
        due_date_attributes:{
          starts: 1.hour.from_now,
          ends:   3.hour.from_now
        }
      })
    end
  end

  test "origin should belong-to/have-one travel" do
    o = @place.becomes(Travels::Places::Origin)

    @travel.origin = o

    assert_equal o.travel, @travel, "Gotcha! Those should be equal"
  end

  test "destination should belong-to/have-one travel" do
    d = @place.becomes(Travels::Places::Destination)

    # We need to establish some items and due-date to have it valid
    d.build_due_date(
      starts: 1.hour.from_now,
      ends:   3.hour.from_now
    )
    d.items << @item

    # Ultimately binding destination with the travel
    @travel.items << @item

    assert_equal d.travel, @travel, "Gotcha! Those should be equal"
  end

  protected

    def setup
      super

      @travel = travels_travels(:_1)
      @place  = travels_places_places(:UNI7911)
      @item   = items(:tulips)
    end

end