//
//  MessageTextView.m
//  BulletinBoardIOS
//
//  Created by LEE ZHE YU on 2015/12/26.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#import "MessageView.h"
#import "POP.h"

@implementation MessageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commInit];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commInit];
    }
    return self;
}
- (void)commInit {
    [self.layer setMasksToBounds:YES];
}
- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(CGRectGetWidth(rect) / 8, CGRectGetWidth(rect) / 8)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:path.CGPath];
    [self.layer setMask:maskLayer];
}

- (void)fadeIn {
    [_textView becomeFirstResponder];
    [UIView animateWithDuration:1.0 animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - IBAction
- (IBAction)enter:(id)sender {
    [_textView resignFirstResponder];
    if (_delegate) {
        [_delegate sendMessage:_textView.text];
    }
}
- (IBAction)cancel:(id)sender {
    [_textView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        if (_delegate) {
            [_delegate cancel];
        }
    }];
}

#pragma mark - UITextFieldDelegate

@end
