# module Extensions

  class Fixnum < Integer

    def kilo
      self * KILO
    end

    # Nothing interesting here, just syntactic sugar

    def rubles
      self
    end

  end


  class Numeric

    KILO = 1000

    def to_kilo
      self / KILO
    end

  end

# end