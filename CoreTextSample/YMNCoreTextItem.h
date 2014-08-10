//
//  YMNCoreTextItem.h
//  CoreTextSample
//
//  Created by Shingai Yoshimi on 8/9/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMNCoreTextItem : NSObject

/// リンカブル文字に付加するタグ
@property (nonatomic, strong) NSString *tag;
// リンカブル文字が押された時のアクション
@property (nonatomic, copy) void (^action)();

/**
 * 初期化メソッド
 * @param NSString リンカブル文字に付加するタグ
 * @param void リンカブル文字が押された時のアクション
 */
- (id)initWithTag:(NSString*)tag action:(void(^)(void))action;

@end
