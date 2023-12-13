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

class Game
  NUMBER_OF_ATTEMPTS = 6

  def initialize
    @word = Word.new.word
    @current_state = "_" * @word.length
    @remaining_attempts = NUMBER_OF_ATTEMPTS
    @guess_array = []
  end

  def display_all
    puts @word
    puts @current_state
    puts @remaining_attempts
  end

  def display
    puts "Remaining attempts: #{@remaining_attempts}"
    puts "#{@current_state}"
    puts "Guesses: #{@guess_array.join(" ")}"
  end

  def play
    until (@remaining_attempts == 0)
      display
      guess = prompt_guess

      if @current_state == @word
        puts "Congratulations! You've guessed the word!"
        return
      else
        provide_feedback(guess)
      end
    end

    puts "\e[36mGame over! The secret word was: #{@word}\e[36m\e[0m"
  end

  private

  def prompt_guess
    loop do
      puts "Enter your guess: "
      guess = gets.chomp.downcase
      return guess if valid_guess?(guess)

      puts "Invalid guess. Please choose another letter."
    end
  end

  def valid_guess?(guess)
    guess.length == 1 && guess.match?(/\A[a-zA-Z]+\z/) && !@current_state.include?(guess) && !@guess_array.include?(guess)
  end

  def provide_feedback(guess)
    if @word.include?(guess)
      puts "\e[32m#{guess} is correct!\e[32m\e[0m"
      matching_indices = find_matching_indices(guess)
      update_current_state(guess, matching_indices)

    else
      puts "\e[31m#{guess} is *not* correct\e[31m\e[0m"
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
