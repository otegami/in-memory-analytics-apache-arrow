# Working with Key Arrow Specifications

扱うトピック
- 複数のフォーマットのデータをインポートする
  - CSV, Apache Parquet, pandas DataFrames
  - ^ Ruby では、pandas DataFrame に関しては現在対応中？
- Arrow と pandas 間の操作
- ゼロコストデータ交換に近い句するために共有メモリの利用方法

chunked arrays と tables の説明をしていくよ

## Working with Arrow tables
- record batch は、同じ長さの Arrow arrays と名前、型やメタデータでカラムを表すスキーマとのコレクションでした

データ操作や読む際は、chunks されたデータを一つの巨大なテーブルとして扱いたい

解決策としては、十分になスペースを用意し、単純にそこにカラムをコピーし配置していく

ただ、大きく二つの問題がある
- 新しく大きな chunk メモリをそれぞれのカラムに用意したりコピーするには、コストがかかりすぎる
- さらに record batch が増えたら、もう一度上記の操作を行う必要がある

この問題をどのように解決しているのか？
- chunked arrays は、同じ型の Arrow Arrays をただラップする
- Arrow table は、１つ以上の chunked arrays と schema を持つ

## Accessing data files with pyarrow(red arrow)

