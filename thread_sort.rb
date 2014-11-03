class ThreadSort
  def initialize(time_limit)
    @time_limit = time_limit.to_i
  end

  def sort(array_to_sort, &comparer)
    #do a clone of the list first
    sorter = lambda do |arr|
      if arr.size == 1
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

    sorter.call(array_to_sort)

  end

  private

  def p_merge(left, right, &comparer)
    merged = Array.new(left.size + right.size)
    if right.size > left.size
      merged = p_merge(right, left, &comparer)
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

    end
    merged

  end

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

s = ThreadSort.new(0)
sorted = s.sort([1, 4, 11, 6, 7, 2, 5, 14, 3, 12, 13, 9, 8, 10]) { |l, r| l - r }
puts sorted.join(',')
sorted = s.sort([61, 46, 141, 68, 774, 22, 5, 14, 3, 132, 13, 9, 8, 10]) { |l, r| l - r }
puts sorted.join(',')
sorted = s.sort([15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]) { |l, r| l - r }
puts sorted.join(',')
sorted = s.sort([16, 54, 511, 6, 7, 2, 5, 14, 3, 12, 13, 9, 8, 10]) { |l, r| l - r }
puts sorted.join(',')