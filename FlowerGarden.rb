# PROBLEM:
#   You are planting a row of flowers of varying heights. You want the 
#   taller flowers towards the front of the row, but you can't have them 
#   blocking the view of the shorter flowers. Fortunately, some flowers are 
#   in bloom for only part of the year, and if two flowers are never in 
#   bloom at the same time, you can plant the taller of the two closer to 
#   the front. Those flowers that do overlap in their bloom durations 
#   though, even if by a single day, must be planted in order of increasing 
#   height. Additionally, each of the flowers has a unique height, so there 
#   will always be a single optimum arrangement (a well-defined ordering). 
#   
#   You will be given a int[] `height`, a int[] `bloom`, and a int[] `wilt`, 
#   where the data for the i-th flower is the i-th elements of each array. 
#   `height[i]` specifies how tall the i-th flower is; `bloom[i]` specifies 
#   the day of the year it goes into bloom; and `wilt[i]` specifies the day 
#   of the year it wilts. The range specified by `bloom[i]` to `wilt[i]` is 
#   inclusive (i.e. flowers bloom in the morning and wilt in the evening). 
#   
#   You will return a int[] which contains the elements of `height` in the 
#   order which the flowers should be planted, starting at the front the 
#   row. 
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
# Original at http://community.topcoder.com/stat?c=problem_statement&pm=1918&rd=5006
# Clarification at http://community.topcoder.com/tc?module=Static&d1=match_editorials&d2=tccc04_online_rd_1


def get_ordering(height, bloom, wilt)
  # Two things made this problem difficult for me:
  # First, there's some ambiguity in the original problem statement (which I've 
  # retained in my paraphrase, to a degree). Consider the case where you have 2 
  # or more flowers solidly in bloom for each season of the year. You can 
  # properly order the flowers within each season, but, essentially, how should 
  # you order the seasons? (What if one season has the tallest flower, but also 
  # all of the shortest flowers?) The clarification at the URL above suggests 
  # we iteratively take the tallest flower and put it as far to the front as 
  # possible.
  # Second, I found this problem while searching for some dynamic programming 
  # practice, and though it's labeled as such, it doesn't appear to be a DP
  # problem. In fact, I spent quite a bit of time trying to orient the problem 
  # to yield an optimal substructure, but didn't come up with anything that 
  # wasn't convoluted. If you, dear reader, can discern a good DP solution, 
  # please let me know!
  
  # For our solution, the first thing we do for each flower is build up a count 
  # of the number of flowers that are *allowed* to be planted behind it, and a 
  # list of which flowers are *allowed* to be planted before it (starting at 
  # the front of the row).  The complexity cost for this step is O(n^2).
  successor_count = [0] * height.count
  predecessor_list = (0...height.count).map{|i| [] }
  for i in 0...height.count
    for j in 0...height.count
      next if i == j

      # if i is shorter than j, or the 2 are not in bloom at the same time...
      if height[i] < height[j] || (wilt[i] < bloom[j] || wilt[j] < bloom[i])
        successor_count[i] += 1
        predecessor_list[j] << i
      end
    end
  end
  
  # Next, we use those counts to determine which flowers to plant first at the 
  # front of the row. We iteratively choose the flower with the greatest 
  # successor count until we have planted all the flowers. Because there's a 
  # well-defined ordering, if 2 or more flowers have the same successor count, 
  # they must be including each other in that count, and thus must bloom 
  # independently. In such a case, we choose the tallest flower first. As we 
  # plant flowers, we remove the just-planted flower from availability, using 
  # the predecessor lists to appropriately decrement successor counts. This 
  # just makes it easier to track which flowers to consider next. The 
  # complexity cost for this step is also O(n^2).
  ordering = []
  best_i = 0
  while ordering.count < height.count
    for i in 0...height.count
      if successor_count[i] > successor_count[best_i] || 
          (successor_count[i] == successor_count[best_i] && height[i] > height[best_i])
        best_i = i
      end
    end
  
    ordering << height[best_i]
    successor_count[best_i] = -1
    predecessor_list[best_i].each{|j| successor_count[j] -= 1 }
  end

  # Overall complexity cost is O(n^2), whereas a brute-force solution would 
  # likely cost O(n!).
  ordering
end
