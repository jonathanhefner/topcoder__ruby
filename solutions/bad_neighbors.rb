# Bad Neighbors (TCCC 2004, Division 1, Level 1)
# https://community.topcoder.com/stat?c=problem_statement&pm=2402&rd=5009
#
# There is a small town with a well.  Each resident in the town hates
# his next-door neighbors.  Nobody in the town is willing to live
# farther away from the well than his neighbors though, so all the
# houses are arranged in a big circle around the well.
#
# Over time the well falls into disrepair and needs to be fixed.
# Donations must be collected to fund the repairs, but no resident wants
# to donate to a collection that his next-door neighbor has donated to.
#
# You will be given an int[] `donations` which lists the amount each
# resident is potentially willing to donate, going in clockwise order
# around the well (note that the first and last residents represented in
# this list are also neighbors).  You will return the maximum possible
# collected amount.
#
# CONSTRAINTS:
#   - `donations`:
#     - will contain between 2 and 40 elements (inclusive)
#   - each element in `donations`:
#     - will be between 1 and 1000 (inclusive)
#
# (Visit the URL above for original problem specification.)

BadNeighbors = Module.new

def BadNeighbors.solve(donations)
  # This is a dynamic programming problem with a small catch:
  # progression from state to state (going from to neighbor to neighbor
  # to collect donations) can be circular.  To break that circle, we
  # explicitly handle the two cases of including or excluding the first
  # resident from the collection.  Then we can follow a top-down
  # approach and recurse over the remaining residents in a typical
  # fashion.  Algorithmic complexity is O(n) (roughly (2n)), in contrast
  # to a brute-force solution which would be something like O(2^n).

  return donations.max if donations.length <= 3 # optimization

  # We maintain two memoization arrays because in the case of including
  # the first resident, we must exclude the last resident, which alters
  # the subproblem.
  exclude_first = [nil] * donations.length
  include_first = [nil] * donations.length

  [ solve_rec(donations, exclude_first, 1),
    donations[0] + solve_rec(donations[0...-1], include_first, 2)
  ].max
end

def BadNeighbors.solve_rec(donations, memo, i)
  # The recursion here is straightforward: find the maximum donation
  # possible by either excluding the i-th resident (allowing inclusion
  # of the (i+1)th and remaining residents), or including the i-th
  # resident (requiring exclusion of the (i+1)th resident).
  if i >= donations.length
    0
  else
    memo[i] ||= [
      solve_rec(donations, memo, i + 1),
      donations[i] + solve_rec(donations, memo, i + 2)
    ].max
  end
end
