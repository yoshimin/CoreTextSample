//
//  YMNCoreTextItem.m
//  CoreTextSample
//
//  Created by Shingai Yoshimi on 8/9/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

#import "YMNCoreTextItem.h"

@implementation YMNCoreTextItem

- (id)initWithTag:(NSString*)tag action:(void(^)(void))action {
    self = [super init];
    if (self) {
        self.tag = tag;
        self.action = action;
    }
    return self;
}

@end
