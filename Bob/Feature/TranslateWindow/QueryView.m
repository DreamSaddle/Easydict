//
//  QueryView.m
//  Bob
//
//  Created by ripper on 2019/11/13.
//  Copyright © 2019 ripperhe. All rights reserved.
//

#import "QueryView.h"
#import "ImageButton.h"
#import "TextView.h"

#define kTextViewBottomInset 36.0


@interface QueryView () <NSTextViewDelegate>

@property (nonatomic, strong) NSButton *detectLanguageButton;

@end


@implementation QueryView

DefineMethodMMMake_m(QueryView);

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSColor *blackColor = [NSColor blackColor];
    
    self.wantsLayer = YES;
    [self.layer excuteLight:^(id _Nonnull x) {
        [x setBackgroundColor:LightBgColor.CGColor];
        [x setBorderColor:[NSColor mm_colorWithHexString:@"#EEEEEE"].CGColor];
    } drak:^(id _Nonnull x) {
        [x setBackgroundColor:DeepDarkColor.CGColor];
        [x setBorderColor:DarkBorderColor.CGColor];
    }];
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 8;
    
    self.scrollView = [NSScrollView mm_make:^(NSScrollView *_Nonnull scrollView) {
        [self addSubview:scrollView];
        scrollView.wantsLayer = YES;
        scrollView.layer.backgroundColor = NSColor.clearColor.CGColor;
        scrollView.hasVerticalScroller = YES;
        scrollView.hasHorizontalScroller = NO;
        scrollView.autohidesScrollers = YES;
        self.textView = [TextView mm_make:^(TextView *_Nonnull textView) {
            [textView excuteLight:^(id _Nonnull x) {
                [x setBackgroundColor:LightBgColor];
                [x setTextColor:LightTextColor];
            } drak:^(id _Nonnull x) {
                [x setBackgroundColor:LightBgColor];
                [x setTextColor:[NSColor whiteColor]];
            }];
            [textView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
            textView.delegate = self;
        }];
        scrollView.documentView = self.textView;
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.inset(0);
            make.bottom.inset(kTextViewBottomInset);
        }];
    }];
    
    
    self.audioButton = [ImageButton mm_make:^(ImageButton *_Nonnull button) {
        [self addSubview:button];
        button.bordered = NO;
        button.wantsLayer = YES;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.imageScaling = NSImageScaleProportionallyDown;
        button.bezelStyle = NSBezelStyleRegularSquare;
        [button setButtonType:NSButtonTypeMomentaryChange];
        
        NSImage *image = [NSImage imageNamed:@"audio"];
        
        if (@available(macOS 10.14, *)) {
            button.image = image;
            button.contentTintColor = NSColor.blackColor;
        } else {
            NSImage *image = [NSImage imageNamed:@"audio"];
            button.image = [self changeColor:blackColor oldImage:image];
        }
        button.toolTip = @"播放音频";
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(6);
            make.bottom.inset(6);
            make.width.height.equalTo(@26);
        }];
        mm_weakify(self)
        [button setRac_command:[[RACCommand alloc] initWithSignalBlock:^RACSignal *_Nonnull(id _Nullable input) {
            mm_strongify(self) if (self.audioActionBlock) {
                self.audioActionBlock(self);
            }
            return RACSignal.empty;
        }]];
    }];
    
    self.textCopyButton = [ImageButton mm_make:^(ImageButton *_Nonnull button) {
        [self addSubview:button];
        button.bordered = NO;
        button.wantsLayer = YES;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        
        NSImage *image = [NSImage imageNamed:@"copy"];
        
        if (@available(macOS 10.14, *)) {
            button.image = image;
            button.contentTintColor = NSColor.blackColor;
        } else {
            button.image = [self changeColor:blackColor oldImage:image];
        }
        button.imageScaling = NSImageScaleProportionallyDown;
        button.bezelStyle = NSBezelStyleRegularSquare;
        [button setButtonType:NSButtonTypeMomentaryChange];
        
        button.toolTip = @"复制";
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.audioButton.mas_right);
            make.bottom.equalTo(self.audioButton);
            make.width.height.equalTo(self.audioButton);
        }];
        mm_weakify(self)
        
        [button setRac_command:[[RACCommand alloc] initWithSignalBlock:^RACSignal *_Nonnull(id _Nullable input) {
            mm_strongify(self) if (self.copyActionBlock) {
                self.copyActionBlock(self);
            }
            return RACSignal.empty;
        }]];
    }];
    
    self.detectLanguageButton = [NSButton mm_make:^(NSButton *_Nonnull button) {
        [self addSubview:button];
        button.hidden = YES;
        button.bezelStyle = NSBezelStyleInline;
        [button setButtonType:NSButtonTypeMomentaryChange];
        
        button.toolTip = @"检测语言";
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.textCopyButton.mas_right).offset(5);
            make.centerY.equalTo(self.textCopyButton);
            make.height.equalTo(self.textCopyButton).offset(-5);
        }];
        
        [button setRac_command:[[RACCommand alloc] initWithSignalBlock:^RACSignal *_Nonnull(id _Nullable input) {
            NSLog(@"detectLanguageActionBlock");
            
            return RACSignal.empty;
        }]];
    }];
    
    
    // 将scrollview放到最上层
    [self addSubview:self.scrollView];
    
    [self layoutSubtreeIfNeeded];
    
    NSTrackingArea *copyTrackingArea = [[NSTrackingArea alloc]
                                        initWithRect:[self.textCopyButton bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:self
                                        userInfo:nil];
    [self.textCopyButton addTrackingArea:copyTrackingArea];
    
    NSTrackingArea *playTrackingArea = [[NSTrackingArea alloc]
                                        initWithRect:[self.audioButton bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:self
                                        userInfo:nil];
    
    [self.audioButton addTrackingArea:playTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSColor *highlightBgColor = [NSColor mm_colorWithHexString:@"#E2E2E2"];
    CGPoint point = theEvent.locationInWindow;
    point = [self convertPoint:point fromView:nil];
    if (CGRectContainsPoint(self.textCopyButton.frame, point)) {
        [[self.textCopyButton cell] setBackgroundColor:highlightBgColor];
    } else if (CGRectContainsPoint(self.audioButton.frame, point)) {
        [[self.audioButton cell] setBackgroundColor:highlightBgColor];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[self.textCopyButton cell] setBackgroundColor:NSColor.clearColor];
    [[self.audioButton cell] setBackgroundColor:NSColor.clearColor];
}

// Change NSImage tint color
- (NSImage *)changeColor:(NSColor *)color oldImage:(NSImage *)oldImage {
    NSImage *newImage = [oldImage copy];
    [newImage lockFocus];
    [color set];
    NSRect imageRect = NSMakeRect(0, 0, newImage.size.width, newImage.size.height);
    NSRectFillUsingOperation(imageRect, NSCompositingOperationSourceAtop);
    [newImage unlockFocus];
    [newImage setTemplate:NO];
    return newImage;
}


- (void)setDetectLanguage:(NSString *)detectLanguage {
    _detectLanguage = detectLanguage;
    
    NSString *title = @"识别为 ";
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [attrTitle addAttributes:@{
        NSForegroundColorAttributeName : NSColor.grayColor,
        NSFontAttributeName : [NSFont systemFontOfSize:10],
    }
                       range:NSMakeRange(0, attrTitle.length)];
    
    
    NSMutableAttributedString *detectAttrTitle = [[NSMutableAttributedString alloc] initWithString:detectLanguage];
    [detectAttrTitle addAttributes:@{
        NSForegroundColorAttributeName : [NSColor mm_colorWithHexString:@"#007AFF"],
        NSFontAttributeName : [NSFont systemFontOfSize:10],
    }
                             range:NSMakeRange(0, detectAttrTitle.length)];
    
    [attrTitle appendAttributedString:detectAttrTitle];
    
    CGFloat width = [self widthForAttributeString:attrTitle];
    self.detectLanguageButton.hidden = NO;
    self.detectLanguageButton.attributedTitle = attrTitle;
    [self.detectLanguageButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width + 10);
    }];
    
    [self layoutSubtreeIfNeeded];
}

