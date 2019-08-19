require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grids = ('a'..'z').to_a.sample(10)
  end

  def score
    @attempt = params[:word]
    @grids   = params[:hidden_grid].split
    @result  = params[:result]
    @score   = 0
    run_game(@attempt, @grids)
    session[:score] = @score
    @total_score = session[:score]
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def score_and_message(attempt, grid)
    if included?(attempt, grid)
      if english_word?(attempt)
        @score += attempt.size
        [@score.to_s, "#{attempt} is an valid English word!"]
      else
        [0, "Sorry! but #{attempt} it is not an English word."]
      end
    else
      [0, "Sorry! #{attempt} can't be build out of #{@grids.join(', ')}."]
    end
  end

  def run_game(attempt, grid)
    score_and_message = score_and_message(attempt, grid)
    @result = "#{score_and_message.first} marks. #{score_and_message.last}"
  end
end
