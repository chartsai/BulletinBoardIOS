//
//  CheckAlert.h
//  WalletParty
//
//  Created by LEE ZHE YU on 2015/10/21.
//  Copyright © 2015年 LEE ZHE YU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckAlert : UIView

+ (instancetype)alertWithTitle:(NSString *)title content:(NSString *)content handler:(void(^ __nullable)())handler;

@end

NS_ASSUME_NONNULL_END