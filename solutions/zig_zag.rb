# Zig Zag (TCCC 2003, Division 1, Level 1)
# https://community.topcoder.com/stat?c=problem_statement&pm=1259&rd=4493
#
# A zig-zag sequence is a sequence of numbers where the differences
# between successive numbers strictly alternate between positive and
# negative.  The first difference may be either positive or negative.
# As a base case, a sequence of only one number qualifies as a zig-zag
# sequence of length one.  For example, [1,7,4,9,2,5] is a zig-zag
# sequence because its differences [6,-3,5,-7,3] strictly alternate
# between positive and negative.  However, [1,4,7,2,5] is not zig-zag
# sequence, because its first two differences are positive.  Likewise,
# [1,7,4,5,5] is not a zig-zag sequence because its last difference is
# zero.
#
# A subsequence is a series of number obtained by removing zero or more
# elements from an original sequence of numbers, leaving the remaining
# elements in their original order.  For example, [1,3,4] is a
# subsequence of [1,2,3,4,5], however [3,1,4] is not.
#
# You will be given a int[] `sequence` that specifies a sequence of
# numbers.  Return the length of the longest zig-zag subsequence of
# `sequence`.
#
# CONSTRAINTS:
#   - `sequence`:
#     - will contain between 1 and 50 elements (inclusive)
#   - each element of `sequence`:
#     - will be between 1 and 1000 (inclusive)
#
# (Visit the URL above for original problem specification.)

ZigZag = Module.new

def ZigZag.solve(sequence)
  # This is a mostly straight-forward dynamic programming problem.  The
  # only twist here is that we keep two state arrays: one for zig-zag
  # subsequences that end in a positive difference, and the other for
  # those that end in a negative difference.  Both state arrays contain,
  # for each i, the length of the longest zig-zag subsequence that ends
  # with element i.  We take the bottom-up approach, using a nested loop
  # to build up the subsequences.  Algorithmic complexity is O(n^2), in
  # contrast to a brute-force solution which would likely be O(2^n).
  endPositive = [1] * sequence.length
  endNegative = [1] * sequence.length

  sequence.length.times do |i|
    i.times do |j|
      if sequence[i] > sequence[j]
        # consider longest subsequence ending negatively at j which
        # could now extend to end positively at i
        endPositive[i] = [endPositive[i], endNegative[j] + 1].max
      elsif sequence[i] < sequence[j]
        # consider longest subsequence ending positively at j which
        # could now extend to end negatively at i
        endNegative[i] = [endNegative[i], endPositive[j] + 1].max
      end
    end
  end

  [endPositive.max, endNegative.max].max
end
