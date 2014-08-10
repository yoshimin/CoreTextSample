CoreTextSample
==============

CoreTextを使ったリンク文字描画のサンプルです

#####使い方

自分のプロジェクトにCoreTextViewディレクトリ以下を追加
CoreTextViewを使いたいクラスでYMNCoreTextView.hをインポート

以下のようにYMNCoreTextView生成 
```
NSString *text = @This is <printlog>sample</printlog> text.";
    
YMNCoreTextItem *printlog = [[YMNCoreTextItem alloc] initWithTag:@"printlog"
                                                          action:^{
                                                              NSLog(@"お、おされたー");
                                                          }];
YMNCoreTextView *textView = [[YMNCoreTextView alloc] initWithText:text item:@[printlog]];
```
表示したい文字列（NSString）とリンク情報（YMNCoreTextItem）を指定  
リンクにしたい文字列は<[任意のタグ文字列]></[任意のタグ文字列]>のタグで囲ってください
