gem 'test-unit'
require 'test/unit'
require './thread_sort'
class ThreadSortContract < Test::Unit::TestCase


  def test_empty_list
    time_limit = 0
    arr = []
    sorter = ThreadSort.new(time_limit)

    is_sorted(sorter.sort(arr)){|l,r| l - r}
  end

  def test_reverse_sorted_list
    time_limit = 0
    num_elements = 100
    arr = (1..num_elements).to_a.reverse
    sorter = ThreadSort.new(time_limit)

    is_sorted(sorter.sort(arr) {|l,r| l - r}){|l,r| l - r}
  end

  def test_random_list
    time_limit = 0
    num_elements = 100
    arr = Array.new(num_elements)
    arr.map!{ rand(num_elements) }
    sorter = ThreadSort.new(time_limit)

    is_sorted(sorter.sort(arr) {|l,r| l - r}){|l,r| l - r}
  end

  def test_timeout
    time_limit = 1
    num_elements = 1000
    arr = Array.new(num_elements)
    arr.map!{ rand(num_elements) }
    sorter = ThreadSort.new(time_limit)

    assert_nil(sorter.sort(arr) {|l,r| l - r})
  end

  def is_sorted(arr, &compare_block)
    arr.each_index { |index|
      assert_true(compare_block.call(arr[index - 1], arr[index]) <= 0) unless index == 0
    }
  end


end