# 概要

GIMP 3.x用のユーテリティ集です．[181号の同人誌](https://fwing.net/event.rb)は，このツールでハーフトーン化などをしています．
**.scm**は**~/.config/GIMP/3.0/scripts/**に，
**.rb**はPATHに含まれる場所に配置してください．

- export-png-3.scm xcfを，リサイズと切り抜きをしてpngファイルに保存します．
- save-layers-to-files-3.scm レイヤー別にファイルへ保存します．**makeToneLayers2.rb**と組み合わせて使用することを想定しています．
- makeToneLayers2.rb 以下のルールに従って複数のpngファイルを結合します
  - k{\d}3.png k010.png のようなファイルは，ハーフトーン化してから結合します．ただしk015.pngのみトーンの重ね効果を目的として，4px左右にオフセットした状態で乗算で結合します．
  - white.png 一番上に，上書きするように結合します(-compose Multiply を設定しません)．
  - 上記以外のファイル 乗算で結合します(-compose Multiply を設定します)．
- change-hair-color-3.scm レイヤ名に従って色を上書きしたり色相を回転します．

