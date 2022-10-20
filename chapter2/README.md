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

pandas では、下記のことをサポートしていない
- DataFrame では、ネスとしたカラムをサポートしていない
- Null のカラムをサポートしていない(一部のカラムはできているよ)
- DateTime には、ns のみ使われる

^ どちらも Arrow ではサポートしている

## pandas firing Arrow

pandas は、index 変数を持っている
- データに対する行のラベルを保持するもの
- 0 ベースの index を利用する代わりである

from pandas で変換される際には、preserve_index がデータの index 情報などを保持する
- 上記はメタデータで管理される

実際の値としては下記のようなものがある
- None
- False
- True

## Keeping pandas from running wild

## Sharing is caring ... epecially when it's your memory

### Diving into memory management

メモリを管理や追跡するための memory pools をどのように共有しているか

C++
- arrow::MemoryPool class がメモリの配置の管理やチェックを行なっている
- プロセスのデフォルトのメモリープールは、ライブラリー初期化時に初期化される
  - arrow::default_memory_pool

Memory allocators
- jemalloc or mimalloc は malloc よりも、システムメモリーの利用率や配置に関して優れている（実際に確かめてみるのが良いよ）

- Buffer の管理は、arrow::Buffer が行っている
  - Buffer Builder によって、Buffer は事前に配置される STL コンテイナーの std::vector ように Resize や Reserve メソッドを通して
- Buffer インスタンスは、内部のバッファーをスライスでき、追加データのコピーを避ける
- 配置された Buffer は、長さとキャパシティを持っている

### Managing buffers for performance

- 大量のデータがあった際には、カラムごとにメモリの配置は変えずに、Slice 単位に分けることで、並列処理で対応できる
- bitmap を利用して、null のデータがあった際には、効率的にフィルタリングが可能である
