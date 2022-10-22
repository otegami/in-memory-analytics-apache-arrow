import pyarrow as pa
import pyarrow.csv
import pyarrow.parquet as pq

sliced = pq.read_table('../sample_data/yellow_tripdata_2022-01.parquet')
