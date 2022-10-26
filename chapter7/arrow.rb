require 'arrow'
require 'parquet'

builder = Arrow::Int64ArrayBuilder.new
builder.append_values([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
column1 = builder.finish
builder.reset

builder.append_values([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].reverse)
column2 = builder.finish
builder.reset

builder.append_values([1, 2, 1, 2, 1, 2, 1, 2, 1, 2])
column3 = builder.finish
builder.reset

fields = [
  Arrow::Field.new("a",  :int64),
  Arrow::Field.new("b",  :int64),
  Arrow::Field.new("c",  :int64),
]
schema = Arrow::Schema.new(fields)
p column1
p n_rows = column1.length
p record_batch = Arrow::RecordBatch.new(schema, n_rows, [column1, column2, column3])
# p table = Arrow::Table.new(schema, [column1, column2, column3])

Arrow::FileOutputStream.open("./tmp/file.arrow", false) do |output|
  Arrow::RecordBatchFileWriter.open(output, schema) do |writer|
    writer.write_record_batch(record_batch)
  end
end

table = Arrow::Table.load('./tmp/file.arrow')
p table
p table.slice { |slicer| slicer['a'] < 4 }
