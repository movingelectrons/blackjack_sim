#####################################
# Ruby powered blackjack similator  #
# Copywrite 2013 Jerome Stonebridge #
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
	def faceValue
    @faceValue
	end
	def value
    @value 
	end
end

class Deck
  def initialize()
    faceValues = %w(2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A)
		@cards = Array.new()
		faceValues.each do |x|
      @cards.push(Card.new(x))
		end
	end
  def cards
    @cards
	end
end

class Shoe #composed of one or more decks
  def initialize(numDecks = 1)
		@cards = Array.new()
    numDecks.times do
      deck = Deck.new()
      deck.cards.each do |x|
        @cards.push(x)
			end
		end
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
	def cards
		@cards
	end	
	def lose(bet)
    @cash = @cash - bet
		puts "#{self.class} lost #{bet}"
	end
	def win(bet)
    @cash = @cash + bet
		puts "#{self.class} won #{bet}"
	end
	def hit(card) #return false if bust or 21, true if not
		puts "#{self.class} hits gets a #{card.faceValue}"
    @cards.push(card) 
		if self.total > 21 then
			puts "#{self.class} BUST"
			return false
		elsif self.total == 21 then
      return false
		else
			return true
		end
	end
	def aces
		i = 0
    @cards.each do |c|
      if c.faceValue == "A" then 
			  i = i + 1
			end
		end
		return i
	end
	def discard
    @cards = Array.new
	end	
	def total
		#start off with trying first ace as 11.
    total = self.total_helper(true)
		if total > 21 then
			total = self.total_helper(false)
		end
		return total
	end
	def total_helper(big_first_ace)
		total = 0
    @cards.each do |c|
			if c.faceValue == "A" and big_first_ace==true then
        total = total + 11
				big_first_ace = false
			elsif c.faceValue == "A" and big_first_ace==false then
				total = total + 1
			else
        total = total + c.value
			end
		end
		return total
  end
end

class AI < Player
end

class Dealer < Player
end

class Hand
  def initialize(game)
    @game = game
		@shoe = game.shoe
    @dealer = game.dealer
		@player = game.player
		@players = game.players
		@bet = nil
		#discard all cards
    @dealer.discard
		@players.each do |x| x.discard end

		#take bets
		l=true
		while l==true do
		  puts "\nPlace your bet. You have #{@player.cash}.  q to quit."  
      res = @game.getInput("bet")
			if res == "q" or res == "s" then 
			  exit
			else
				res = Integer(res)
			end
      if res >= @game.minbet and res <= @game.maxbet and res <= @player.cash then
			  @bet = res
			  l=false
		  else
        puts "Invalid bet. Min:#{@game.minbet} Max:#{@game.maxbet}"
		  end
		end

		#deal cards
		2.times do @dealer.cards.push(@shoe.dealCard) end
		@game.players.each do |x|
		  2.times do x.cards.push(@shoe.dealCard) end
	  end

    #show players their cards and other and dealers
    puts "Dealer  #{@dealer.cards[0].faceValue} X"
		@players.each do |p|
		  print "#{p.class} "
	    p.cards.each do |x| print " #{x.faceValue}" end
	    puts "\n"
		end

		l=true
		while l==true do
		  #check to see if we have 21
      if @player.total == 21	then
        #TODO AI players
				l=false
			end

			if l==true then
		    puts "(h)it or (s)tand?"
        res = @game.getInput("hit")
        if res == "h" then
          l = @player.hit(@shoe.dealCard)		
			  elsif res == "s" then
          l = false
			  end
			end
		end

    #show dealers cards
    print "Dealer has "
	  @dealer.cards.each do |x| print " #{x.faceValue}" end
	  puts "\n"
		dealerTurn()
	end

	def dealerTurn
		if @dealer.total < 17 then
			card = @shoe.dealCard
      @dealer.hit(card)
      self.dealerTurn
		else
      self.checkWinner
		end
	end
	
  def checkWinner 
		#TODO check the AI players
    #FIXME ? if you win with 21 you may get 2.5 times bet ? (make option? check casinos)
		d  = @dealer.total
		p  = @player.total
		da = @dealer.aces
		pa = @player.aces
    if d > 21 and p > 21 then
		  puts "push"
		elsif d > 21 and p <= 21 then
      @player.win(@bet)
		elsif p > 21 and d <= 21 then
      @player.lose(@bet)
		elsif d == 21 and p == 21 then
      if da == 1 and pa == 1 then
			  puts "push"
			elsif da == 1 then
        @player.lose(@bet)
			elsif da != 1 then
				@player.win(@bet)
			end
		elsif p > d then
      @player.win(@bet)
	  elsif d > p then
			@player.lose(@bet)	
		elsif d == p then
			puts "push"
		end
	end
end

class Game
  def initialize(numAI = 0, numDecks = 1, testing = false)
		@minbet  = 1
		@maxbet  = 100
    @shoe    = Shoe.new(numDecks)
		@dealer  = Dealer.new
		@player  = Player.new
		@players = Array.new
		@players.push(@player)
		numAI.times do
      @players.push(AI.new)
		end
		@testing = testing #to automate user input
		self.playHands
	end
	def getInput(ptype)
    if @testing == true then  #TODO ? get rid of this (currently necessary for testing)
      if ptype == "bet" then
        "100"
		  elsif ptype == "hit" then
        "s"
		  end
    else
		  STDOUT.flush
      gets.chomp
    end
  end
	def minbet
    @minbet
	end
	def maxbet
		@maxbet
	end
  def shoe
    @shoe
	end
	def player
	  @player
	end
	def dealer
		@dealer
	end
	def players
		@players
	end
	def playHands
    quit = false
    until quit == true
      hand = Hand.new(self)

			#TODO find out what this actually is (when does dealer resuffle the entire shoe)
	    if self.shoe.cardsLeft < 20 or @player.cash < @maxbet then
			  quit = true
	    end
	  end
	end
end

if $testing != true
  game = Game.new(0,3)
end

