//
//  YMNCoreTextView.m
//  CoreTextSample
//
//  Created by Shingai Yoshimi on 8/3/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

#import "YMNCoreTextView.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface YMNCoreTextView()

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSMutableArray *linkableWords;
@property (nonatomic, strong) NSArray *items;

@end

@implementation YMNCoreTextView

- (id)initWithText:(NSString*)text item:(NSArray*)items {
    self = [super init];
    if (self) {
        self.text = text;
        self.items = items;
        self.linkableWords = [NSMutableArray array];
        [self setText];
    }
    return self;
}

- (void)setText {
    for (YMNCoreTextItem *item in self.items) {
        [self addLinkableAttributs:item.tag];
    }
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"HiraKakuProN-W3", 12.0f, nil);
    NSDictionary *attrDictionary = @{(NSString *)kCTFontAttributeName:(__bridge id)fontRef};
    CFRelease(fontRef);
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attrDictionary];
    
    CTFontRef linkableFontRef = CTFontCreateWithName((CFStringRef)@"HiraKakuProN-W6", 12.0f, nil);
    NSDictionary *linkableAttrDictionary = @{(NSString *)kCTFontAttributeName:(__bridge id)linkableFontRef,
                                             (NSString *)kCTForegroundColorAttributeName:(id)[UIColor blueColor].CGColor,
                                             (NSString *)kCTUnderlineStyleAttributeName:@(kCTUnderlineStyleSingle)};
    for (id obj in self.linkableWords) {
        NSRange wordRange = [obj rangeValue];
        [self.attributedString addAttributes:linkableAttrDictionary range:wordRange];
    }
    CFRelease(linkableFontRef);
}

- (void)addLinkableAttributs:(NSString*)tag {
    NSString *startTag = [NSString stringWithFormat:@"<%@>", tag];
    NSString *endTag = [NSString stringWithFormat:@"</%@>", tag];
    
    BOOL finished = NO;
    while (!finished) {
        NSRange startTagRange = [self.text rangeOfString:startTag];
        NSRange endTagRange = [self.text rangeOfString:endTag];
        
        if (startTagRange.location != NSNotFound && endTagRange.location != NSNotFound) {
            // タグをテキストから削除
            self.text = [self.text stringByReplacingCharactersInRange:startTagRange withString:@""];
            endTagRange.location -= startTagRange.length;
            self.text = [self.text stringByReplacingCharactersInRange:endTagRange withString:@""];
            
            // リンカブル文字のrangeを配列に突っ込む
            CFIndex wordLocation = startTagRange.location;
            CFIndex wordLength = endTagRange.location - startTagRange.location;
            [self.linkableWords addObject:[NSValue valueWithRange:NSMakeRange(wordLocation, wordLength)]];
        } else {
            finished = YES;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // iPhone の座標系と Core Graphics の座標系は、左下が原点なためそのまま描画をすると反転してしまう
    // CGContextSetTextMatrix で反転させ CGContextTranslateCTM で並行移動
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0.f, rect.size.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    
    // 描画範囲を設定して描画
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.f, 0.f, rect.size.width, rect.size.height));
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0.f, self.attributedString.length), path, nil);
    CTFrameDraw(frame, context);
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
}


@end
