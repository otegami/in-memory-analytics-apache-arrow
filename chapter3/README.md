# Chapter3: Data Science with Apache Arrow

## ODBC takes an Arrow to the knee

### Lost in translation

## SPARking new ideas on Jupyter
```
docker run -d -it -v /Users/otegami/Coding/apache_arrow/in-memory-analytics-apache-arrow/:/home/jovyan/work -e JUPYTER_ENABLE_LAB=yes -p 8888:8888 -p 4040:4040 jupyter/pyspark-notebook
```

下記のエラーが出て実行ができなかったので、`use_legacy_dataset=True` をつけてみた。

```
The 'metadata' keyword is no longer supported with the new datasets-based implementation. Specify 'use_legacy_dataset=True' to temporarily recover the old behaviour.
```

実行したが、下記のエラーが出たのでサンプル用のファイルを見直さないと行けなさそうなので、一旦スルーして本文を読んでいきます。
`sliced = pq.read_table('../sample_data/sliced.parquet', use_legacy_dataset=True)`

```
The 'schema' argument is only supported when use_legacy_dataset=False
```

データを自分で NYC Taxi から引っ張ってくることにした

```python
%%time
import pyarrow as pa
import pyarrow.csv
import pyarrow.parquet as pq

pdf = pa.csv.read_csv('../sample_data/sliced.csv').to_pandas()
```
結果
```
CPU times: user 1.41 s, sys: 209 ms, total: 1.62 s
Wall time: 444 ms
```

```
%%timeit
import pyarrow as pa
import pyarrow.csv
import pyarrow.parquet as pq

pdf = pa.csv.read_csv('../sample_data/sliced.csv').to_pandas()
```
結果
```
The slowest run took 15.69 times longer than the fastest. This could mean that an intermediate result is being cached.
1.41 s ± 1.84 s per loop (mean ± std. dev. of 7 runs, 1 loop each)
```
```
%time df = spark.read.format('csv').load('../sample_data/sliced.csv', inferSchema='true', header='true')
```
結果
```
CPU times: user 7.75 ms, sys: 718 µs, total: 8.47 ms
Wall time: 8.2 s
```

```python
# using pyspark native reader
%%time
df = spark.read.format('parquet').load('../sample_data/yellow_tripdata_2022-01.parquet') # using pyspark native reader
df.describe().show()
```
```
CPU times: user 11.4 ms, sys: 916 µs, total: 12.3 ms
Wall time: 22.3 s
```

```python
%%time
df = spark.createDataFrame(pq.read_table('../sample_data/yellow_tripdata_2022-01.parquet').to_pandas()) # using pyarrow
df.describe().show()
```

結果(手元ではうまく動かなかった)ので、本の結果を仮で貼ります
```
CPU times: user 2.54 s, sys: 1.38 s, total: 3.92 s Wall time: 12.3 s Our timing shows a total
```
python <-> sparm(jvm) 間のシリアライズ・デシリアライズのコスト削減が顕著に出ている(3x?)

### Step3 - Creating our UDF to normalize a column

### Step X
他にも Step がいくつかあるが、手元でうまく動かせなかったので、読むことに専念しました。
- Red Data Tools で開発されている gem を利用すれば再現はできそう(一旦最後まで一通り読むことに専念する)

## Stretching workflows onto Elasticsearch

Elasticsearch では、JSON 形でデータを扱うので、binary でデータを扱う Arrow をそのまま流用することはできない。シリアライズしてあげる必要があるよ！

そもそも、Elasticsearch をどうやって利用するものなのかを理解していないので、あまり頭に入ってこないなぁ...

Elasticsearch ように index されたデータが必要そうなのだけはわかった。

## Summary
Jupyter(Note 上でコードを実行できる), Spark(JVM 上で動き分析が得意), ODBC(データベースへアクセスするための共通 API などを定義したもの?) を学んだ。
- Ruby には現在存在しないが、[Red Table Query](https://github.com/red-data-tools/red-table-query)で、挑戦しようとしていたはず。




