$testing = true
require "bjs"

class GameMock
  def initialize(numAI = 0, numDecks = 1, testing = true)
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
	end
	def getInput(ptype)
    if ptype == "bet" then
      "100"
		elsif ptype == "hit" then
      "s"
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
end

