# Bridge Crossing (SRM 146, Division 2, Level 3)
# https://community.topcoder.com/stat?c=problem_statement&pm=1599&rd=4535
#
# A number of people are crossing an old bridge.  The bridge cannot hold
# more than two people at once.  It is dark, so they can't walk without
# a flashlight, and they only have one flashlight.  It's not possible to
# toss the flashlight across the bridge, so one person always has to go
# back to bring the flashlight to the others.  Furthermore, each person
# walks at a different pace, and when people walk together, they always
# walk at the speed of the slowest person.  What is the minimum amount
# of time needed to get all the people across the bridge?
#
# You will be given an int[] `times`, where the elements represent the
# time each person needs to cross the bridge.  Your program should
# return the minimum possible amount of time spent getting everyone to
# the other side of the bridge.
#
# CONSTRAINTS:
#   - `times`:
#     - will have between 1 and 6 elements (inclusive)
#   -	each element of `times`:
#     - will be between 1 and 100 (inclusive)
#
# (Visit the URL above for original problem specification.)

BridgeCrossing = Module.new

def BridgeCrossing.solve(times)
  # I remember working on a problem like this during an ACM ICPC
  # practice session.  At the time, I attempted to solve it with a
  # mathematical formula, but when the formula didn't cover all cases I
  # fell back to brute force.  Now, years later, I can put more time and
  # thought into it.  For completeness though, and to verify the results
  # of the formula, I've included a brute force solution further down.

  # There are two crucial observations to make.  First, whenever we send
  # a person back across the bridge to return the flashlight, it's
  # always optimal to choose the fastest person available, because they
  # will be crossing the bridge an extra two times.  Second, as long as
  # there is a fast person on the far side of the bridge to carry the
  # flashlight back, it's optimal to batch slow crossers together, to
  # minimize their impact on total time (e.g. if one person requires 100
  # units of time to cross and another requires 99, crossing together
  # means only paying 100 once and getting 99 for free).

  # In a (non-brute-force) simulation algorithm, these two observations
  # could be expressed as steps in a loop:
  #
  #   While not everyone has crossed
  #     Send two fastest across (and exit if we're done)
  #     Send fastest back with flashlight
  #     Send two slowest across (and exit if we're done)
  #     Send fastest (i.e. 2nd fastest from step 1) back with flashlight
  #
  # But, looking at these steps, we observe that we don't need to
  # actually move the two fastest crossers between groups, because at
  # the end of the loop, barring exit conditions, they just end up back
  # in the first group.  All we need to do is account for their total
  # crossing time -- once together, then once each separately.  This
  # crossing time, which we'll refer to as fencepost time, has to be
  # paid in-between steps of sending the two slowest remaining people
  # across, until the two fastest people themselves become the two
  # slowest remaining.

  # For an even number of people this resolves nicely.  For an odd
  # number of people we have to do something extra.  Consider the case
  # of three people left to cross: the 2nd fastest and the 2nd slowest
  # is the same person.  It also doesn't matter if the fastest + slowest
  # persons cross before or after the fastest + 2nd fastest / slowest
  # persons; the number of steps and total cost will be the same.  Thus
  # when we have three people left to cross, the cost is the slowest,
  # plus the fastest (to return the flashlight), plus the 2nd fastest.

  n = times.length
  return times.max if n <= 2

  # Sort the times in reverse order, so the slowest people are first.
  times = times.sort.reverse!

  # Compute the fencepost time from the two fastest people (once
  # together + once each separately).
  fencepost = times[-2] + times[-1] + times[-2]

  # Sum the slowest of each pair of people...
  (0...n).select(&:even?).map{|i| times[i] }.reduce(&:+) +
    # Add in the fencepost times...
    fencepost * (n / 2 - 1) +
    # Add the 2nd fastest for the final step, if necessary...
    (n.odd? ? times[-2] : 0)
end



##### Brute force solution, for comparison #####

