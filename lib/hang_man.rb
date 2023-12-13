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
  NUMBER_OF_ATTEMPTS = 6
  include Display

  def initialize
    @word = Word.new.word
    @current_state = "_" * @word.length
    @remaining_attempts = NUMBER_OF_ATTEMPTS
    @guess_array = []
    @input_handler = InputHandler.new
  end

  def play
    until (@remaining_attempts == 0)

      puts @word
      show_current_state(@current_state, @remaining_attempts, @guess_array)
      guess = @input_handler.get_user_guess(@guess_array)

      if @current_state == @word
        show_win_message(@word)
        return
      else
        provide_feedback(guess)
      end
    end

    show_lose_message(@word)
  end

  private

  def provide_feedback(guess)
    if @word.include?(guess)
      show_correct_guess_message(guess)
      matching_indices = find_matching_indices(guess)
      update_current_state(guess, matching_indices)

    else
      show_incorrect_guess_message(guess)
      @remaining_attempts -= 1
    end
    @guess_array.push(guess)
  end

  def find_matching_indices(guess)
    matching_indices = []

    @word.each_char.with_index do |char, index|
      matching_indices << index if char == guess
    end

    matching_indices
  end

  def update_current_state(guess, matching_indices)
    matching_indices.each do |index|
      @current_state[index] = guess
    end
  end
end

game = Game.new
game.play
