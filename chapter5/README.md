# Chapter5: Crossing the Language Barrier with the Arrow C Data API

- Schemas と Data の両方を共有できる
- Data の Record Batch を　Streaming できる
- Interface が有益に働くケース

## Using the Arrow C data interface

Arrow IPC format と C data format のどちらを使うべきか

C data format の利点
- Zero-copy
- リソースのライフタイムマネジメントのためのカスタマイズ性のあるリリースコールバック
- 異なるコードベースに対して容易にコピーする最小の C 定義である
- FlatBuffers に依存しない Arrow のロジカルなフォーマットな形でデータが提供される

Arrow IPC format の利点
- 異なるプロセスやマシンを超えてのやり取りや、ストレージと持続性を提供する
- C data へのアクセスが必要ない
- Stream 可能な format なので、圧縮のような他の機能性を追加する余地がある

### The ArrowSchema structure
Schema と Data 事態を分けることで、ABI(Application Binary Interface)は、それぞれの バッチデータに対して、Schema 情報を import や export するコストを回避させている

#### TIDBIT
C の ArrowSchema は、C++ の arrow::Field に実態は近い
C++ の arrow::Schema は、Fields の Collection 情報と schema レベルの metadata を保持している
C の ArrowSchema Struct type として、スキマーまの個々のフィールドを children として Schema 形式で持つ（ArrowSchema を再利用する形になっている）
- これわかりづらくならないのかなぁ...

ArrowSchema と ArrowArray のみを利用する

## Example use cases

## Streaming across the C Data API

## Other use cases
