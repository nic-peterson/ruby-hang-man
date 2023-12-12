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
      if (word.length.between?(5, 12)) # > 4 && word.length < 13)
        words.push(word)
      end
    end
    return words
  end
end

# word = Word.new.word
# p word

class Game
  NUMBER_OF_ATTEMPTS = 6

  def initialize
    @word = Word.new.word
    @current_state = "_" * @word.length
    @remaining_attempts = NUMBER_OF_ATTEMPTS
  end

  def display_all
    puts @word
    puts @current_state
    puts @remaining_attempts
  end

  def display
    puts "Remaining attempts: #{@remaining_attempts}"
    puts "#{@current_state}"
  end

  def play
    until (@remaining_attempts == 0)
      puts "play"
      display
      guess = prompt_guess
      @remaining_attempts -= 1
      if @current_state == @word
        puts "Congratulations! You've guessed the word!"
        return
      else
        provide_feedback(guess)
      end
    end

    puts "Game over! The secret word was: #{@word}"
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
    guess.length == 1 && guess.match?(/\A[a-zA-Z]+\z/) && !@current_state.include?(guess)
  end

  def provide_feedback(guess)
    puts "provide_feedback"
    if @word.include?(guess)
      puts "#{guess} is correct"
    else
      puts "#{guess} is *not* correct"
    end
  end
end

game = Game.new
game.play

# game.display_all
# game.display
