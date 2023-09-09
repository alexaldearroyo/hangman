require "securerandom"
require "json"

def load_words
  words = []

  File.open("list.txt", "r").each_line do |line|
    word = line.chomp
    if word.length >= 5 && word.length <= 12
      words.push(word)
    end
  end

  words.sample
end

def display_word(secret_word, guessed_letters)
  secret_word.chars.map { |letter| guessed_letters.include?(letter) ? letter : "_" }.join(" ")
end

def save_game(secret_word, guessed_letters, attempts_left)
  data = {
    secret_word: secret_word,
    guessed_letters: guessed_letters,
    attempts_left: attempts_left,
  }

  File.open("saved_game.json", "w") do |file|
    file.write(data.to_json)
  end
  puts "Game saved!"
end

def load_game
  data = JSON.parse(File.read("saved_game.json"))
  [data["secret_word"], data["guessed_letters"], data["attempts_left"]]
end

def play_game(secret_word, guessed_letters = [], attempts_left = 8)
  wrong_letters = guessed_letters.select { |letter| !secret_word.include?(letter) }

  while attempts_left > 0
    puts display_word(secret_word, guessed_letters)
    puts "Wrong guesses: #{wrong_letters.join(", ")}" unless wrong_letters.empty?
    puts "Attempts left: #{attempts_left}"
    puts "Guess a letter or type 'save' to save the game:"
    guess = gets.chomp.downcase

    if guess == "save"
      save_game(secret_word, guessed_letters, attempts_left)
      return
    end

    if guessed_letters.include?(guess)
      puts "You've already guessed that letter. Try again!"
    elsif secret_word.include?(guess)
      guessed_letters << guess
      puts "Good guess!"
    else
      puts "Oops! That letter isn't in the word."
      attempts_left -= 1
      wrong_letters << guess
    end

    if secret_word.chars.all? { |letter| guessed_letters.include?(letter) }
      puts "Congratulations! You've guessed the word: #{secret_word}"
      return
    end
  end

  puts "Sorry, you're out of attempts! The word was: #{secret_word}"
end

puts "Do you want to load a saved game? (yes/no)"
choice = gets.chomp.downcase

if choice == "yes" && File.exist?("saved_game.json")
  secret_word, guessed_letters, attempts_left = load_game
else
  secret_word = load_words
  guessed_letters = []
  attempts_left = 8
end

play_game(secret_word, guessed_letters, attempts_left)
