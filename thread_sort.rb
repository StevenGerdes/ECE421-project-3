require 'timeout'
class ThreadSort

  #a time limit of zero means wait forever
  def initialize(time_limit)
    if !time_limit.respond_to?(:to_i) or time_limit.to_i < 0
      pre_condition_abort
    end
    @time_limit = time_limit.to_i
  end

  #does a threaded parralel merge sort
  def sort(array_to_sort, &comparer)

    if comparer.nil?
      comparer = Proc.new {
          |l, r|
        if l.nil? and r.nil?
          0
        elsif l.nil?
          -1
        elsif r.nil?
          1
        else
          l-r
        end
      }
    end

    #Even though this isn't how contracts are supposed to work seeing as it is a requirement
    #checking preconditions
    begin
    if !array_to_sort.respond_to?(:slice) ||
        !array_to_sort.respond_to?(:[]) ||
        !array_to_sort.respond_to?(:size) ||
        (array_to_sort.size > 1 && #We don't need to check the other preconditions if it is a size 1 or less array
            !comparer.call(array_to_sort[0], array_to_sort[1]).respond_to?(:to_i) ||
            comparer.call(array_to_sort[0], array_to_sort[0]) != 0)
      pre_condition_abort
    end
    rescue Exception
      pre_condition_abort
    end

    sorter = lambda do |arr|
      if arr.size <= 1
        return arr
      end

      middle = (arr.size/2).floor
      left = right = []

      l_sort = Thread.new {
        left = sorter.call arr[0..middle - 1]
      }

      r_sort = Thread.new {
        right = sorter.call arr[middle..arr.size - 1]
      }

      l_sort.join
      r_sort.join

      return p_merge(left, right, &comparer)

    end
    to_return = nil
    begin
      Timeout::timeout(@time_limit) {
        to_return = sorter.call(array_to_sort)
      }
    rescue TimeoutError
      puts 'Sort Timed Out'
    rescue
      puts 'An error occurred in the sort.'
    end

    to_return.each_index { |index|
      if index > 0 and (comparer.call(to_return[index - 1], to_return[index]) > 0)
        post_condition_abort
      end
    } unless to_return.nil?

    to_return

  end

  #getter for the time_limit
  def time_limit
    @time_limit
  end

  #test if two thread sorts are equal
  def == other
    other.time_limit == @time_limit
  end

  private
  def pre_condition_abort
    abort('precondition failed')
  end

  def post_condition_abort
    abort('postcondition failed')
  end

  #merges a left array and a right array recursivley and in parallel
  def p_merge(left, right, &comparer)
    merged = Array.new(left.size + right.size)
    if right.size > left.size
      merged = p_merge(right, left, &comparer)
    elsif right.size == 0
      merged = left
    elsif merged.size == 1
      merged[0] = left[0]
    elsif left.size == 1 and right.size == 1
      if 0 >= comparer.call(left[0], right[0])
        merged[0] = left[0]
        merged[1] = right[0]
      else
        merged[0] = right[0]
        merged[1] = left[0]
      end
    else
      middle = (left.size/2).floor
      j = find_index(right, left[middle], &comparer)
      retries_left = 1
      begin #the retry pattern will only be helpful for unexpected race conditions which is why it is only handled here
        #which has the most likely place for race conditions
        if j == -1
          l_merge = Thread.new { merged[0..middle + j] = left[0..middle - 1] }
          r_merge = Thread.new {
            new_right = p_merge(left[middle..left.size - 1], right[j+1..right.size-1], &comparer)
            l_merge.join #There is a race condition where the left side must be set first.
            merged[middle + j+1 .. merged.size - 1] = new_right
          }
        elsif j == right.size
          l_merge = Thread.new { merged[0..middle + j] = p_merge(left[0..middle - 1], right[0..j], &comparer) }
          r_merge = Thread.new {
            l_merge.join
            merged[middle + j.. merged.size - 1] = left[middle..left.size - 1] }
        else
          l_merge = Thread.new { merged[0..middle + j] = p_merge(left[0..middle - 1], right[0..j], &comparer) }
          r_merge = Thread.new {
            new_right = p_merge(left[middle..left.size - 1], right[j+1..right.size-1], &comparer)
            l_merge.join
            merged[middle + j+1 .. merged.size - 1] = new_right
          }
        end
        r_merge.join
      rescue
        raise Exception if retries_left == 0
        retries_left -= 1
        retry
      end
    end
    merged

  end

  #uses the comparer to see if it is in a proper range
  def range_compare(arr, left_index, right, &comparer)
    left_is_smaller = comparer.call(arr[left_index], right) <= 0
    right_is_bigger = left_index+1 >= arr.size || comparer.call(arr[left_index+1], right) >= 0
    unless left_is_smaller
      return 1
    end
    unless right_is_bigger
      return -1
    end
    return 0
  end

  #finds the index i which satisfies arr[i] <= num <= arr[i+1]
  #if num is smaller then -1 is returned if it is bigger size is returned
  def find_index(arr, num, &comparer)

    if comparer.call(num, arr[0]) < 0
      return -1
    end
    if comparer.call(num, arr[arr.size - 1]) > 0
      return arr.size
    end

    min = 0
    max = arr.size
    index = 0
    while max >= min
      index = (min + (max - min)/2).floor
      if 0 == range_compare(arr, index, num, &comparer)
        return index
      elsif range_compare(arr, index, num, &comparer) < 0
        min = index + 1
      else
        max = index - 1
      end
    end

    index

  end
end
