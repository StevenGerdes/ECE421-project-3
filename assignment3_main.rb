#Group 3 Steven Gerdes, Tyler Meen
# to run in command line simply type
#     Ruby assignment3_main.rb
#The first sort will time out, the second will succesflly sort
#The first shows sorting without a block and the second shows sorting with a block

require './thread_sort'
num_elements = 1000
arr = Array.new(num_elements)
arr.map!{ rand(num_elements) }
timeout = 2
s = ThreadSort.new(timeout)
puts "attempting to sort #{num_elements} elements"
s.sort(arr)

num_elements = 20
puts "attempting to sort #{num_elements} elements"

arr = Array.new(num_elements)
arr.map!{ rand(num_elements) }

puts 'unsorted array:'
puts arr.join(', ')

sorted = s.sort(arr){|l,r| l - r}
puts 'sorted array:'
puts sorted.join(', ')


