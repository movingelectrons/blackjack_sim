$shoe = %w(2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 J J J J Q Q Q Q K K K K A A A A) 
$shoe.shuffle!
$pbet    = 0
$min_bet = 5
$pmoney  = 200
dcards   = Array.new()
pcards   = Array.new()

def cardInfo(dcards, pcards)
  puts "\nDealer: " + String(dcards[0]) + " X"
  cardString = ""
  pcards.each { |x| cardString = cardString +" "+x }
  puts "Player:" + cardString  
  if addCards(pcards)[0] > 21 then
    puts "BUST. you lose"
    main()
  end
end

def addCards(cards)
  r = 0
  first_ace = true
  cards.each do |x|
    if (x == "K" or x == "Q" or x == "J") then 
      x = 10
    elsif (x == "A" and first_ace == true) then
      if r + 11 <= 21 then 
        x = 11 
      else
        x = 1
      end
      first_ace = false
    elsif (x == "A" and first_ace == false) then
      x = 1
    end 
    r = r + Integer(x)
  end
  if first_ace == false and r == 21 and cards.count == 2 then
    b = true
  else
    b = false
  end
  return r,b
end

def checkWinner(dcards, pcards) #return "d,p,t" (dealer,player,tie)
  d,db = addCards(dcards)
  p,pb = addCards(pcards)
  #check for winner
  if d > p then return "d" end
  if p > d then return "p" end
  #check for tie (if one blackjack it winner)
  if p == d then 
    if db == true and pb == true then
      return "t"
    elsif db == false and pb == true then
      return "p"
    elsif db == true and pb == false then
      return "d"
    elsif db == false and pb == false then
      return "t"
    end
  end
end

def showDealerCards(dcards)
  puts "\nDealers cards"
  dcards.each { |x| puts x }
end

def dealerAI(dcards, pcards)
  dtotal = addCards(dcards)[0]
  while dtotal <= 16 do
    ncard = $shoe.pop
    puts ncard
    dcards.push(ncard)
    dtotal = addCards(dcards)[0]
    if dtotal > 21 then
      puts "Dealer busted"
      payout("p")
    else
      w = checkWinner(dcards, pcards)
      payout(w)
    end
  end
end

def payout(winner)
  #add double bet to player account if winner or orgional amt if tie.
  if winner == "p" then
    puts "Player wins " + String($pbet*2)
    $pmoney = $pmoney + ($pbet*2)
  elsif winner == "t" then
    puts "Player wins " + $pbet
    $pmoney = $pmoney + $pbet
  else
    #casino wins.  do nothing
  end
end

def main() #every time main() is called a new game begins
  if $pmoney == 0 then 
    puts "GAME OVER"
    exit 
  end
  game_started = true
  while game_started == true do
    le = false
    while le == false do
      puts "\n"+String($pmoney)+" credits avilable.\n"
      #puts "Min bet: "+String($min_bet)
      print "Bet: "
      STDOUT.flush  
      $pbet = Integer(gets.chomp)
      if $pbet >= $min_bet and $pbet <= $pmoney then
	$pmoney = $pmoney - $pbet
        game_started = true
        le = true
      else
        puts "Invalid bet please try again."
      end
    end
    
    #deal out first 2 cards 
    dcards = [$shoe.pop, $shoe.pop]
    pcards = [$shoe.pop, $shoe.pop]

    cardInfo(dcards, pcards)

    #check if we have 21 already
    pb = addCards(pcards)[1]
    if pb == false then
      le = false #exit flag
    elsif le == true then
      le = true
    end
    while le == false do
      puts "(h)it or (s)tay?"  
      STDOUT.flush  
      re = gets.chomp
      if re == "h" then
	ncard = $shoe.pop
        puts "Player hits. Got a "+ncard
        pcards.push(ncard)
        checkWinner(dcards, pcards)
      elsif re == "s" then
	dealerAI(dcards,pcards)
	#find out who won
	winner = checkWinner(dcards, pcards)
	#triger credits exchange 
	payout(winner)
        le = true
      else
        puts "what? try again... h or s"
      end
      cardInfo(dcards, pcards)
    end
  end
end
main()
