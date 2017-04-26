# Quiz Show (SRM 223, Division 1, Level 1)
# https://community.topcoder.com/stat?c=problem_statement&pm=2989&rd=5869
#
# You are on a TV quiz show.  You and your two opponents have each
# accumulated points, and now, at the end of the game, you are all given
# one final question.  Before hearing the question, each contestant must
# decide how many points he wants to wager.  Each contestant who answers
# the question correctly will gain points equal to his wager, while each
# contestant who answers incorrectly will lose points equal to his
# wager.  The contestant who has the most points after the final
# question wins the game.
#
# You must select your wager.  You can choose any amount between zero
# and your current score, inclusive.  Given your current score, your
# opponents' scores, and how much you think each opponent will wager,
# compute how much you should wager to ensure the highest probability of
# winning the game uncontested (i.e. not ending in a tie).  Assume you
# and your opponents each independently have a 50% chance of answering
# the final question correctly.
#
# You will be given an int[] `scores` containing your score followed by
# your 2 opponents' scores (in order).  You will also be given an int
# `wager1`, the amount of the first opponent's wager, and an int
# `wager2`, the amount of your second opponent's wager.  If there are
# multiple wagers that would give you the same highest probability of
# winning, return the smallest such wager.  If you have no chance of
# winning, return zero.
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
# (Visit the URL above for original problem specification.)

QuizShow = Module.new

def QuizShow.solve(scores, wager1, wager2)
  # reshape the data so it's easier to work with
  score = scores[0]
  opp_scores = scores[1..-1]
  opp_wagers = [wager1, wager2]

  # First we need to determine all the scenarios we'll have to contend
  # with, with respect to our opponents.  That is, for all possible
  # combinations of each opponent each answering correctly or
  # incorrectly, determine what final score we have to beat.  Note that
  # because each of our opponents have a 50% chance to answer correctly,
  # each of the scenarios is equally likely.  If this was not the case,
  # we would have to track the probability of each scenario as well, to
  # factor that into our final answer.  For n opponents, this step has
  # O(n * 2^n) complexity.
  to_beat = [-1, 1].repeated_permutation(opp_wagers.length).map do |corrects|
    corrects.zip(opp_wagers, opp_scores).map{|c, w, s| c * w + s }.max
  end

  # Now that we know what score we need to beat in each scenario, we
  # compute a winning wager for each scenario.  Then, we find which
  # wager does best over all known scenarios.  Again, if we or our
  # opponents did not have a 50% chance to answer correctly, we'd have
  # to factor that into how likely a win would be for any winning wager.
  # For n opponents, this step has O(2^2n) complexity.
  winning_wagers = to_beat.map{|b| [b + 1 - score, 0].max }
  best_wager = winning_wagers.max_by do |w|
    next -1 if w > score # we can't win
    wins = to_beat.count{|b| (score + w) > b } + to_beat.count{|b| (score - w) > b }
    (wins * 100_000) + (10_000 - w) # minimum wager tie-breaker
  end
  best_wager > score ? 0 : best_wager
end
