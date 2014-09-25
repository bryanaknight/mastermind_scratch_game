require 'pry'
require 'Time'

class Game
  attr_reader :correct_position, :correct_color, :num_guesses, :printer
  attr_accessor :secret_code, :command

  def initialize(printer = MessagePrinter.new)
    @start_time = Time.new
    @correct_position = 0
    @correct_color = 0
    @num_guesses = 0
    @printer = printer
    @command = ""
    @secret_code = ""
    generate_random_code
  end

  def play
    printer.take_a_guess
    @command = gets.strip
    process_game_turn
  end

  def process_game_turn
    puts "secret code: #{@secret_code}"
    exit_game
    until exit?
      case
      when exit?
	exit
      when too_short?
	printer.too_short
	@command = gets.strip
      when too_long?
	printer.too_long
	@command = gets.strip
      when win?
	correct_guess
	printer.you_win(@secret_code, @num_guesses, @time_minutes, @time_seconds)
	@command = gets.strip
	Mastermind.new.process_initial_commands
      when incorrect_guess?
        @num_guesses += 1
	guess_checker
        printer.guess_results(@command, number_of_correct_elements, @correct_position, @num_guesses)
        @command = gets.strip
      end
    end
  end

  def guess_checker
    @count = 0
    @correct_position = 0
    @temp_secret_code = @secret_code.dup
    @command.each_char do |c|
      if c == @temp_secret_code[@count]
	@correct_position += 1
      end
      @count += 1
    end
  end

  def number_of_correct_elements
    common = @secret_code.split("") & @command.split("")
    common.count
  end

  def generate_random_code
    @secret_code = ["r","g","b","y"].sample(4).join
  end

  def win?
    command == secret_code
  end

  def exit?
    command.downcase == "q" || command.downcase == "quit"
  end

  def exit_game
    if exit?
      puts "Goodbye!"
      exit
    end
  end

  def too_short?
    command.length < 4 && ( command.downcase != "q" || command.downcase != "quit" )
  end

  def too_long?
    command.length > 4
  end

  def play?
    command.downcase == "p" || command.downcase == "play"
  end

  def incorrect_guess?
    command.length == 4 && command != secret_code
  end

  def correct_guess
    @end_time = Time.new
    @time_length = ( @end_time - @start_time ).to_i
    @time_minutes = ( @time_length / 60 )
    @time_seconds = ( @time_length % 60 )
  end

end
