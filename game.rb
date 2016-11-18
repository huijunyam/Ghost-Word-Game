require_relative 'player'
require 'set'
class Game
  MAX_COUNT = 5

  attr_reader :players, :fragment, :dictionary, :losses, :current_player,
              :previous_player

  def initialize(*player)
    @players = player
    @fragment = ""
    @losses = {}
    words = File.readlines("dictionary.txt").map(&:chomp)
    @dictionary = Set.new(words)

    players.each { |player| losses[player] = 0 }
  end

  def next_player!
    players.rotate!
    current_player
    until losses[current_player] < MAX_COUNT
      players.rotate!
      current_player
    end
  end

  def take_turn(player)
    play = player.guess
    until valid_play?(play)
      player.alert_invalid_guess
      play = player.guess
    end
    fragment << play

  end

  def current_player
    @current_player = players.first
  end

  def previous_player
    @previous_player = players.last
  end

  def valid_play?(string)
    return false unless string.downcase >= "a" && string.downcase <= "z"
    return false unless string.length == 1
    temp = fragment + string
    dictionary.each do |word|
      #return true if word[0..(temp.length - 1)] == temp
      return true if word.start_with?(temp)
    end
    false
  end

  def play_round
    until dictionary.include?(fragment) && fragment != ""
      puts "Current player : #{current_player.name}"
      take_turn(current_player)
      puts fragment
      next_player!
    end
    puts "#{previous_player.name} loses"
    losses_count
  end

  def losses_count
    losses[previous_player] += 1
  end

  def record(player)
    lose_word = "GHOST"
    lose_word[0...losses[player]]
  end

  def reset_fragment
    @fragment = ""
  end

  def remove_loser
    @losses.each do |player, loss|
      if loss == MAX_COUNT
        players.delete(player)
        @losses.delete(player)
      end 
    end
    update_status
  end

  def run
    until @losses.keys.length == 1
      system("clear")
      update_status
      play_round
      reset_fragment
      remove_loser
      sleep(2)
    end

    final_status
    winner
  end

  def update_status
    @losses.each do |player, loss|
      puts "#{player.name} has #{loss} losses"
      puts record(player)
    end
  end

  def final_status
    players.each do |player|
      puts "#{player.name}: #{record(player)}"
    end
  end

  def winner
    (player, _) = @losses.find { |_, loss| loss < MAX_COUNT }
    puts "#{player} won"
  end
end

if __FILE__ == $PROGRAM_NAME
  player1 = Player.new("human1")
  player2 = Player.new("human2")
  player3 = Player.new("human3")
  Game.new(player1, player2, player3).run
end
