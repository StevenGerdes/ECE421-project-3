class ThreadSortContract  < Test::Unit::TestCase

  def sort_contract_comparitor
    time_limit = 1000
    object_array = [2,65,8,2,678,2,76]
    old_object_array = object_array.clone
    compare_block = Proc.new{|left,right| left - right}

    sorter = ThreadSort.new(time_limit)

    #invarient
    old_sorter = sorter.clone

    #precondition
    #block preconditions
    assert_respond_to(:to_i, compare_block.call(object_array[0],object_array[1]) )
    assert_equal( 0, compare_block.call(object_array[0], object_array[0]))
    #time limit preconditions
    assert_respond_to(:to_i, time_limit)
    assert_true( 0 < time_limit.to_i)
    #array preconditions
    assert_respond_to( :[], object_array)
    assert_respond_to( :size, object_array)

    sorted_array = sorter.sort(object_array, &compare_block)

    #postcondition
    assert_equal(object_array, old_object_array )
    sorted_array.each_index { |index |
      assert_true( 0 < compare_block.call(sorted_array[index - 1], sorted_array[index+] ) ) unless index == 1
    }

    #invarient
    assert_equal( old_sorter, sorter )

  end


end