//
//  AddBtn.m
//  BulletinBoardIOS
//
//  Created by LEE ZHE YU on 2015/12/26.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#import "AddBtn.h"
#import "POP.h"

@implementation AddBtn {
    BOOL stopAnimation;
}

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
    [self waitAnimatin];
}

- (void)waitAnimatin {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.duration = 0.4;
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.2)];
    POPBasicAnimation *scaleAnimation2 = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation2.duration = 0.7;
    scaleAnimation2.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];

    [scaleAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [self pop_addAnimation:scaleAnimation2 forKey:@"scaleAnimation"];
    }];
    [scaleAnimation2 setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimation2"];
    }];
    [self pop_addAnimation:scaleAnimation forKey:@"scalingUp"];
}

- (void)fadeAnimation {
    [UIView animateWithDuration:0.4 animations:^{
        [self setAlpha:0.0];
        [self setTransform:CGAffineTransformMakeScale(2.0, 2.0)];
    } completion:^(BOOL finished) {
    }];
}

- (void)backInit {
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat lineWith = 12;
    UIBezierPath *crossPath = [UIBezierPath bezierPath];
    [crossPath moveToPoint:CGPointMake(lineWith * 2, (CGRectGetHeight(rect)) / 2)];
    [crossPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) - lineWith * 2, (CGRectGetHeight(rect)) / 2)];
    [crossPath moveToPoint:CGPointMake((CGRectGetWidth(rect)) / 2, lineWith * 2)];
    [crossPath addLineToPoint:CGPointMake((CGRectGetWidth(rect)) / 2, CGRectGetHeight(rect) - lineWith * 2)];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineWidth = lineWith;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.strokeEnd = 0.f;
    shapeLayer.path = crossPath.CGPath;

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

@end
