# Chapter4: Format and Memory Handling

どのようにメモリが利用されるかなどを考えると、必然的に Protocol Buffers, JSON, FlatBuffers などから何を利用すべきかが見えてくるよ。

この章で扱うのは下記の 2 点
- どのような状況で Arrow を利用すべきか
  - Protobuf, JSON, FlatBuffers または、CSV や Apache Parquet など
- 100 GB にもなるデータを処理する 数 MB の物理的な RAM を用意て、メモリのマッピングを利用することで

## Storage versus runtime in-memory versus message-passing formats

下記の3点から判断する
- Size
- Serialize/desrialize speed
- Ease of use

- long-term storage
- in-memory runtime processing
- messages passing

### Long-term storage

候補に上がるのは下記のフォーマット
- CSV
- Apache Parquet
- Avro
- ORC(Optimized Row Columnar)
- JSON

- データの物理的なサイズを小さくする
- Query を満たすために読まれるデータを再消化するフォーマットを利用する

OLTP と OLAP

OLTP ではデータを行単位で処理する(CRUD)
- Apache Avro が最も適している

OLAP では、大量のデータを列単位で分析する
- 必要な列の情報だけを読むので、I/O コストを削減できる

### In-memory runtime formates
Memory 上で分析する際は、I/O よりも CPU が鍵となる
- より良いアルゴリズムを利用する or ベクトルとして扱う

Arrow は、頻出な分析アルゴリズムや SIMD(single instruction multiple data)に対して最適化されるようにデザインされている

CPU 側で次に来るデータが予想できるならば、より早い Clock Cycle で制御できる
なので、カラム指向であれば次のデータが予想しやすくパフォーマンスが出る

### Message-passing formats
Message-passing formats are Protbuf, FlatBuffers and JSON.

Protbuf と FlatBuffers は、メッセージを送るための共通の表現を与えてくれる
- 共通の表現に落とし込むには、シリアライズとデシリアライズのコストがかかってしまう
- 言語などに依存しない共通のフォーマットという点で Arrow があるよ

Arrow は、Protbuf や FlatBuffers 競合する技術ではなく、ORC や Parquet のようなディスク上のフォーマットと協業する技術でもない。

Arrow は、短期的にメモリ上で実行されるフォーマである。
- array-cell 形式のデータを処理するための
- 長期的に持続性のあるストレージではない

Arrow の Record Batch や Table データを渡す必要が出てきた時は、Arrow IPC の出番です！

### Passing your Arrows around

Arrow はデザインされている、容易にプロセス間で受け渡しができるように、同じマシンで動いているいないにかかわらず。

#### What is this sorcery?

2つのバイナリーフォーマットが定義されている、Record Batch をプロセス館で共有するため
- Streaming Format
  - 任意の長さの連続した Record Batch を送るため
  - 最初から最後まで一貫して処理しなければならない 
- Random Access Format
  - いくつかの Record Batch を共有するために利用される
  - メモリーマッピングをする際の結合要素としてよく利用される

Arrow IPC protocol は下記の3つのメッセージタイプを定義する
- Schema
- RecordBatch
- DictonaryBatch

それぞれのメッセージは、メタデータのための FlatBuffers メッセージで構成される
Flat buffers はかなり効率的である
- Google によってデザインされたクロスプラットフォームシリアライズのために

- 0xFFFFFFF <- 4-byte
- 32-bit little-endian integer <- Length of FlatBuffer Message
- FlatBuffers Bytes <- Metadata
- Padding to 8-bytes
- Message Body Bytes

FlatBuffers の構造

```c++
table Message {
  version: org.apache.arrow.flatbuf.MetadataVersion;
  header: MessageHeader; <- Schema, RecordBatch or DictionaryBatch
  bodyLength: long;
  custom_metadata: [ keyValue ];
}
```

Record-Batch message
RecordBatch FlatBuffer message
- Length
- Null Count

Raw Buffers data make up Record Batch(最後の部分は 8 bytes padding が含まれる)
- validity bitmap, raw data, offsets, and so on

最後の 8 bytes のメッセージを読むことで、次のデータが存在するかを確認できる

0xFFFFFFFF: まだ続くデータが存在する
0x00000000: **続くデータが存在しない**

Random Access Format

ARROW1 <- Magic String
Empty padding to 8 bytes boundary
Data Using the Streaming Format with EOS indicator
FlatBuffer Footer Message Bytes
32-bit Little Endian Int <- Footer Size
ARROW1 <- Magic String
