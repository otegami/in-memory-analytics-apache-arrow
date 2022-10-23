require "parquet"
require 'memory_profiler'

# table = Arrow::Table.load("./yellow_tripdata_2021-01.parquet")
# table.save("./yellow_tripdata_2021-01.arrow")

report = MemoryProfiler.report do
  arrow_table = Arrow::Table.load("./yellow_tripdata_2021-01.arrow")
  total = arrow_table.find_column("total_amount").sum
  puts total/arrow_table.size
end

report.pretty_print
