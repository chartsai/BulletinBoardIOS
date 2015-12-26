//
//  ViewController.m
//  BulletinBoardIOS
//
//  Created by CHA-MBP on 2015/12/26.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#define client_name @"client"
#define server_name @"server"
#import "ViewController.h"
#import "CheckAlert.h"
#import "AddBtn.h"
#import "POP.h"

@interface ViewController () {
}

@property (retain, nonatomic) SessionContainer *sessionContainer;
// TableView Data source for managing sent/received messagesz
@property (retain, nonatomic) NSMutableArray *transcripts;
// Map of resource names to transcripts array index
@property (retain, nonatomic) NSMutableDictionary *imageNameIndex;

@property (weak, nonatomic) IBOutlet AddBtn *addBtn;
@property (weak, nonatomic) IBOutlet MessageView *messageView;
@end

@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
// RFC 6335 text:
//   5.1. Service Name Syntax
//
//     Valid service names are hereby normatively defined as follows:
//
//     o  MUST be at least 1 character and no more than 15 characters long
//     o  MUST contain only US-ASCII [ANSI.X3.4-1986] letters 'A' - 'Z' and
//        'a' - 'z', digits '0' - '9', and hyphens ('-', ASCII 0x2D or
//        decimal 45)
//     o  MUST contain at least one letter ('A' - 'Z' or 'a' - 'z')
//     o  MUST NOT begin or end with a hyphen
//     o  hyphens MUST NOT be adjacent to other hyphens
//
- (BOOL)isDisplayNameAndServiceTypeValid:(NSString *)clientName serviceName:(NSString *)serviceName {        MCPeerID *peerID;
    @try {
        peerID = [[MCPeerID alloc] initWithDisplayName:clientName];
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid display name [%@]", clientName);
        return NO;
    }
    
    // Check if using this service type string causes a framework exception
    MCNearbyServiceAdvertiser *advertiser;
    @try {
        advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:nil serviceType:serviceName];
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid service type [%@]", serviceName);
        return NO;
    }
    NSLog(@"Room Name [%@] (aka service type) and display name [%@] are valid", advertiser.serviceType, peerID.displayName);
    // all exception checks passed
    return YES;
}

- (void)commonInit {
    [_messageView setDelegate:self];
    [_messageView.textView setDelegate:self];

    // Init transcripts array to use as table view data source
    _transcripts = [NSMutableArray new];
    _imageNameIndex = [NSMutableDictionary new];

    if ([self isDisplayNameAndServiceTypeValid:client_name serviceName:server_name]) {
        [self createSession];
//        if (_delegate) {
//            [_delegate controllerDidCreateChatRoomWithDisplayName:@"client" serviceType:@"server"];
//        }
    }
    else {
        CheckAlert *alert = [CheckAlert alertWithTitle:@"ERROR" content:@"" handler:nil];
        [[[UIApplication sharedApplication] keyWindow] addSubview:alert];
    }
}

- (void)createSession {
    // Create the SessionContainer for managing session related functionality.
    _sessionContainer = [[SessionContainer alloc] initWithDisplayName:client_name serviceType:server_name];
    // Set this view controller as the SessionContainer delegate so we can display incoming Transcripts and session state changes in our table view.
    _sessionContainer.delegate = self;
}

// Check if there is any message to send
- (void)sendMessageToServer:(NSString *)message {
    // Send the message
    Transcript *transcript = [self.sessionContainer sendMessage:message];

    if (transcript) {
        // Add the transcript to the table view data source and reload
        [self insertTranscript:transcript];
        [self sendCompleteAnimation];
    } else {
        [self sendFailAniamtion];
    }
}

// Helper method for inserting a sent/received message into the data source and reload the view.
// Make sure you call this on the main thread
- (void)insertTranscript:(Transcript *)transcript {
    // Add to the data source
    [_transcripts addObject:transcript];
    NSLog(@"received %@", transcript.message);

    // If this is a progress transcript add it's index to the map with image name as the key
    if (nil != transcript.progress) {
        NSNumber *transcriptIndex = [NSNumber numberWithUnsignedLong:(_transcripts.count - 1)];
        [_imageNameIndex setObject:transcriptIndex forKey:transcript.imageName];
    }

    // Update the table view
//    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([self.transcripts count] - 1) inSection:0];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];

    // Scroll to the bottom so we focus on the latest message
//    NSUInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
//    if (numberOfRows) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
}

#pragma mark - SessionContainerDelegate

- (void)receivedTranscript:(Transcript *)transcript {
    // Add to table view data source and update on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertTranscript:transcript];
    });
}

- (void)updateTranscript:(Transcript *)transcript {
    // Find the data source index of the progress transcript
    NSNumber *index = [_imageNameIndex objectForKey:transcript.imageName];
    NSUInteger idx = [index unsignedLongValue];
    // Replace the progress transcript with the image transcript
    [_transcripts replaceObjectAtIndex:idx withObject:transcript];

    // Reload this particular table view row on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//        [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - MCBrowserViewControllerDelegate methods

// Override this method to filter out peers based on application specific needs
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    return YES;
}

// Override this to know when the user has pressed the "done" button in the MCBrowserViewController
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Override this to know when the user has pressed the "cancel" button in the MCBrowserViewController
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma makr - MessageDelegate
- (void)sendMessage:(NSString *)messageString {
    [self sendMessageToServer:messageString];
}
- (void)cancel {
    [_addBtn backInit];
}

#pragma mark - TextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setReadyToSend:NO];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self setReadyToSend:YES];
}

#pragma mark - IBAction
- (IBAction)addMessage:(id)sender {
    [_addBtn fadeAnimation];
    [_messageView fadeIn];
}
- (IBAction)tap:(id)sender {
    [self.view endEditing:YES];
}
- (IBAction)messagePan:(UIPanGestureRecognizer *)sender {
    if (_readyToSend) {
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
            if (_messageView.frame.origin.y < -100 || [sender velocityInView:self.view].y < -5000) {
                [self sendMessageToServer:_messageView.textView.text];
                POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPositionY];
                anim.velocity = @([sender velocityInView:self.view].y);
                [_messageView pop_addAnimation:anim forKey:@"slide"];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    [_messageView setTransform:CGAffineTransformIdentity];
                }];
            }
        } else {
            CGPoint p = [sender translationInView:self.view];
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformRotate(transform, p.x / CGRectGetWidth(_messageView.frame) * M_1_PI / 1);
            transform = CGAffineTransformTranslate(transform, p.x, p.y);
            [_messageView setTransform:transform];
        }
    }
}

- (void)sendCompleteAnimation {
    [_addBtn backInit];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_messageView pop_removeAnimationForKey:@"slide"];
        [_messageView setTransform:CGAffineTransformIdentity];
        [_messageView setAlpha:0.0];
        [_messageView.textView setText:@""];
    });
}
- (void)sendFailAniamtion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_messageView pop_removeAnimationForKey:@"slide"];
        [UIView animateWithDuration:0.3 animations:^{
            [_messageView setTransform:CGAffineTransformIdentity];
        }];
    });
}
@end
