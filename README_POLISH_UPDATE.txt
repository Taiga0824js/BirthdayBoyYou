Birthday Boy You - Polish Update

今回の更新:
- 起動直後に短いタイトル演出を追加
- タイトルBGMとメニューBGMを分離
- BGMをぶつ切りせずフェードで切り替え
- ろうそくを吹く場面ではBGMをさらに小さくする
- 最後の火が消えてから約0.55秒静かにして、その後に拍手
- 誕生日モードの派手な紙吹雪をやめ、短い「……おめでとう。」へ
- ケーキへ自然につなぐ
- 食べ終わった直後に結果画面を出さず、静かなエンディングを追加
- 「今日は来てくれてありがとう。」→「また来年。」→暗転
- 自分で用意したSE/BGMを置くだけで読み込める custom フォルダ追加
- 音源がなくても既存の仮音源へ自動フォールバック
- 既存の4言語、マイク選択、ケーキ掴み操作は維持

音源の場所:
  BirthdayBoyYou/assets/audio/custom/

ファイル名:
  title.mp3
  menu.mp3
  candle_out.wav  （mp3/oggでも可）
  applause.wav    （mp3/oggでも可）
  eat.wav         （mp3/oggでも可）

導入:
  cd ~/Desktop
  cp -R BirthdayBoyYou BirthdayBoyYou_before_polish
  unzip -o BirthdayBoyYou_polish_update.zip -d BirthdayBoyYou
  open ~/Desktop/BirthdayBoyYou/project.godot

その後、上記 custom フォルダへ自分の音源をコピーしてGodotを再度開いてください。
