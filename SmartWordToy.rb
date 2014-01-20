# PROBLEM:
#   There is a word toy that displays 4 letters at all times. There are 2 
#   buttons for each letter that cause the letter to change to the previous 
#   or next letter in alphabetical order. So, with one click of a button the 
#   letter 'c' can be changed to a 'b' or a 'd'. The alphabet is circular, 
#   so for example an 'a' can become a 'z' or a 'b' with one click. 
#   
#   You are to determine if, using these mechanics, a starting word can 
#   transformed into a goal word. However, there are forbidden words that 
#   can never be displayed by the toy. These forbidden words are determined 
#   by one or more constraint strings, each in the form of "X X X X" where 
#   each X is a sequence of lowercase letters. A word is forbidden if the 
#   ith letter of the word is contained in the ith X of a contraint string. 
#   For example, the constraint "lf a tc e" forbids the words "late", 
#   "fate", "lace" and "face". 
#   
#   You will be given a string `start`, a string `finish`, and a string[] 
#   `forbid`. Return the minimum number of button presses required to 
#   display `finish` if the toy was originally displaying `start`. Remember, 
#   the toy must never show a forbidden word. If it is impossible for the 
#   toy to ever show `finish`, return -1. 
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
# Original at http://community.topcoder.com/stat?c=problem_statement&pm=3935&rd=6532

DISPLAYS = (0...4).to_a
CLICKS = [1, -1]

def min_presses(start, finish, forbid)
  # Think of the toy as a state machine with 4^26 == 456,976 states. Some 
  # states are forbidden. Each state has upto 4*2 == 8 possible transitions, 
  # though some of those may be forbidden. Each transition has a cost of 1 
  # (click). Thus we have an undirected graph with uniform edge costs, and 
  # we want to find the length of the shortest path between a start node and 
  # a finish node.  So we do a breadth-first search and keep track of the paths 
  # we take (kind of like Dijkstra's algorithm, but without the "relax" step).
  
  # Because of the regularity of the graph, we don't have to store the nodes or 
  # edges explicitly.  Each node can be represented as a 4-digit integer 
  # (in base-26, though we'll use base-32 to make things easier), and its 
  # neighbors can be calculated.  We just need to exclude the forbidden states, 
  # which we'll do lazily, before adding them to the BFS queue.  We could keep 
  # track of which states are verified forbidden with something like a binary 
  # search tree, but instead we're going to make the `visited` flag tri-state 
  # (i.e. nil/false/true), with false meaning "not visited, but verified not 
  # forbidden" and true meaning "either visited or forbidden."  Note that since 
  # there is a maximum of 456,976 states we could trade memory for clock cycles 
  # by using a boolean-ish array for the visited/forbidden checks, but we're 
  # just going to use a hashtable.
  start_id = to_id(start)
  finish_id = to_id(finish)
  constraints = preprocess_constraints(forbid)
  visited = {}
  previous = {start_id => -1}
  queue = [start_id]
  
  # PERFORMANCE HACK: Ruby's Array#shift is *SLOW* because internally it does a 
  # memmove (at least 1.9.3), so instead of removing elements from the front of 
  # the queue, we allow the queue to expand up to its bounded maximum size, and 
  # keep an index of which element to process next.  For the worst-case BFS 
  # scenario (finish node was at max depth), this reduced run time from 4  
  # minutes to 5.5 sec.
  queue_i = 0
  
  while queue_i < queue.length
    id = queue[queue_i]; queue_i += 1 # queue.shift
    next if visited[id]
    break if id == finish_id
    visited[id] = true
    
    DISPLAYS.each do |digit|
      CLICKS.each do |increment|
        n = neighbor(id, digit, increment)
        visited[n] = check_forbidden(n, constraints) if visited[n].nil?
        unless visited[n] || previous[n]
          queue << n
          previous[n] = id
        end
      end
    end
  end
  
  # back trace to compute path length
  path_length = -1
  n = finish_id
  path_length += 1 while (n = previous[n])
  path_length
end


BASE = 26
CHAR_OFFSET = 'a'.codepoints.first
SPACE = ' '.codepoints.first
DIGIT_WIDTH = Math.log2(BASE).ceil
SHIFTS = DISPLAYS.map{|d| d * DIGIT_WIDTH }
MASKS = SHIFTS.map{|s| (2**DIGIT_WIDTH - 1) << s }


def to_id(str)
  str.reverse.codepoints.reduce(0){|id, c| (id << DIGIT_WIDTH) + (c - CHAR_OFFSET) }
end


def neighbor(id, digit, increment)
  val = ((((id & MASKS[digit]) >> SHIFTS[digit])) + increment) % BASE
  (id & ~MASKS[digit]) | (val << SHIFTS[digit])
end


def preprocess_constraints(forbid)
  # PERFORMANCE NOTE: my original version of check_forbidden brute-force 
  # iterated over `forbid` with minimal preprocessing.  Creating a trie here 
  # instead, and using it in check_forbidden, brought the run time for a 
  # combinatorially explosive corner case down from 1m5s to 8s.
  
  forbid.inject({}) do |trie, f|
    preprocess_constraints_sub(trie, f.split(' '), 0)
  end
end


def preprocess_constraints_sub(trie, xs, i)
  return true if i >= xs.length

  xs[i].codepoints.each do |c|
    c -= CHAR_OFFSET
    trie[c] = preprocess_constraints_sub(trie[c] || {}, xs, i + 1)
  end
  
  trie
end


def check_forbidden(id, constraints)
  return false if constraints.empty?
  
  DISPLAYS.map{|d| (id & MASKS[d]) >> SHIFTS[d] }.reduce(constraints) do |trie, c|
    trie[c] or break false
  end
end
