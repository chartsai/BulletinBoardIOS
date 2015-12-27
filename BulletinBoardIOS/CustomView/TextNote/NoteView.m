//
//  NoteView.m
//  BulletinBoardIOS
//
//  Created by LEE ZHE YU on 2015/12/27.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#import "NoteView.h"

@implementation NoteView

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
    [self setBackgroundColor:[UIColor clearColor]];
}
- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"note"] drawInRect:rect];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attr = @{NSParagraphStyleAttributeName:paragraphStyle,
                           NSFontAttributeName:[UIFont systemFontOfSize:12.0f],
                           NSForegroundColorAttributeName:[UIColor blackColor]};
    [_textString drawAtPoint:CGPointMake(20, 20) withAttributes:attr];
}

@end
