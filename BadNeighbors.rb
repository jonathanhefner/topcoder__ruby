# PROBLEM:
#   There is a small town with a well. Each resident in the town hates his 
#   next-door neighbors. Nobody in the town is willing to live farther away 
#   from the well than his neighbors though, so all the houses are arranged 
#   in a big circle around the well. 
#   
#   Over time the well falls into disrepair and needs to be fixed. Donations 
#   must be collected to fund the repairs, but no resident wants to donate 
#   to a collection that his next-door neighbor has donated to. 
#   
#   You will be given a int[] `donations` which lists the amount each 
#   resident is potentially willing to donate, going in clockwise order 
#   around the well (note that the first and last residents represented in 
#   this list are also neighbors). You will return the maximum possible 
#   collected amount. 
#
# CONSTRAINTS:
#   - `donations`:
#     - will contain between 2 and 40 elements (inclusive)
#   - each element in `donations`:
#     - will be between 1 and 1000 (inclusive)
#
# Original at http://community.topcoder.com/stat?c=problem_statement&pm=2402&rd=5009


def max_donations(donations)
  return donations.max if donations.count <= 3 # optimization
  
  # This is a dynamic programming problem with a small catch: progression from 
  # state to state (going from to neighbor to neighbor to collect donations) 
  # can be circular. To break that circle, we explicitly handle the 2 cases of 
  # including or excluding the first resident from the collection; then we can 
  # follow a top-down approach and recurse over the remaining residents in a 
  # typical fashion. Note that we maintain 2 memoization arrays because in the 
  # case including the first resident, we must exclude the last resident, 
  # altering the subproblem. (Alternatively we could maintain a single 2-d 
  # memoization array parameterized by a "upto index", but there's not much 
  # benefit in doing so.)
  memo_exc_first = [nil] * donations.count
  memo_inc_first = [nil] * donations.count

  # Overall complexity cost is roughly (2n), in contrast to a brute-force 
  # solution which would cost something like O(2^n).
  [max_donations_rec(donations, donations.count, memo_exc_first, 1),
    donations[0] + max_donations_rec(donations, donations.count - 1, memo_inc_first, 2)].max
end


def max_donations_rec(donations, donations_count, memo, i)
  if i >= donations_count
    0
  else
    # The recursion here is straightforward: find the maximum donation possible 
    # by either excluding the i-th resident (allowing inclusion of the (i+1)th 
    # and remaining residents), or including the i-th resident (requiring 
    # exclusion of the (i+1)th resident).
    memo[i] ||= [max_donations_rec(donations, donations_count, memo, i + 1), 
                  donations[i] + max_donations_rec(donations, donations_count, memo, i + 2)].max
  end
end
