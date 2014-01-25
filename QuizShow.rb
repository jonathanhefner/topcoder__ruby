# PROBLEM:
#   You are on a TV quiz show. You and your 2 opponents have each 
#   accumulated points, and now, at the end of the game, you are all given 
#   one final question. Before hearing the question, each contestant must 
#   decide how many points he wants to wager. Each contestant who answers 
#   the question correctly will gain points equal to his wager, while each 
#   contestant who answers incorrectly will lose points equal to his wager. 
#   The contestant who has the most points after the final question wins the 
#   game. 
# 
#   You must select your wager. You can choose any amount between zero and 
#   your current score, inclusive. Given your current score, your opponents' 
#   scores, and how much you think each opponent will wager, compute how 
#   much you should wager to ensure the highest probability of winning the 
#   game uncontested (i.e. not ending in a tie). Assume you and your 
#   opponents each independently have a 50% chance of answering the final 
#   question correctly. 
# 
#   You will be given an int[] `scores` containing your score followed by 
#   your 2 opponents' scores (in order). You will also be given an int 
#   `wager1`, the amount of the first opponent's wager, and an int `wager2`, 
#   the amount of your second opponent's wager. If there are multiple wagers 
#   that would give you the same highest probability of winning, return the 
#   smallest such wager. If you have no chance of winning, return zero. 
#
# CONSTRAINTS:
#   - `scores`:
#     - will contain exactly 3 elements
#   - each element of `scores`:
#     - will be between 0 and 10000 (inclusive)
#   - `wager1`:
#     - will be between 0 and `scores[1]` (inclusive)
#   - `wager2`:
#     - will be between 0 and `scores[2]` (inclusive)
#
# Original at http://community.topcoder.com/stat?c=problem_statement&pm=2989&rd=5869


def wager(scores, wager1, wager2)
  # reshape the data so it's easier to work with (and more general)
  wager_generalized(scores[0], scores[1..-1], [wager1, wager2])
end

def wager_generalized(score, opp_scores, opp_wagers)
  # First we need to determine all the scenarios we'll have to contend with, 
  # with respect to our opponents. That is, for all possible combinations of 
  # our opponents each answering correctly or incorrectly, what final scores do 
  # we have to beat. Note that because each of our opponents has a 50% chance 
  # to answer correctly, each of the scenarios is equally likely. If this was 
  # not the case, we'd have to track the probability of each scenario as well, 
  # to factor that into our final answer. For n opponents, these computations 
  # have complexity (2^n * n).
  to_beat = [-1, 1].repeated_permutation(opp_wagers.count).map do |corrects|
    corrects.each_with_index.map{|c, i| opp_scores[i] + (c * opp_wagers[i]) }.max
  end
  
  # Now, we could loop over all possible wagers (0 through `score`) and keep 
  # track of which one wins the most, but since we only care about out-scoring 
  # the highest-scoring opponent, that's overkill (at least for a small n and a 
  # potentially large `score`). Instead, for each scenario to beat, we compute 
  # a winning wager. Then, we tally how well said wager does in all known 
  # scenarios. Again, if we or our opponents did not have a 50% chance to 
  # answer correctly, we'd have to factor that into how likely a win would be 
  # for any winning wager. For n opponents, these computations have complexity 
  # at most (2^n * 2^n).
  best_wager = 0
  best_wins = 0
  
  to_beat.each do |beat|
    wager = (beat + 1) - score
    next if wager > score # we can't win
    wager = 0 if wager < 0 # we've already won
    wins = 0
    to_beat.each do |b|
      wins += 1 if (score + wager) > b
      wins += 1 if (score - wager) > b
    end
    if wins >= best_wins
      best_wager = wins > best_wins ? wager : [best_wager, wager].min # minimize wager
      best_wins = wins
    end
  end
  
  best_wager
end
