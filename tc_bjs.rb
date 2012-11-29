require "rubygems"
require "shoulda-context"
require "mocha/setup"
require "test/unit"
$testing = true
require "bjs"
require "gamemock"

class TestBJS < Test::Unit::TestCase
  context "card" do
    should "show value and facevalue 7" do
      @card = Card.new("7")
      assert_equal(7, @card.value)
			assert_equal("7", @card.faceValue)
		end
    should "show value and facevalue Q" do
      @card = Card.new("Q")
      assert_equal(10, @card.value)
			assert_equal("Q", @card.faceValue)
		end
    should "show value and facevalue A" do
      @card = Card.new("A")
      assert_equal(11, @card.value)
			assert_equal("A", @card.faceValue)
		end		
	end

  context "a deck" do
    setup do
      @deck = Deck.new
		end
		should "have 52 cards" do
      assert_equal(52, @deck.cards.count)
		end
	end

  context "a shoe" do
		setup do
      @shoe = Shoe.new
		end
		should "have 52 cards if composed of one deck" do
      assert_equal(52, @shoe.cardsLeft)
		end
    should "deal a card" do
			@card = @shoe.dealCard
      assert_equal(Card, @card.class)
      assert_equal(51, @shoe.cardsLeft)
		end
		should "have 156 cards if composed of three decks" do
			@shoe = Shoe.new(3)
      assert_equal(156, @shoe.cardsLeft)
		end
	end

	context "a player" do
    setup do
      @player = Player.new
	  end

    should "have 500 starting cash" do
      assert_equal(500, @player.cash )
    end

	  should "simple total" do
		  @player.discard
		  @player.cards.push(Card.new(10))
      @player.cards.push(Card.new(9))
      assert_equal(19, @player.total )
	  end

	  should "complex total" do
		  @player.discard
		  @player.cards.push(Card.new("A"))
      @player.cards.push(Card.new(5))
      @player.cards.push(Card.new(5))
		  assert_equal(21, @player.total )
	  end

	  should "complex total 2" do
		  @player.discard
		  @player.cards.push(Card.new(9))
      @player.cards.push(Card.new("A"))
      @player.cards.push(Card.new("A"))
		  assert_equal(21, @player.total )
	  end

	  should "complex total 3" do
		  @player.discard
		  @player.cards.push(Card.new(2))
      @player.cards.push(Card.new("A"))
      @player.cards.push(Card.new("A"))
      @player.cards.push(Card.new(6))
		  assert_equal(20, @player.total )
	  end
	end

	context "hand" do
    setup do
      @game = GameMock.new(0,3,true)
			@hand = Hand.new(@game)
		end

		should "dealers hand should be 17 or more" do
      assert(@game.dealer.total >= 17)
		end
	end

	context "hand" do
    setup do
      @game = GameMock.new(0,3,true)
			@hand = Hand.new(@game)
		end

		should "determine player winner and pay" do
      @game.dealer.discard
		  @game.players.each do |x| x.discard end
			@game.dealer.cards.push(Card.new("7"))
			@game.dealer.cards.push(Card.new("K"))
			@game.player.cards.push(Card.new("A"))
			@game.player.cards.push(Card.new("K"))

      assert_equal(@game.dealer.total, 17)
      assert_equal(@game.player.total, 21)
			pcash = @game.player.cash
			@hand.checkWinner
			assert_equal(pcash+100, @game.player.cash)
		end

		should "determine player loser and take" do
      @game.dealer.discard
		  @game.players.each do |x| x.discard end
			@game.dealer.cards.push(Card.new("A"))
			@game.dealer.cards.push(Card.new("J"))
			@game.player.cards.push(Card.new("10"))
			@game.player.cards.push(Card.new("Q"))

      assert_equal(@game.dealer.total, 21)
      assert_equal(@game.player.total, 20)
			pcash = @game.player.cash
			@hand.checkWinner
			assert_equal(pcash-100, @game.player.cash)
		end

		should "determine dealer loser and pay player" do
      @game.dealer.discard
		  @game.players.each do |x| x.discard end
			@game.dealer.cards.push(Card.new("4"))
			@game.dealer.cards.push(Card.new("9"))
			@game.dealer.cards.push(Card.new("A"))
			@game.dealer.cards.push(Card.new("9"))
			@game.player.cards.push(Card.new("9"))
			@game.player.cards.push(Card.new("Q"))

      assert_equal(@game.dealer.total, 23)
      assert_equal(@game.player.total, 19)
			pcash = @game.player.cash
			@hand.checkWinner
			assert_equal(pcash+100, @game.player.cash)
		end		
	end	
'''
  context "game" do
		setup do
	  end
	  should "have right number of cards in shoe" do
      #pinput = ["100","s","s","s","s"]
			#$stdin = StringIO.new(pinput.shift, "r:)
			@game = Game.new(0,1,true)
			assert_equal(52, @game.getShoe.cardsLeft)
	  end
	end
'''
end