def BridgeCrossing.brute_solve(times)
  brute_solve_rec(times, [false] * times.length, 0)
end

def BridgeCrossing.brute_solve_rec(times, crossed, total_time)
  # We need to alternate between sending two people across and sending
  # one person back across to return the flashlight.  When sending one
  # person back across, it's always optimal to choose the fastest
  # person.  Thus we recursively choose 2+1 until all people have
  # crossed the bridge.

  # Our base case.  Before each recursive call, we ensure the flashlight
  # is back on the starting side.  Thus, if there are two or less people
  # who haven't crossed, just send them across (at the slowest pace
  # amongst them), and we are done.
  if crossed.count(false) <= 2
    total_time + times.each_with_index.map{|t, i| crossed[i] ? 0 : t }.max

  # Otherwise try all combinations of 2 crossers + 1 flashlight carrier,
  # and recurse for each.  Note that combination order doesn't matter
  # (i.e. [i,j] == [j,i]), so we start the inner loop at i + 1 to save
  # computations.
  else
    min = 1 << (1.size * 8 - 2) - 1 # 32-bit Fixnum max

    for i in 0...times.length
      next if crossed[i]
      for j in (i + 1)...times.length
        next if crossed[j]

        # two people cross
        crossed[i], crossed[j] = true, true
        ij_time = times[i] > times[j] ? times[i] : times[j]

        # fastest person carries flashlight back
        f = i
        for k in 0...times.length
          f = k if crossed[k] && times[k] < times[f]
        end
        f_crossed, crossed[f] = crossed[f], false

        # recursively repeat
        t = brute_solve_rec(times, crossed, total_time + ij_time + times[f])
        min = t < min ? t : min

        # undo for next iteration (note the order, because f can be i or j)
        crossed[f], crossed[i], crossed[j] = f_crossed, false, false
      end
    end

    min
  end
end



##### BONUS Story about algorithmic complexity #####
#
# The algorithmic complexity on this brute force approach is pretty
# crazy.  Something on the order of (n! * (n - 1)!).  We can see the
# cause of this is the nested loops.  First, we choose 1 of n people,
# then we choose 1 of (n - 1) people, BUT then we add 1 person back to
# our original pool and recurse until we only have 2 people left.
# (Since we always choose the fastest person to add back, we're not
# factoring that into our complexity analysis, but there's still a cost
# there too, based on which data structure.)  As an example, with n = 5,
# our costs look something like:
#
#   (5 * 4) * (4 * 3) * (3 * 2)
#     == (5 * 4 * 3) * (4 * 3 * 2)
#     == 5!/2 * 4!
#     == 5! * 4! / 2
#
# So I put in a counter to check the numbers, but I found that the
# number of cases tried were much fewer than this first estimation (i.e.
# it was not a very tight upper bound).  So I scribbled down a branching
# tree and, after a bit of confusion, found that it was my own
# optimization of choosing j > i that was causing the discrepancy.  For
# each recursion where there were k people remaining to cross, there are
# only ((k - 1) + (k - 2) + (k - 3) + (k - 4) + ... + 1) ==
# ((k-1) * (k-1 + 1)/2) total sub-solutions tried.  For n = 5, this
# looks something like:
#
#   (4 * (4 + 1)/2) * (3 * (3 + 1)/2) * (2 * (2 + 1)/2)
#     == (4 * 3 * 2) * (5 * 4 * 3) / (2 * 2 * 2)
#     == 4! * 5!/2 / 2^3
#     == 5! * 4! / 2^4
#
# Still, (n! * (n - 1)! / 2^(n - 1)) complexity is a far cry from the
# (n * log2(n) + n) complexity offered by the formula-based algorithm.
# And though it's easy to plug in values for n and see the difference,
# a concrete example conveys it so much better: using a measly value of
# n = 9, the brute force algorithm took 16m42s to complete.  That's
# roughly 1000 seconds.  In comparison, to cause the formula-based
# algorithm take even 1 second to complete, I needed to increase n to
# 1,000,000.
