# Smart Word Toy (SRM 233, Division 1, Level 2)
# https://community.topcoder.com/stat?c=problem_statement&pm=3935&rd=6532
#
# There is a word toy that displays four letters at all times.  There
# are two buttons for each letter that cause the letter to change to the
# previous or next letter in alphabetical order.  So, with one click of
# a button the letter 'c' can be changed to 'b' or 'd'.  The alphabet is
# circular, so for example an 'a' can become a 'z' or a 'b' with one
# click.
#
# You are to determine if, using these mechanics, a starting word can
# transformed into a goal word.  However, there are forbidden words that
# can never be displayed by the toy.  These forbidden words are
# determined by one or more constraint strings, each in the form of
# "X X X X" where each X is a sequence of lowercase letters.  A word is
# forbidden if the i-th letter of the word is contained in the i-th X of
# a contraint string.  For example, the constraint "lf a tc e" forbids
# the words "late", "fate", "lace", and "face".
#
# You will be given a string `start`, a string `finish`, and a string[]
# `forbid`.  Return the minimum number of button clicks required to
# display `finish` if the toy was originally displaying `start`.
# Remember, the toy must never show a forbidden word.  If it is
# impossible for the toy to ever show `finish`, return -1.
#
# CONSTRAINTS:
#   - `start`:
#     - will not be a forbidden word
#   - `start` and `finish`:
#     - will contain exactly 4 characters
#     - will contain only lowercase letters
#   - `forbid`:
#     - will contain between 0 and 50 elements (inclusive)
#   - each element of `forbid`:
#     - will contain between 1 and 50 characters (inclusive)
#     - will have exactly three spaces
#     - will not contain leading, trailing or double spaces
#     - will contain only lowercase letters
#   - each letter within a group of letters in each element of `forbid`:
#     - will be distinct (thus "aa a a a" is not allowed)
#
# (Visit the URL above for original problem specification.)

module SmartWordToy
  DIGIT_COUNT = 4
  DIGIT_BASE = 26
  DIGIT_BITS = Math.log2(DIGIT_BASE).ceil
end

def SmartWordToy.solve(start, finish, forbid)
  # Think of the toy as a state machine with 4^26 == 456,976 states,
  # with some states forbidden.  Each state has up to 4*2 == 8 possible
  # transitions.  Each transition has a cost of 1 (click).  Thus we have
  # an undirected graph with uniform edge costs, and we want to find the
  # length of the shortest path between a start node and a finish node.
  # So we do a breadth-first search and keep track of the transitions we
  # take (kind of like Dijkstra's algorithm, but without the "relax"
  # step).
  #
  # Because of the regularity of the graph, we don't have to store the
  # nodes or edges explicitly.  Each node can be represented as a
  # base-26 4-digit integer, which can be packed into 5*4 bits.  The
  # neighbors of each node are easily computed by incrementing and
  # decrementing those 4 digits, and we can exclude forbidden states
  # lazily, right before adding them to the BFS queue.

  # First, we pack the start and finish states into our 20-bit
  # representation, for future comparison.
  packed_start = pack_bytes(start.bytes)
  packed_finish = pack_bytes(finish.bytes)

  # Next, we build a hash table of forbidden states.  This is necessary
  # because a linear search of `forbid` to check if a state is forbidden
  # can take upto (12 * 12 * 12 * 11 * 50) == 950,400 operations in the
  # worst case.  Our 20-bit state representation helps with limiting
  # this hash table to a reasonable size (a worst case of all states
  # forbidden costs roughly (26 * 26 * 26 * 26 * 4) == 1,827,904 bytes).
  forbidden = {}
  forbid.each do |rule|
    sets = rule.split(' ').map(&:bytes)
    sets[0].product(*sets[1..-1]) do |combin|
      forbidden[pack_bytes(combin)] = true
    end
  end

  # Now the heart of our algorithm: a breadth-first graph search which
  # keeps track of transitions.
  visited = {}
  previous = { packed_start => -1 }
  queue = Queue.new
  queue.enq(packed_start)

  until queue.empty?
    x = queue.deq()
    break if x == packed_finish
    next if visited[x]
    visited[x] = true

    each_neighbor(x) do |n|
      unless forbidden[n] || previous[n]
        previous[n] = x
        queue.enq(n)
      end
    end
  end

  # Finally, we backtrace the transitions to compute the number of
  # clicks.  Clever initialization of `clicks` covers the cases where
  # `start` == `finish` and where no solution is possible.
  clicks = -1
  x = packed_finish
  clicks += 1 while (x = previous[x])
  clicks
end

def SmartWordToy.pack_bytes(bytes)
  # We reverse the bytes because the first characters should be stored
  # in the lower-order bits.
  bytes.reverse.reduce(0) do |packed, byte|
    (packed << SmartWordToy::DIGIT_BITS) | (byte - 'a'.ord)
  end
end

def SmartWordToy.each_neighbor(packed)
  SmartWordToy::DIGIT_COUNT.times do |d|
    position = d * SmartWordToy::DIGIT_BITS
    mask = (2**SmartWordToy::DIGIT_BITS - 1) << position
    digit = (packed & mask) >> position
    [-1, 1].each do |adjust|
      adjusted_digit = (digit + adjust) % SmartWordToy::DIGIT_BASE
      neighbor = (packed & ~mask) | (adjusted_digit << position)
      yield neighbor
    end
  end
end
