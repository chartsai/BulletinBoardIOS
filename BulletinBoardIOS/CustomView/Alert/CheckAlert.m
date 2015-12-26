//
//  CheckAlert.m
//  WalletParty
//
//  Created by LEE ZHE YU on 2015/10/21.
//  Copyright © 2015年 LEE ZHE YU. All rights reserved.
//

#import "CheckAlert.h"
#import "POP.h"

typedef void(^HandlerBlock)();
@interface CheckAlert ()

@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (copy, nonatomic) HandlerBlock block;
@end

@implementation CheckAlert
+ (instancetype)alertWithTitle:(NSString *)title content:(NSString *)content handler:(void (^)())handler {
    CheckAlert *alert = [[[NSBundle mainBundle] loadNibNamed:@"CheckAlert" owner:self options:nil] firstObject];
    [alert setFrame:[UIScreen mainScreen].bounds];
    [alert.alertView.layer setMasksToBounds:YES];
    [alert.alertView.layer setCornerRadius:5.0];
    
    [alert.title setText:title];
    [alert.content setText:content];
    [alert setBlock:handler];

    POPSpringAnimation *scaleAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5f, 0.5f)];
    scaleAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.f, 1.f)];
    scaleAnim.springSpeed = 2.f;
    [alert.alertView pop_addAnimation:scaleAnim forKey:@"ScaleXY"];
    return alert;
}

- (IBAction)check:(id)sender {
    POPSpringAnimation *scaleAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.1f, 1.1f)];
    scaleAnim.springSpeed = 2.f;
    
    POPBasicAnimation *fadeAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeAnim.toValue = @(0.0);
    fadeAnim.duration = 0.3;
    [fadeAnim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    [self.alertView pop_addAnimation:scaleAnim forKey:@"ScaleXY"];
    [self pop_addAnimation:fadeAnim forKey:@"Fade"];
    
    if (self.block) {
        self.block();
    }
}

@end
