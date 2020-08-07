module Game
  class HideNSeek
    attr_reader :rooms

    def initialize
      @rooms = Rooms.constants
      @rooms.delete :BasicRoom
      @rooms = @rooms.map { |room| Rooms.const_get(room).new }
    end

    def lets_play!
      "Ready or Not, Here I Come!\n\n"
    end

    def hide
      room = rooms.sample
      room.hide
      puts room
    end

    def ask_where_to_look
      "Where do you want to look?\n\n" +
      rooms.each_with_index.map { |room, i| "\t#{i + 1} - #{room}" }.join("\n")
    end
  end

  module Rooms
    class BasicRoom
      attr_accessor :hiding_location

      def initialize
        self.hiding_location = ""
      end

      def hide
        self.hiding_location = locations.sample
      end

      def seek?(location)
        locations[location - 1] == hiding_location
      end

      def locations
        raise NotImplementedError, "locations is not implemented for #{self.class}"
      end
    end

    class LivingRoom < BasicRoom
      def locations
        [
          "Under the table",
          "In the closet",
          "Behind the picture frame",
          "Behind the drapes",
          "Next to the T.V.",
          "Under the rug",
          "Under the chair"
        ]
      end

      def to_s
        "Living Room"
      end
    end
    class Kitchen < BasicRoom
      def locations
        [
          "In the cupboard",
          "Behind the fridge",
          "In the fridge",
          "In the dishwasher",
          "In the oven",
          "In the garbage can"
        ]
      end

      def to_s
        "Kitchen"
      end
    end
    class Bathroom < BasicRoom
      def locations
        [
          "In the tub",
          "Under the sink",
          "Next to the toilet",
          "Behind the stack of toilet paper"
        ]
      end

      def to_s
        "Bathroom"
      end
    end
    class Bedroom < BasicRoom
      def locations
        [
          "Under the bed",
          "Under the sheets",
          "Under the pillow",
          "Under the big stuffies",
          "Under the comforter"
        ]
      end
      def to_s
        "Bedroom"
      end
    end
    class PlayRoom < BasicRoom
      def locations
        [
          "Under the stack of toys",
          "In the toy closet",
          "In the toy basket",
          "Under the slide",
          "Under the swing",
          "Under the stack of A-B-C mats",
          "On top of the shelf"
        ]
      end

      def to_s
        "Play Room"
      end
    end
    class Office < BasicRoom
      def locations
        [
          "Under the stack of paper",
          "Under the desk",
          "Under the chair",
          "On top of the light",
          "Behind the books",
          "In the drawer",
          "On top of the fan"
        ]
      end

      def to_s
        "Office"
      end
    end
  end
end

class LetsPlay
  attr_reader :game

  def initialize
    @game = Game::HideNSeek.new
    @game.hide
  end

  def play
    puts game.lets_play!

    puts game.ask_where_to_look

    puts
    room = select_room
    until valid_room?(room)
      puts "\nPlease enter a valid room #"
      room = select_room
    end

    room = game.rooms[room - 1]

    puts "You enter the #{room}"

    puts "\n Where do you want to look in the #{room}?"

    room.locations.each_with_index.map { |loc, i| puts "\t#{i + 1} - #{loc}" }

    location = gets.chomp.to_i

    found = room.seek?(location)


    until found
      puts "Sorry, couldn't find the person #{location}"

      puts "Please look again!"

      room.locations.each_with_index.map { |loc, i| puts "\t#{i + 1} - #{loc}" }

      location = gets.chomp.to_i

      found = room.seek?(location)
    end

    puts "You found the person!"
  end

  def select_room
    print "Select a room to enter: "
    gets.chomp.to_i
  end

  def valid_room? room
    room > 0 && room <= game.rooms.length
  end
end

LetsPlay.new.play






























