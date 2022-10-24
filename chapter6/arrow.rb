require 'parquet'

table = Arrow::Table.load("/Users/otegami/Downloads/yellow_tripdata_2017-02.parquet")
# p table.size
# p table.group('VendorID').sum('fare_amount')

target_column = table.find_column("total_amount")
add = Arrow::Function.find('add')
p target_column
p add.execute([target_column, Arrow::ScalarDatum.new(Arrow::FloatScalar.new(5.5))]).value
