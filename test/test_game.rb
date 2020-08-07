require "minitest/autorun"

require_relative "../lib/game.rb"

class TestGame < Minitest::Test

  def test_play_message
    assert_equal "Ready or Not, Here I Come!", Game::HideNSeek.new.lets_play!
  end

end
