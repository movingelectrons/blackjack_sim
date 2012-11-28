#####################################
# Ruby powered blackjack similator  #
# Copywrite 2012 Cutty              #
#####################################

class Card #no point in keeping track of suite for now.
  def initialize(faceValue)
    @faceValue = faceValue
		@value = nil
		if (@faceValue == "K" or @faceValue == "Q" or @faceValue == "J") then 
      @value = 10
    elsif (@faceValue == "A") then
      @value = 11
		else
			@value = Integer(faceValue)
    end
	end
	def getFacevalue
    @faceValue
	end
	def getValue
    @value 
	end
end

class Deck
  def initialize()
    faceValues = %w(2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A)
		@cards = Array.new()
		faceValues.each do |x|
      @cards.push(Card.new(x))
		end
	end
  def getDeck
    @cards
	end
end

class Shoe #composed of one or more decks
  def initialize(numDecks)
		@cards = Array.new()
    numDecks.times do
      #get a deck and add all its cards to the shoe
      deck = Deck.new()
      deck.getDeck.each do |x|
        @cards.push(x)
			end
		end
		#shuffle them all
		@cards.shuffle!
	end
	def dealCard
    @cards.pop
	end
	def cardsLeft
    @cards.count
	end
end

class Player #base class for dealer and AI
  def initialize
		@cards = Array.new
		@cash = 500
  end
	def cash
	  @cash
	end
	def lost(bet)
    @cash = @cash - bet
	end
	def win(bet)
    @cash = @cash + bet
	end
	def hit(card)
		puts "#{self.class} hits gets a #{card.getFacevalue}"
    @cards.push(card)
	end
	def getCards
		@cards
	end
	def aces
		i = 0
    @cards.each do |c|
      if c.getFacevalue == "A" then 
			  i = i + 1
			end
		end
		return i
	end
	def totalHandValue(aces_min = 0)
		total = 0
    @cards.each do |c|
			if c.getFacevalue == "A" and aces_min>0 then
        total = total + 1
				aces_min = aces_min - 1
			else
        total = total + c.getValue
			end
			if total > 21 and aces_min < self.aces then
			  self.totalHandValue(aces_min)
			end
		end
		return total
	end
	def discard
    @cards = Array.new
	end
end

class AI < Player
end

class Dealer < Player
end

class Game
  def initialize(numAI = 0, numDecks = 1)
		@minbet = 1
		@maxbet = 100
    @shoe = Shoe.new(numDecks)
		@player = Player.new
		@players = Array.new
		@players.push(@player)
		numAI.times do
      @players.push(AI.new)
		end
		@dealer = Dealer.new
	end
	def minbet
    @minbet
	end
	def maxbet
		@maxbet
	end
  def getShoe
    @shoe
	end
	def getPlayer
	  @player
	end
	def getDealer
		@dealer
	end
	def getPlayers
		@players
	end
end

class Hand
  def initialize(game)
    @game = game
		@shoe = game.getShoe
    @dealer = game.getDealer
		@player = game.getPlayer
		@players = game.getPlayers
		@bet = nil
		#discard all cards
    @dealer.discard
		@players.each do |x| x.discard end

		#take bets
		l=true
		while l==true do
		  puts "Place your bet.  You have #{@player.cash}"  
      STDOUT.flush  
      res = Integer(gets.chomp)
      if res >= @game.minbet and res <= @game.maxbet and res <= @player.cash then
			  @bet = res
			  l=false
		  else
        puts "Invalid bet. Min #{@game.minbet} Max #{@game.maxbet}"
		  end
		end

		#deal cards
		2.times do @dealer.getCards.push(@shoe.dealCard) end
		@game.getPlayers.each do |x|
		  2.times do x.getCards.push(@shoe.dealCard) end
	  end

    #show players their cards and other and dealers
    puts "Dealer   #{@dealer.getCards[0].getValue}"
		@players.each do |p|
		  print "#{p.class} "
	    p.getCards.each do |x| print " #{x.getValue}" end
	    puts "\n"
		end

		#TODO give each player oppturtunity to hit or stand    
		l=true
		while l==true do
		  #check to see if we have 21
      if @player.totalHandValue == 21	then
        #TODO AI players
				dealerTurn()
				l=false
			end
			#check to see if we went over
			if @player.totalHandValue > 21	then
				puts "BUST"
				dealerTurn()
				l=false
			end

			if l==true then
		    puts "(h)it or (s)tay?"
        STDOUT.flush  
        res = gets.chomp
        if res == "h" then
          @player.hit(@shoe.dealCard)		
			  elsif res == "s" then
          l=false
			  end
			end
		end

    #show dealers cards
    print "Dealers hand: "
	  @dealer.getCards.each do |x| print " #{x.getValue}" end
	  puts "\n"

		dealerTurn()
	end

	def dealerTurn
    if @dealer.totalHandValue <= 17 then
			card = @shoe.dealCard
      @dealer.hit(card)
      self.dealerTurn
		else
      self.checkWinner
		end
	end
	
  def checkWinner #TODO check the AI players
		d = @dealer.totalHandValue
		p = @player.totalHandValue
	  if d == 21 and p == 21 then
      if @dealer.aces == 1 and @player.aces == 1 then
			  #push
			elsif @dealer.aces == 1 and @player.aces != 1 then
        @player.lost(@bet)
			elsif @dealer.aces != 1 and @player.aces == 1 then
				@player.win(@bet)
			end
		elsif d == p then
			#push
		elsif p==21 and d < 21 then
			#may get 2.5 times bet #FIXME
			@player.win(@bet)
		elsif p > d then
      @player.win(@bet)
	  elsif d > p then
			@player.lost(@bet)
		end
		puts "Hand over, dealer:#{d} player:#{p}"
	end

end

game = Game.new(0,3)
quit = false
until quit == true
  hand = Hand.new(game)

	if game.getShoe.cardsLeft < 20 then #TODO find out what this actually is
		quit = true
	end
end
