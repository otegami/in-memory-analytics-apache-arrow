# Getting Started with Apache Arrow

## Understanding the Arrow format and specifications

Apache Arrow とは、インメモリ分析のための開発プラットフォームである
- 大きなデータシステムの実行やデータを素早く動かすことができる
- 標準化された言語から独立したカラムなーメモリフォーマット

Apache Arrow は、オープンソースプロジェクトです。
Apache Software Foundation によってリリースされている。
Dremio さんと Wes McKinney さんによって作られた。

in-memory data processing というときは、RAM 上でのデータ処理を指します

データを扱う際には、2つの主要なやり方があります。
- オンディスク形式
  - データサイズが大きさとI/Oコストに焦点を当てている
  - 例: Apache Parquet 形式が挙げられる
- インメモリ形式
  - 例: Apache Arrow 形式は、CPUの効率化をターゲットにしている

ほとんどのデータ処理システムは、データをチャンクに分割してネットワークを介してチャックしたデータを送信している
- データ処理の際にメモリを介して行っていても、データを送るコストが存在する
Arrow 形式では、メモリの中と同じように扱うことができる
- 利用されているメモリバッファを直接参照できる
- 少しのメタデータを送信される

### 簡単なまとめ
- Apache Arrow 形式を利用することで、データ処理を行う各コンポーネントが標準化されたライブラリを利用することができる(コードの再利用性が高い)
- 直接メモリバッファを共有することでゼロコピーを実現している
- 上記と同様にインメモリフォーマットではシリアライズ・デシリアラズのコストを省けるため、コンポーネント間でのデータのやり取りが早くなる

### 実際に利用されている

- SQL execution engines: Dremio Sonar, Apache Drill, Impala
- Data analysis utilities and pipelines: pandas, Spark
- Streaming and message queue systems: Apache Kafka, Storm
- Storage systems and formats: Apache Parquet, Cassandra, and Kudu

データサイエンティストなら
- pandas や NumPy を通して利用することでデータ操作のパフォーマンスをあげられる
- コピーやシリアライズのコストを大幅に削減できる

データエンジニア（Extract Transform Load に特化）なら
- Arrow を利用することでデータの統合などが容易になる
- メモリを共有することでプロセスやツール間でのデータの共有コストが格段に下がる
    - Python で取得したデータを Spark の中で利用し直接 JVM に渡すこともできる

ソフトウェアエンジニア or マシンラーニングのスペシャリストなら
- コンポーネント間のシリアライズのコストを大幅に削減できる
- クエリの並列化やデータアクセスを向上させることもできる

## Why does Arrow use a columnar in-memory format?

ディスク上に保存するデータに関しては、列指向 or 行指向 どちらが良いかはよく議論されていた
メモリ上のデータに関しては、そんなに議論がされていなかった?

### 列指向で優れている点
- 行指向では必要でないデータまでも行ごとに読み込む必要があるため無駄になってしまう
- 反して、列指向なら必要なデータのカラムのみを検索することができる
  - 複数条件で絞りたいときの行指向でいう id とかってどうなるんだろう？
