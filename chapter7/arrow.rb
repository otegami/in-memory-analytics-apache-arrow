require 'arrow'

builder = Arrow::Int64ArrayBuilder.new
builder.append([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
column1 = builder.finish
builder.reset

builder.append([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].reverse)
column2 = builder.finish
builder.reset

builder.append([1, 2, 1, 2, 1, 2, 1, 2, 1, 2])
column3 = builder.finish
builder.reset

fields = [
  Arrow::Field.new("int64",  :int64),
  Arrow::Field.new("int64",  :int64),
  Arrow::Field.new("int64",  :int64),
]
schema = Arrow::Schema.new(fields)
record_batch = Arrow::RecordBatch.new(schema, [column1, column2, column3])
