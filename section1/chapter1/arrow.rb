require "arrow"

array = Arrow::Int64Array.new([1, 2, 3, 4])
pp array # 論理的な型

fields = [
  Arrow::Field.new("int8",   :int8),
  Arrow::Field.new("int16",  :int16),
  Arrow::Field.new("int32",  :int32),
  Arrow::Field.new("int64",  :int64),
]

puts '-- schema --'
schema = Arrow::Schema.new(fields)
pp schema

ints = [1, -2, 4, -8]
columns = [
  Arrow::Int8Array.new(ints),
  Arrow::Int16Array.new(ints),
  Arrow::Int32Array.new(ints),
  Arrow::Int64Array.new(ints),
]
pp columns

puts '-- record_batch --'
binding.irb
record_batch = Arrow::RecordBatch.new(schema, 4, columns)
pp record_batch

puts '-- record_batch.schema --'
pp record_batch.schema

puts '-- record_batch.n_rows --'
pp record_batch.n_rows
