# require 'arrow'
require 'parquet'

pp arrow_table = Arrow::Table.load('./train.csv')
pp arrow_table.schema
pp arrow_table.columns[0].class
# -> Arrow::Column
pp arrow_table.columns[0].data.class
# -> Arrow::ChunkedArray

## Load CSV
pp Arrow::Table.load('./train.csv', { delimiter: '|' })

## Load JSON
pp arrow_json_table = Arrow::Table.load('./example.json')
pp arrow_json_table.schema
pp arrow_json_table.columns[0]

## Load Parquet
pp arrow_parquet_table = Arrow::Table.load('../sample_data/train.parquet')

