class AccountingController < ApplicationController

  restrict_access :account

  module Rates

    module Item

      class << self
        def rate(*items)
          items.reduce(0) do |s, item|
            if item[:weight].to_i.kilo > 5.kilo
              s + 75.rubles
            else
              s + 50.rubles
            end
          end
        end
      end

    end

    module Distance

      class << self
        def rate(d)
          d = d.to_i if d.is_a? String

          (d - 3.kilo).to_kilo * 30.rubles + 100.rubles
        end
      end

    end

  end

  def account
    attrs = whitelist(params, :account)

    val = Rates::Item::rate(attrs[:items]) + Rates::Distance::rate(attrs[:length])

    respond_to do |format|
      format.json { render json: { cost: val } }
    end
  end

  private

    def whitelist(params, action)
      case action
        when :account
          params.require(:route)
                .permit(
                  { items: [ :weight ] },
                  :length
                )

        else
          raise "Unknown action: #{action}"
      end
    end

end