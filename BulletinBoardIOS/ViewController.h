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

@interface ViewController : UIViewController <SessionContainerDelegate, MCBrowserViewControllerDelegate, MessageDelegate, UITextViewDelegate>

@property (nonatomic) BOOL readyToSend;
@end

