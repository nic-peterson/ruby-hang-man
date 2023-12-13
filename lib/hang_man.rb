class Word
  FILE_PATH = "words.txt"
  attr_reader :word

  def initialize
    @words = generate_words_array
    @word = @words.sample
  end

  private

  def generate_words_array
    lines = File.readlines(FILE_PATH)
    words = []
    lines.each do |line|
      word = line.chomp
      if (word.length.between?(5, 12))
        words.push(word)
      end
    end
    return words
  end
end

module Display
  # Displays the current state of the game
  def show_current_state(current_state, remaining_attempts, guessed_letters)
    puts "Remaining attempts: #{remaining_attempts}"
    puts "Current word: #{current_state}"
    puts "Guessed letters: #{guessed_letters.join(" ")}"
  end

  # Displays a message when the player makes a correct guess
  def show_correct_guess_message(guess)
    puts "\e[32m#{guess} is correct!\e[32m\e[0m"
  end

  # Displays a message when the player makes an incorrect guess
  def show_incorrect_guess_message(guess)
    puts "\e[31m#{guess} is not correct\e[31m\e[0m"
  end

  # Displays a winning message when the player guesses the word
  def show_win_message(word)
    puts "\e[32mCongratulations! You've guessed the word: #{word}\e[32m\e[0m"
  end

  # Displays a losing message when the player runs out of attempts
  def show_lose_message(word)
    puts "\e[36mGame over! The secret word was: #{word}\e[36m\e[0m"
  end
end

module GameLogic
  NUMBER_OF_ATTEMPTS = 6
  # Initializes the game state
  def setup_game()
    @word = Word.new.word.downcase
    @current_state = "_" * @word.length
    @guessed_letters = []
    @remaining_attempts = NUMBER_OF_ATTEMPTS
  end

  # Checks if the given letter is in the word
  def check_guess(letter)
    if @word.include?(letter)
      update_current_state(letter)
      :correct
    else
      @remaining_attempts -= 1
      :incorrect
    end
  end

  # Updates the current state of the word
  def update_current_state(letter)
    @word.each_char.with_index do |char, index|
      @current_state[index] = letter if char == letter
    end
    @guessed_letters.push(letter) unless @guessed_letters.include?(letter)
  end

  # Checks if the game has been won
  def won?
    @current_state == @word
  end

  # Checks if the game has been lost
  def lost?
    @remaining_attempts <= 0
  end

  # Checks if the game is over
  def game_over?
    won? || lost?
  end
end

class InputHandler
  # Prompts the user for a guess and returns the validated guess
  def get_user_guess(guessed_letters)
    loop do
      puts "Enter your guess (a single letter): "
      guess = gets.chomp.downcase

      return guess if valid_guess?(guess, guessed_letters)

      puts "Invalid guess. Please choose a single letter."
    end
  end

  private

  # Validates the user's guess
  def valid_guess?(guess, guessed_letters)
    guess.length == 1 && guess.match?(/[a-zA-Z]/) && !guessed_letters.include?(guess)
  end
end

class Game
  include GameLogic
  include Display

  def initialize
    setup_game() # Method from GameLogic module
    @input_handler = InputHandler.new
  end

  def play
    until game_over?
      show_current_state(@current_state, @remaining_attempts, @guessed_letters)
      puts "Enter 'save' to save the game, or make your guess:"
      choice = gets.chomp.downcase

      if choice == 'save'
        save_game
        puts "Game saved!"
        return
      else
        result = check_guess(choice)
        handle_guess_result(result, choice)
      end
    end

    finalize_game
  end

  def save_game
    File.open('saved_game', 'wb') { |file| Marshal.dump(self, file) }
  end

  def self.load_game
    File.open('saved_game', 'rb') { |file| Marshal.load(file) }
  end

  private

  def handle_guess_result(result, guess)
    case result
    when :correct
      show_correct_guess_message(guess) # Method from Display
    when :incorrect
      show_incorrect_guess_message(guess) # Method from Display
    end
  end

  def finalize_game
    if won? # Method from GameLogic
      show_win_message(@word) # Method from Display
    else
      show_lose_message(@word) # Method from Display
    end
  end
end

def start_game
  puts "Welcome to Hangman!"
  puts "1. Start New Game"
  puts "2. Load Saved Game"
  choice = gets.chomp

  game = if choice == '2' && File.exist?('saved_game')
           Game.load_game
         else
           Game.new
         end

  game.play
end

start_game
