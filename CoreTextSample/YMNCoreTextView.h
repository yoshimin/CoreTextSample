//
//  YMNCoreTextView.h
//  CoreTextSample
//
//  Created by Shingai Yoshimi on 8/3/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMNCoreTextItem.h"

@interface YMNCoreTextView : UIView

/**
 * 初期化メソッド
 * @param NSString YMNCoreTextViewに表示する文字列
 * @param NSArray YMNCoreTextItemの配列
 */
- (id)initWithText:(NSString*)text item:(NSArray*)items;

@end
