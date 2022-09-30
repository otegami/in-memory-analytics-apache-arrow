import pyarrow as pa
import pyarrow.csv
import pandas as pd
import timeit

from datetime import date


# df = pd.DataFrame({"a": [1, 2, 3], "b": ["hello", "world", "!"]})
# record_batch = pa.RecordBatch.from_pandas(df)

# with pa.OSFile("./pandas.arrow", "wb") as sink:
#   schema = record_batch.schema
#   writer = pa.RecordBatchFileWriter(sink, schema)
#   writer.write_batch(record_batch)
#   writer.close()

arr = pa.array([1, 2, 3])
print(arr)
print(arr.to_pandas())
# 0    1
# 1    2
# 2    3
# dtype: int64

# Null の有無で変換先の型を変える必要が出てくる
# pandas の integer 型は、Null を許容しないため
arr = pa.array([1, 2, None])
print(arr.to_pandas())
# 0    1.0
# 1    2.0
# 2    NaN
# dtype: float64

s = pd.Series([date(1987, 8, 4), None, date(2000, 1, 1)])
arr = pa.array(s)
print(arr, arr.type)

# arr = pa.array(s, type='date64')
# print(arr.type)

s2 = pd.Series(arr.to_pandas(date_as_object=False))
print(s2.dtype)

df = pd.DataFrame({
  'datetime': pd.date_range('2020-01-01T00:00:00-0400', freq='H', periods=3)
})
print(df)

table = pa.Table.from_pandas(df)
print('table', table)