// Get attribute string width.
- (CGFloat)widthForAttributeString:(NSAttributedString *)attributeString {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributeString];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGSize size = [layoutManager usedRectForTextContainer:textContainer].size;
    return size.width;
}

- (CGFloat)widthForAttributeString2:(NSAttributedString *)attributeString {
    __block CGFloat width;
    [attributeString enumerateAttributesInRange:NSMakeRange(0, attributeString.length) options:1 usingBlock:^(NSDictionary<NSString *, id> *_Nonnull attrs, NSRange range, BOOL *_Nonnull stop) {
        NSAttributedString *mString = [attributeString attributedSubstringFromRange:range];
        NSLog(@"%@, %lu", mString.string, (unsigned long)mString.string.length);
        
        CGSize rect = [mString.string sizeWithAttributes:attrs];
        NSLog(@"rect: %@", @(rect));
        
        width += rect.width;
    }];
    NSLog(@"width: %@", @(width));
    return width;
}


#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        NSEventModifierFlags flags = NSApplication.sharedApplication.currentEvent.modifierFlags;
        if (flags & NSEventModifierFlagShift) {
            return NO;
        } else {
            if (self.enterActionBlock) {
                self.enterActionBlock(self);
            }
            return YES;
        }
    }
    return NO;
}

@end
