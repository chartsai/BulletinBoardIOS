//
//  ViewController.h
//  BulletinBoardIOS
//
//  Created by CHA-MBP on 2015/12/26.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionContainer.h"
#import "MessageView.h"
#import "Transcript.h"

@protocol SettingsDelegate <NSObject>

- (void)controllerDidCreateChatRoomWithDisplayName:(NSString *)displayName serviceType:(NSString *)serviceType;

@end

@interface ViewController : UIViewController <SessionContainerDelegate, MCBrowserViewControllerDelegate, MessageDelegate, UITextViewDelegate>

@property (weak, nonatomic) id<SettingsDelegate> delegate;
@property (nonatomic) BOOL readyToSend;
@end

