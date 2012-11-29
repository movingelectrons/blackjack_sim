
require "test/unit"
@testing = true
require "bjs"
 
class TestBJS < Test::Unit::TestCase
  def setup
    @player = Player.new
	end

  def test_inital_cash
    assert_equal(500, @player.cash )
  end

	def test_simple_total
		@player.discard
		@player.cards.push(Card.new(10))
    @player.cards.push(Card.new(9))
    assert_equal(19, @player.total )
	end

	def test_complex_total
		@player.discard
		@player.cards.push(Card.new("A"))
    @player.cards.push(Card.new(5))
    @player.cards.push(Card.new(5))
		assert_equal(21, @player.total )
	end

	def test_complex_total_2
		@player.discard
		@player.cards.push(Card.new(9))
    @player.cards.push(Card.new("A"))
    @player.cards.push(Card.new("A"))
		assert_equal(21, @player.total )
	end

	def test_complex_total_3
		@player.discard
		@player.cards.push(Card.new(2))
    @player.cards.push(Card.new("A"))
    @player.cards.push(Card.new("A"))
    @player.cards.push(Card.new(6))
		assert_equal(20, @player.total )
	end
 
end

