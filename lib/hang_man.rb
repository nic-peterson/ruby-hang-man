class Word
  FILE_PATH = "words.txt"
  attr_reader :word

  def initialize
    @words = generate_words_array
    @word = @words.sample
  end

  def generate_words_array
    lines = File.readlines(FILE_PATH)
    words = []
    lines.each do |line|
      word = line.chomp
      if (word.length > 4 && word.length < 13)
        words.push(word)
      end
    end
    return words
  end
end

word = Word.new
p word.word
