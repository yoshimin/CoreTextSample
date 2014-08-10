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

const float FontSize = 12.f;
NSString *const FontName = @"HiraKakuProN-W3";
NSString *const LinkFontName = @"HiraKakuProN-W6";
NSString *const LinkableWordRangeKey = @"range";
NSString *const LinkableWordItemKey = @"item";


@interface YMNCoreTextView()

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSMutableArray *linkableWords;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, assign) CTFrameRef drawingFrame;

@end

@implementation YMNCoreTextView


//※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*
#pragma mark - Initialize -
//※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*

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


//※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*
#pragma mark - Draw Text -
//※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*

- (void)setText {
    for (YMNCoreTextItem *item in self.items) {
        [self addLinkableAttributs:item];
    }
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)FontName, FontSize, nil);
    NSDictionary *attrDictionary = @{(NSString *)kCTFontAttributeName:(__bridge id)fontRef};
    CFRelease(fontRef);
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attrDictionary];
    
    CTFontRef linkableFontRef = CTFontCreateWithName((CFStringRef)LinkFontName, FontSize, nil);
    NSDictionary *linkableAttrDictionary = @{(NSString *)kCTFontAttributeName:(__bridge id)linkableFontRef,
                                             (NSString *)kCTForegroundColorAttributeName:(id)[UIColor blueColor].CGColor,
                                             (NSString *)kCTUnderlineStyleAttributeName:@(kCTUnderlineStyleSingle)};
    for (NSDictionary *linkableWord in self.linkableWords) {
        NSRange wordRange = [linkableWord[LinkableWordRangeKey] rangeValue];
        [self.attributedString addAttributes:linkableAttrDictionary range:wordRange];
    }
    CFRelease(linkableFontRef);
}

- (void)addLinkableAttributs:(YMNCoreTextItem*)item {
    NSString *startTag = [NSString stringWithFormat:@"<%@>", item.tag];
    NSString *endTag = [NSString stringWithFormat:@"</%@>", item.tag];
    
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
            NSDictionary *linkableWord = @{LinkableWordItemKey: item, LinkableWordRangeKey: [NSValue valueWithRange:NSMakeRange(wordLocation, wordLength)]};
            [self.linkableWords addObject:linkableWord];
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
    self.drawingFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0.f, self.attributedString.length), path, nil);
    CTFrameDraw(self.drawingFrame, context);
    CFRelease(framesetter);
    CFRelease(path);
}

- (void)highlightLinkableWordWithRange:(NSRange)range highlight:(BOOL)highlight {
    UIColor *textColor = [UIColor blueColor];
    if (highlight) {
        textColor = [UIColor lightGrayColor];
    }
    
    CTFontRef linkableFontRef = CTFontCreateWithName((CFStringRef)LinkFontName, FontSize, nil);
    NSDictionary *linkableAttrDictionary = @{(NSString *)kCTFontAttributeName:(__bridge id)linkableFontRef,
                                             (NSString *)kCTForegroundColorAttributeName:(id)textColor.CGColor,
                                             (NSString *)kCTUnderlineStyleAttributeName:@(kCTUnderlineStyleSingle)};
    
    [self.attributedString addAttributes:linkableAttrDictionary range:range];
    
    CFRelease(linkableFontRef);
    [self setNeedsDisplay];
}


//※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*
#pragma mark - Touch Handling -
//※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*─※○o｡..:*

- (NSRange)rangeOfPoint:(CGPoint)point {
    // CTFrameからCTLineの配列を取得
    CFArrayRef lines = CTFrameGetLines(self.drawingFrame);
    
    // CTFrameからCTLineの原点座標を取得
    CGPoint *origins = malloc(sizeof(CGPoint) * CFArrayGetCount(lines));
    CTFrameGetLineOrigins(self.drawingFrame, CFRangeMake(0, 0), origins);
    
    NSRange range;
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        // i番目のCTLineを取得
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        // i番目のCTLineの原点座標
        CGPoint origin = *(origins + i);
        
        // 行のframeを計算
        CGFloat ascent = 0;
        CGFloat descent = 0;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, nil);
        CGRect lineFrame = CGRectMake(origin.x, origin.y - descent, lineWidth, ascent + descent);
        
        // タッチされた座標がCTLineのframe内にあるかどうか判定
        if (CGRectContainsPoint(lineFrame, point)) {
            // タッチされた文字列のインデックスを取得
            CFIndex index = CTLineGetStringIndexForPosition(line, point);
            if (index == kCFNotFound) {
                continue;
            }
            
            // タッチされた文字列の属性を取得
            [self.attributedString attributesAtIndex:index effectiveRange:&range];
        }
    }
    
    if (origins) {
        free(origins), origins = nil;
    }
    
    return range;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    point.y = CGRectGetHeight(self.bounds) - point.y;
    
    // タッチされた文字列のrangeを取得
    NSRange touchedRange = [self rangeOfPoint:point];
    
    for (NSDictionary *linkableWord in self.linkableWords) {
        NSRange linkableWordRange = [linkableWord[LinkableWordRangeKey] rangeValue];
        
        // タッチされた文字列のrangeがリンク文字かどうか判定
        if (NSIntersectionRange(touchedRange, linkableWordRange).length > 0) {
            // タッチされた文字列をハイライトさせる
            [self highlightLinkableWordWithRange:linkableWordRange highlight:YES];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    point.y = CGRectGetHeight(self.bounds) - point.y;
    
    NSRange touchedRange = [self rangeOfPoint:point];
    
    for (NSDictionary *linkableWord in self.linkableWords) {
        NSRange linkableWordRange = [linkableWord[LinkableWordRangeKey] rangeValue];
        
        if (NSIntersectionRange(touchedRange, linkableWordRange).length > 0) {
            // タッチされた文字列をハイライトさせる
            [self highlightLinkableWordWithRange:linkableWordRange highlight:YES];
        } else {
            // タッチが文字から外れたら元の色に戻す
            [self highlightLinkableWordWithRange:linkableWordRange highlight:NO];
        }
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    point.y = CGRectGetHeight(self.bounds) - point.y;
    
    NSRange touchedRange = [self rangeOfPoint:point];
    
    for (NSDictionary *linkableWord in self.linkableWords) {
        NSRange linkableWordRange = [linkableWord[LinkableWordRangeKey] rangeValue];
        if (NSIntersectionRange(touchedRange, linkableWordRange).length > 0) {
            // 元の色に戻す
            [self highlightLinkableWordWithRange:linkableWordRange highlight:NO];
            
            YMNCoreTextItem *item = linkableWord[LinkableWordItemKey];
            if (item.action) {
                item.action();
            }
        }
    }
    
    [super touchesEnded:touches withEvent:event];
}

@end
