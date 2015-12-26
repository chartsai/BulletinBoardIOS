//
//  MessageTextView.h
//  BulletinBoardIOS
//
//  Created by LEE ZHE YU on 2015/12/26.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageDelegate <NSObject>

- (void)sendMessage:(NSString *)messageString;
- (void)cancel;

@end
IB_DESIGNABLE
@interface MessageView : UIView

@property (weak, nonatomic) id<MessageDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (void)fadeIn;
@end
