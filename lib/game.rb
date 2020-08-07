module Game
  class HideNSeek
    attr_accessor :room_to_hide_in
    attr_reader :rooms

    def initialize
      @rooms = Rooms.constants
      @rooms.delete :BasicRoom
      @rooms = @rooms.map { |room| Rooms.const_get(room).new }
    end

    def lets_play!
      "(Hint: Type 'clue' at anytime if you need a clue\n\n" +
      "Ready or Not, Here I Come!\n\n"
    end

    def hide
      self.room_to_hide_in = rooms.sample
      room_to_hide_in.hide
      # puts room_to_hide_in
    end

    def ask_where_to_look
      "Where do you want to look?\n\n" +
      rooms.each_with_index.map { |room, i| "\t#{i + 1} - #{room}" }.join("\n")
    end

    def clue
      room = rooms.sample
      if room == room_to_hide_in
        puts "Hiding in a room with a #{room.class::LOCATIONS.sample}"
      else
        puts "Not in a room with a #{room.class::LOCATIONS.sample}"
      end
      :hint
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

      def display_locations
        locations.each_with_index.map { |loc, i| puts "\t#{i + 1} - #{loc}" }
      end

      def seek?(location)
        locations[location - 1] == hiding_location
      end

      DESCRIPTOR = [
        UNDER = "Under the",
        IN = "In the",
        BEHIND = "Behind the",
        NEXT = "Next to the",
        ONTOP = "On top of the"
      ]

      def locations
        raise NotImplementedError, "locations is not implemented for #{self.class}"
      end
    end

    class LivingRoom < BasicRoom
      LOCATIONS = [
        TABLE = "table",
        CLOSET = "closet",
        PICTUREFRAME = "picture frame",
        CURTAIN = "curtain",
        TV = "T.V.",
        RUG = "rug",
        CHAIR = "chair",
      ]
      def locations
        [
          "#{UNDER} #{TABLE}",
          "#{IN} #{CLOSET}",
          "#{BEHIND} #{PICTUREFRAME}",
          "#{BEHIND} #{CURTAIN}",
          "#{NEXT} #{TV}",
          "#{UNDER} #{RUG}",
          "#{UNDER} #{CHAIR}"
        ]
      end

      def to_s
        "Living Room"
      end
    end
    class Kitchen < BasicRoom
      LOCATIONS = [
        CUPBOARD = "cupboard",
        FRIDGE = "fridge",
        DISHWASHER = "dishwasher",
        OVEN = "oven",
        GARBAGECAN = "garbage can"
      ]
      def locations
        [
          "#{IN} #{CUPBOARD}",
          "#{BEHIND} #{FRIDGE}",
          "#{IN} #{FRIDGE}",
          "#{IN} #{DISHWASHER}",
          "#{IN} #{OVEN}",
          "#{IN} #{GARBAGECAN}"
        ]
      end

      def to_s
        "Kitchen"
      end
    end
    class Bathroom < BasicRoom
      LOCATIONS = [
        TUB= "tub",
        SINK= "sink",
        TOILET= "toilet",
        TOILETPAPER= "stack of toilet paper"
      ]

      def locations
        [
          "#{IN} #{TUB}",
          "#{UNDER} #{SINK}",
          "#{NEXT} #{TOILET}",
          "#{BEHIND} #{TOILETPAPER}"
        ]
      end

      def to_s
        "Bathroom"
      end
    end
    class Bedroom < BasicRoom
      LOCATIONS = [
         BED = "bed",
         SHEET = "sheet",
         PILLOW = "pillow",
         STUFFIE = "stuffie",
         COMFORTER = "comforter"
      ]

      def locations
        [
          "#{UNDER} #{BED}",
          "#{UNDER} #{SHEET}s",
          "#{UNDER} #{PILLOW}",
          "#{UNDER} big #{STUFFIE}s",
          "#{UNDER} #{COMFORTER}"
        ]
      end
      def to_s
        "Bedroom"
      end
    end
    class PlayRoom < BasicRoom
      LOCATIONS = [
        TOYS = "stack of toys",
        CLOSET = "closet",
        BASKET = "basket",
        SLIDE = "slide",
        SWING = "swing",
        MATS = "stack of A-B-C mats",
        SHELF = "shelf"
      ]
      def locations
        [
          "#{UNDER} #{TOYS}",
          "#{IN} toy #{CLOSET}",
          "#{IN} toy #{BASKET}",
          "#{UNDER} #{SLIDE}",
          "#{UNDER} #{SWING}",
          "#{UNDER} #{MATS}",
          "#{ONTOP} #{SHELF}"
        ]
      end

      def to_s
        "Play Room"
      end
    end
    class Office < BasicRoom
      LOCATIONS = [
        PAPER = "stack of paper",
        DESK = "desk",
        CHAIR = "chair",
        LIGHT = "light",
        BOOK = "book",
        DRAWER = "drawer",
        FAN = "fan"
      ]
      def locations
        [
          "#{UNDER} #{PAPER}",
          "#{UNDER} #{DESK}",
          "#{UNDER} #{CHAIR}",
          "#{ONTOP} #{LIGHT}",
          "#{BEHIND} #{BOOK}S",
          "#{IN} #{DRAWER}",
          "#{ONTOP} #{FAN}"
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

    room = select_room

    puts "You enter the #{room}"

    location = search_room(room)
    while hint_given?(location)
      location = search_room(room)
    end
    found = room.seek?(location)

    until found
      puts "Sorry, couldn't find the person #{room.locations[location - 1]}"

      puts "Would you like to search the room again? (yes/no) "
      answer = get_user_input to_i: false

      if answer.downcase[0] == 'y'
        location = search_room(room)
        found = room.seek?(location)
      else
        room = select_room

        puts "You enter the #{room}"

        location = search_room(room)
        found = room.seek?(location)
      end
    end

    puts "You found the person!"
  end

  def select_room
    puts game.ask_where_to_look
    print "Select a room to enter: "
    room = get_user_input
    while hint_given?(room)
      print "Select a room to enter: "
      room = get_user_input
    end
    validate_room(room)
    game.rooms[room - 1]
  end

  def hint_given? room
    room == :hint
  end

  def get_user_input(to_i: true)
    input = gets.chomp
    return game.clue if input == 'clue'
    return input.to_i if to_i
    input
  end

  def validate_room(room)
    until valid_room?(room)
      puts "\nPlease enter a valid room #"
      room = select_room
    end
    room
  end

  def valid_room? room
    room > 0 && room <= game.rooms.length
  end

  def search_room room
    puts "\n Where do you want to look in the #{room}?"

    room.display_locations

    get_user_input
  end
end

LetsPlay.new.play






























