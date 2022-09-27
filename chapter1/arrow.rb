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
record_batch = Arrow::RecordBatch.new(schema, columns)
pp record_batch

puts '-- record_batch.schema --'
pp record_batch.schema

puts '-- record_batch.n_rows --'
pp record_batch.n_rows

## Record Batch
# - 均等な長さの Array のグループや Schema を参照する
# - 大きな Dataset の row のサブセットとして扱われる
#   - Struct にとても似ている
#
# Struct Archer {
#   archer: string
#   location: string
#   year: int16
# }

# Building a struct array
data_type = Arrow::StructDataType.new(
  archer: {type: :string},
  location: {type: :string},
  year: {type: :int16}
)
values = [
['archer1', 'here', 2000],
['archer2', 'there', 2022],
['archer3', 'over there', nil],
]

puts '-- Struct Array --'
struct_array = Arrow::StructArray.new(data_type, values)
pp struct_array

# Using record batches and zero-copy manipulation
fields = [
  Arrow::Field.new(:archer, :string),
  Arrow::Field.new(:location, :string),
  Arrow::Field.new(:year, :int16),
]
schema = Arrow::Schema.new(fields)
record_batch = Arrow::RecordBatch.new(schema, struct_array)
pp record_batch

# record_batch.raw_records
# -> [["archer1", "here", 2000], ["archer2", "there", 2022]]

pp record_batch.slice(0, 3)
pp record_batch.slice(1, 1)

# Handling none values

row_data = { id: 4, cost: 241.21, cost_components: [100.00, 140.10, 1.11] }

list_description = {
  name: "cost_components",
  type: :list,
  field: {
    name: "component",
    type: :float
  }
}
fields = [
  Arrow::Field.new("id", :int8),
  Arrow::Field.new("cost",  :float),
  Arrow::Field.new(list_description)
]
data_type = Arrow::ListDataType.new(name: "component", type: :float)

schema = Arrow::Schema.new(fields)
columns = [
  Arrow::Int8Array.new(row_data[:id]),
  Arrow::FloatArray.new(row_data[:cost]),
  Arrow::ListArray.new(data_type, [row_data[:cost_components]])
]

record_batch = Arrow::RecordBatch.new(schema, 1, columns)
pp record_batch
