# Flower Garden (TCCC 2004, Division 1, Level 2)
# https://community.topcoder.com/stat?c=problem_statement&pm=1918&rd=5006
#
# You are planting a row of flowers of varying heights.  You want the
# taller flowers towards the front of the row, but you can't have them
# blocking the view of the shorter flowers.  Fortunately, some flowers
# are in bloom for only part of the year, and if two flowers are never
# in bloom at the same time, you can plant the taller of the two closer
# to the front.  Those flowers that do overlap in their bloom durations
# though, even if by a single day, must be planted in order of
# increasing height.  Additionally, each of the flowers has a unique
# height, so there will always be a single optimum arrangement (a
# well-defined ordering).
#
# You will be given an int[] `height`, an int[] `bloom`, and an int[]
# `wilt`, where the data for the i-th flower is the i-th elements of
# each array.  `height[i]` specifies how tall the i-th flower is;
# `bloom[i]` specifies the day of the year it goes into bloom; and
# `wilt[i]` specifies the day of the year it wilts.  The range specified
# by `bloom[i]` to `wilt[i]` is inclusive (i.e. flowers bloom in the
# morning and wilt in the evening).
#
# You will return a int[] which contains the elements of `height` in the
# order which the flowers should be planted, starting at the front the
# row.
#
# CONSTRAINTS:
#   - `height`:
#     - will have between 2 and 50 elements (inclusive)
#     - will have no repeated elements
#   - `bloom` and `wilt`:
#     - will have the same number of elements as `height`
#   - each element of `height`:
#     - will be between 1 and 1000 (inclusive)
#   - each element of `bloom`:
#     - will be between 1 and 365 (inclusive)
#   - each element of `wilt`:
#     - will be between 1 and 365 (inclusive)
#     - will be greater than its corresponding element in `bloom`
#
# (Visit the URL above for original problem specification.)

FlowerGarden = Module.new

def FlowerGarden.solve(height, bloom, wilt)
  # Two things made this problem difficult, personally speaking:
  #
  # First, there's ambiguity in the original problem statement (which
  # I've retained in my paraphrase, to a degree).  Consider the case
  # where we have two or more flowers solidly in bloom for each season
  # of the year.  We can properly order the flowers within each season,
  # but, essentially, how should we order the seasons?  (What if one
  # season has the tallest flower, but also all of the shortest
  # flowers?)  A clarification was later released which suggests we
  # iteratively take the tallest flower and put it as far to the front
  # as possible:
  # http://community.topcoder.com/tc?module=Static&d1=match_editorials&d2=tccc04_online_rd_1
  #
  # Second, this problem is categorized as a dynamic programming
  # practice problem, but it doesn't appear to be a DP-related.  In
  # fact, I spent quite a bit of time trying to orient the problem to
  # yield a substructure, but could not come up with anything that
  # wasn't convoluted.  If you, dear reader, can discern a good DP
  # solution, please let me know!  As it is, the complexity of this
  # algorithm is O(n^2), whereas a brute-force solution would likely be
  # O(n!).

  # The first thing we do is, for each flower, count the number of
  # flowers that are *allowed* to be planted behind it, and build a list
  # of flowers which are *allowed* to be planted before it (starting at
  # the front of the row).
  behind_counts = [0] * height.length
  before_lists = Array.new(height.length){ [] }

  height.length.times do |i|
    height.length.times do |j|
      # if i shorter than j or the two aren't in bloom at the same time...
      if height[i] < height[j] || wilt[i] < bloom[j] || wilt[j] < bloom[i]
        behind_counts[i] += 1
        before_lists[j] << i
      end
    end
  end

  # Next, we use those counts to determine which flowers to plant first
  # at the front of the row.  We iteratively choose the flower with the
  # greatest number of possible flowers behind it until we have planted
  # all the flowers.  Because there is a guaranteed well-defined
  # ordering, if two or more flowers have this same count, they must be
  # including each other in that count, and thus must bloom
  # independently.  In such a case, we use height as the tie-breaker,
  # choosing the tallest flower first.  As we choose flowers, we remove
  # the just-chosen flower from availability.
  height.map do
    i = (0...height.length).max_by{|i| behind_counts[i] * 10000 + height[i] }

    behind_counts[i] = -1
    before_lists[i].each{|before| behind_counts[before] -= 1 }

    height[i]
  end
end
