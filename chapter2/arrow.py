import pyarrow as pa
import pandas as pd

df = pd.DataFrame({"a": [1, 2, 3]})
record_batch = pa.RecordBatch.from_pandas(df)
