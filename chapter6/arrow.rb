require 'parquet'

# table = Arrow::Table.load("/Users/otegami/Downloads/yellow_tripdata_2017-02.parquet")
# # p table.size
# # p table.group('VendorID').sum('fare_amount')

# target_column = table.find_column("total_amount")
# # add = Arrow::Function.find('add')
# # p target_column
# # p add.execute([target_column, Arrow::ScalarDatum.new(Arrow::FloatScalar.new(5.5))]).value

# min_max = Arrow::Function.find('min_max')
# p min_max.execute([target_column]).value
# p table.slice { |slicer| slicer['total_amount'] > 361772.0 }
# p table.slice { |slicer| slicer['total_amount'] < -235.0 }

# options = Arrow::SortOptions.new
# options.add_sort_key(Arrow::SortKey.new('total_amount', :descending))
# p table.sort_indices(options)

# options.add_sort_key(Arrow::SortKey.new('total_amount', :ascending))
# p table.sort_indices(options)

def generate_random_array(size)
  Array.new(size).map { rand(10) }
end

p Arrow::Int32Array.new(generate_random_array(10))

builder = Arrow::Int32ArrayBuilder.new
builder.append(2)
p builder.finish
