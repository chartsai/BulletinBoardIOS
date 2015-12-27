//
//  DownloadBtn.m
//  BulletinBoardIOS
//
//  Created by LEE ZHE YU on 2015/12/27.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#import "DownloadBtn.h"

@implementation DownloadBtn

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat lineWith = 12;
    UIBezierPath *crossPath = [UIBezierPath bezierPath];
    [crossPath moveToPoint:CGPointMake(CGRectGetWidth(rect) / 2, lineWith * 2)];
    [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) - lineWith * 2)];
    [crossPath addLineToPoint:CGPointMake(lineWith * 2, CGRectGetHeight(rect) / 2)];
    [crossPath moveToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) - lineWith * 2)];
    [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) - lineWith * 2, CGRectGetHeight(rect) / 2)];

    CGContextSetLineWidth(context, lineWith);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddPath(context, crossPath.CGPath);
    CGContextDrawPath(context, kCGPathStroke);

    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:path.CGPath];
    [self.layer setMask:maskLayer];
}


- (void)fadeAnimation {
    [UIView animateWithDuration:0.4 animations:^{
        [self setAlpha:0.0];
        [self setTransform:CGAffineTransformMakeScale(2.0, 2.0)];
    } completion:^(BOOL finished) {
    }];
}
- (void)backInit {
    [self setTransform:CGAffineTransformIdentity];
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
    }];
}
@end