- データを連続的に配置することで、ベクトル計算が容易になる
  - 近年のプロセッサーは、SIMD(Single Instruction, Multiple Data）に対応している
  - GPU(Graphics Processing Units)の有利な部分を利用できる

従来の CPU が、一要素毎に計算を行い結果を RAM に保存して進めていくのに対して、
SIMD を利用しベクトル計算を行うことで、複数要素の計算を一度で行うことができる

- 圧縮に関しても、有利な点がある
  - 列ごとで圧縮する方が、行ごとに異なるデータタイプを圧縮するよりも効率的に行える

#### SIMD vs Multithreading
単純化すると、Multithreading は、マルチタスクを処理するのに利用し、
SIMD は、同様の計算結果を最小限の工数で達成することができる

## Learning the Terminology and physical memory layout
- Arrow columnar format の仕様は下記を含んでいる
  - in-memory データ構造
  - メタデータのシリアライズ
  - データ転送するためのプロトコル
- 重要な幾つかの key point
  - シーケンシャルアクセス時のデータの隣接性
  - ランダムアクセスした際に　O(1)　でアクセス可能
  - SIMD や ベクトル計算がしやすい
  - 再配置可能であり、共有メモリないでゼロコピーが可能

メモリ内でどのように配列を定義しているかをみていく
- 一つの論理的なデータのタイプ(典型的には、enum value やメタデータで識別される)
- 一つのバッファグループ
- 64 ビット符号付き数値としての長さ
- 64 ビット符号付き数値としての null カウント
- 任意で辞書付きエンコードされた配列のための辞書

## Quick summary of physical layout

### Primitive fixed-length value arrays
- [1, null, 2, 4, 8]
  - Lenght: 5
  - Null Count: 1
  - Value Buffer: 1, UNF, 2, 4, 5, UNF

### Variable-length binary arrays
- [ "water", "Rising" ]
  - Offsets Buffer: 0 , 5, 11
  - Values Buffer: water, Rising
- 文字ごとの区切りを Offsets Buffer を見ることで判断可能

### List and fixed-size list arrays

#### List
- List<Int8> array: [[12, -7, 25], null, [0, -127, 127, 50], []]
  - :ength: 4
  - Null Count: 1
  - Validity Bitmap: 00001101
    - 確か逆位置から書かれているの CPU 依存によるものだったはず
    - CPU が理解できる仕様によって変わるから合わせる必要があったはず(ワード忘れてしまった)
  - Offests Buffer: 0, 3, 3, 7, 7
  - Value buffer: Child Array
    - Length: 7
    - Null Count: 0

例えば index 3 の長さを確かめたい時
- offset[3 + 1] - offset[3] = 7 - 7 = 0 <= 長さは 0 であることがわかる

#### FixedSizeList
FixedSizeList<T>[N] のように表され、offset buffers が必要ない

- FixedSizeList<Int8>[2]{[10, null], null, [0, 5]}
  - Length: 3
  - NullCount: 1
  - Validity Bitmap: 00000101
  - Value Buffer: 10, UNF, UNF, UNF, 0, 5
    - 長さ 2 で固定されている

二つの異なる Buffer を見る必要も、保持する必要もないので効率的である

### Struct arrays
Struct<name: VarBinary, age: Int32>
- [{"Joe", 1}, {null, 2}, null, {"mark", 4}]
- Length: 4
- NullCount: 1
- Field-0 Child Array(String)
  - Length: 4
  - NullCount: 2
  - Validity Map: 00001001
  - Offests Buffer: 0, 3, 3, 3, 7
  - Value Buffer: Joe, Mark
- Field-1 Child Array(Int32)
  - Lenght: 4
  - NullCount: 1
  - Validity Map: 00001011
  - Value Bugger: 1, 2, UNF, 4

### Union arrays - sparse and dense
一つのカラムが複数のタイプを持っている際に利用します
Struct array が、順序づけられたシーケンスなフィールドであるのに対して、順序づけられたシーケンスなタイプです。

2 つの全く異なる Union Layout が存在し、ユースケースによって最適化されている
- Dense: 密集
  - 混合型の配列を 5 bytes オーバーヘッドと共に表現している
  - それぞれの型に1つの Child Array を持つ
  - 一つの Type Buffer を持つ
    - 8 bit の符号化数値のバッファーであり、対応する slot の Type ID を持つ
  - 一つのオフセット Buffer を持つ
    - 32 bit の符号化数値のバッファーであり、対応する Child Array の中のオフセットを示している?
Dense Union は、オーバーラッピングされていないフィールドを含んだ structs の union を利用する際に使われる
-> Union<s1: Struct1, s2: Struct2, s3: Struct3, ...>
-> Union<f: float, i: int32>
  - [{f = 1.2}, null, {f = 3.2}, {i = 5}] 

Types Buffer(int8) => 0001
Offsets Buffer(int32) => 0120

Field-0 Child Array(float)
- Length: 3
- NullCount: 1
- Validity Bitmap: 00000101
- Value Buffer: 1.2, UNF, 3.4

Field-1 Child Array(int32)
- Length: 1
- NullCount: 0
- Validity Bitmap: Not Required
- ValueBuffer: 5

- Sparse: まばら

Types Buffer(int8) => 0001
^ Offset Buffer は存在しないので、どちらも同じ長さの Array になる

Field-0　Child Array(float)
- Length: 4
- NullCount: 2
- ValidityBitmap: 00000101
- Value Buffer: 1.2, UNF, 3.4, UNF

Field-1 Child Array(Int32)
- Length: 4
- NullCount: 3
- ValidityBitmap: 00001000
- Value Buffer: UNF, UNF, UNF, 5

^ dense と異なりスペースは増えてしまうが、
ベクトル式を評価する際に容易になります。

### Dictionary-encoded arrays
多くの連続した値が続く時に、Dictonary-encoeded を利用すると多くのスペースを削減できる

=> String Array { ["foo", "bar", "foo", "bar", "null", "baz"] }

Length: 6
Null Count: 1
Offsets Buffer: 0, 3, 6, 9, 12, 12, 15
Value Buffer: foo, bar, foo, bar, baz

=> Dictionary Encoded String Array { ["foo", "bar", "foo", "bar", "null", "baz"] }

Length: 6
Null Count: 1
Validity Bitmap: 00101111
Value Buffer: 0, 1, 0, 1, UNF, 2
- Dictionary Array String
- Length: 3
- Null Count: 0
- Validity Bitmap: Not Required <- Null がないからですか？
- Offests Buffer: 0, 3, 6, 9
- Value Buffer: foo, bar, baz

### Null Arrays
type set: null
Lenght: Array の長さそのまま
Validity Bitmap: Not Required <-　全て Null だから
Data Buffer: Not Required

## Hot to speak Arrow
physical layout をみてきたが、logical types をみていきましょう！

- Null logical type; Null physical type
- Boolean: Primitive array with data represented as a bitmap
- Primitive integer types: Primitive, fixed-size array layout
  - Int8, Uint8, Int16, Uint16, Int32, Uint32, Int64, and Uint64
- Floating-point types: Primitive fixed-size array layout
  - Float16, Float32(float), and Float64(double)
- VarBinary types: Variable length binary physical layout
  - Binary and String(UTF-8)
  - LargeBinary and LargeString(variable length binary with 64-bit offsets) 
- Decimal128 And Decimal256: 128-bit and 256-bit fixed-size primitive arrays with metadata
- Fixed-size binary: Fixed-size binary physical layout
- Temporal types: Primitive fixed binary physical layout
  - Date types: Dates with no time information
    - Date32: 32-bit integers が Unix Epoch(1970-01-01)からの日にちの数値を表現する
    - Date64: 64-bit integers が Unix Epoch(1970-01-01)からmsで表す
  - Time types: TIme information with no date attached
    - Time32: 32-bit integers が深夜から経過した時間を秒あるいはミリ秒で表現する
    - Time64: 64-bit integers が深夜から経過した時間をマイクロ秒あるいはナノ秒で表現する
- Timestamps: 64-bit integers Unix Epoch からの時間を表す（ただし閏年は考慮しない）
  - メタデータでユニット(秒、ミリ秒、マイクロ秒、ナノ秒)をで定義します。任意で タイムゾーンを string で加える
- Interval types: カレンダーアーティファクトの点で完全な時間の長さを表す?(ちょっと意味が取れてない)
  - YearMonth: 32-bit 符号化数値として経過した整数年月
  - DayTime: 2つの連続した 4-byte の符号化付き数値として経過日数とミリ秒を数値であわわす
  - MonthDayNano: 経過月、日にちとナノ秒を連続した 16 byteのブロックとして保存する。月と日数を2つの 32-bit 数値表し、深夜からの経過を64-bitのナノ秒で表す
  - Duration: 64-bit の数値と秒、ミリ秒、マイクロ秒またはナノ秒をメタデータによって特定されるユニットで、カレンダーに紐づかない時間を完全な長さで表す
- List & FixedSizeList: これらは物理的なレイアウトを表す
  - LargeList: 64-bit のオフセットで表されるリストタイプ
- Struct, DenseUnion & SparseUnion types: すでにみているので割愛
- Map: 論理的なタイプであり、List<entries: Struct<key: K, value: V>> として物理的に表される。
  - メタデータは、key がソートされているか否かを示す

## Arrow format versioning and stability
2つのバージョンニングが存在する
- format version
- library version

## Would you download a library? Of course!
- Arrow の仕様を明確に実装したもの
  -> C++, C#, GO, Java, JavaScript, Julia, Rust
- 他の実装上に実装されたもの
  -> C, MATLAB, Python, R, Ruby
  - ^ C++ のライブラリー上に実装されている

