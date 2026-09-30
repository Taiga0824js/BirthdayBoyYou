Birthday Boy You — Party Update

更新内容
- 息判定をかなり通りやすく調整。
- メニューにマイク感度スライダーを追加（初期75%）。
- 音量だけではなく、波形の荒さ＋声の周期性も見るので、叫び声は弱く扱う。
- 5人の簡易3Dキャラクターがケーキの周りで祝う。
- 「HAPPY BIRTHDAY」と名前を3D文字で壁に表示。
- 「Happy Birthday!」「Make a wish!」「We're here!」などの吹き出し文字。
- 全消し後に人物が腕を上げて跳ねる。
- 拍手SE、歓声SE、成功SE、紙吹雪。
- 火は一瞬で消えず、傾く→縮む→最後に小さく揺れる→消火→煙、の順。
- 手前・中央の火ほど風を受けやすい。
- SPACEは動作確認用の疑似ブレス。

上書き
1. Godotを閉じる。
2. BirthdayBoyYou_party_update.zip をDesktopへ置く。
3. Terminal:

cd ~/Desktop
cp -R BirthdayBoyYou BirthdayBoyYou_before_party_update
unzip -o BirthdayBoyYou_party_update.zip -d BirthdayBoyYou
open ~/Desktop/BirthdayBoyYou/project.godot

マイク
- モード開始直後だけ0.85秒ほど静かにする。
- まず感度75%で試す。
- 息が通らなければ90〜100%。
- 環境音で勝手に反応するなら55〜70%。
