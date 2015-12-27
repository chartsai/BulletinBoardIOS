//
//  ViewController.m
//  BulletinBoardIOS
//
//  Created by CHA-MBP on 2015/12/26.
//  Copyright © 2015年 bulletin board. All rights reserved.
//

#define client_name [NSString stringWithFormat:@"client%@", [[UIDevice currentDevice] name]]
#define server_name @"server"
#define server_display_name @"host"
#import "ViewController.h"
#import "CheckAlert.h"
#import "AddBtn.h"
#import "DownloadBtn.h"
#import "TextNoteView.h"
#import "NoteView.h"
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
@property (weak, nonatomic) IBOutlet DownloadBtn *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadCancelBtn;

@property (nonatomic) NSMutableArray *noteViewArray;
@property (nonatomic) NSMutableArray *historyArray;
@property (nonatomic) NSMutableArray *historyTimeArray;
@end

@implementation ViewController {
    CGAffineTransform noteTransorm;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    NSLog(@"server name : %@, client name : %@", server_name, client_name);
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
    _historyArray = [[NSMutableArray alloc] init];
    _historyTimeArray = [[NSMutableArray alloc] init];
    _noteViewArray = [[NSMutableArray alloc] init];
    [_messageView setDelegate:self];
    [_messageView.textView setDelegate:self];

    // Init transcripts array to use as table view data source
    _transcripts = [NSMutableArray new];
    _imageNameIndex = [NSMutableDictionary new];

    if ([self isDisplayNameAndServiceTypeValid:client_name serviceName:server_name]) {
        [self createSession];
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
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

        [_historyArray addObject:message];
        [_historyTimeArray addObject:[dateFormatter stringFromDate:[NSDate date]]];

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
    NSLog(@"received : %@ from %@", transcript.message, transcript.peerID.displayName);
//    if (![transcript.peerID.displayName isEqualToString:client_name] &&
//        ![transcript.peerID.displayName isEqualToString:server_name] &&
//        ![transcript.peerID.displayName isEqualToString:server_display_name]) {
//        [_historyArray addObject:transcript.message];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//        [_historyTimeArray addObject:[dateFormatter stringFromDate:[NSDate date]]];
//    }

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
    [_downloadBtn backInit];
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
    [_downloadBtn fadeAnimation];
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
- (IBAction)downloadHistoryMessage:(id)sender {
    [self startDownlaod];
    [_downloadBtn fadeAnimation];
    [_addBtn fadeAnimation];
    [UIView animateWithDuration:0.3 animations:^{
        [_downloadCancelBtn setAlpha:1.0];
    }];
}
- (IBAction)downloadCancel:(id)sender {
    [_noteViewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_noteViewArray removeAllObjects];
    [_addBtn backInit];
    [_downloadBtn backInit];
    [UIView animateWithDuration:0.3 animations:^{
        [_downloadCancelBtn setAlpha:0.0];
    }];
}

- (IBAction)noteViewPan:(UIPanGestureRecognizer *)sender {
    UIView *targetView = sender.view;
    if (sender.state == UIGestureRecognizerStateBegan) {
        noteTransorm = targetView.transform;
    }
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        anim.velocity = @([sender velocityInView:self.view].x);
        [targetView pop_addAnimation:anim forKey:@"slide"];
        POPDecayAnimation *anim2 = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        anim2.velocity = @([sender velocityInView:self.view].y);
        [targetView pop_addAnimation:anim2 forKey:@"slide2"];
    } else {
        CGPoint p = [sender translationInView:self.view];
        CGAffineTransform transform = noteTransorm;
        transform = CGAffineTransformRotate(transform, p.x / CGRectGetWidth(self.view.frame) * M_1_PI / 1);
        transform = CGAffineTransformTranslate(transform, p.x, p.y);
        [targetView setTransform:transform];
    }
}

#pragma mark - Animation
- (void)sendCompleteAnimation {
    [_addBtn backInit];
    [_downloadBtn backInit];
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

#pragma mark - Download History Message
- (void)startDownlaod {
    NSInteger totalMessage = [_historyArray count];
    for (int i = 0; i < totalMessage; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((totalMessage - i) * 0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addNoteMessage:[NSString stringWithFormat:@"%@\n\n\n\n%@", [_historyArray objectAtIndex:i], [_historyTimeArray objectAtIndex:i]] index:i];
        });
    }
}
- (void)addNoteMessage:(NSString *)string index:(int)i {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, i * M_2_PI);
    transform = CGAffineTransformTranslate(transform, 300, -200);

    CGFloat noteWidth = self.view.frame.size.width * 0.8;
    NoteView *textView = [[NoteView alloc] initWithFrame:CGRectMake(noteWidth / 8, 150, noteWidth, noteWidth * 73/80)];
    [textView setTransform:transform];
    [textView setTextString:string];
    [self.view addSubview:textView];
    [_noteViewArray addObject:textView];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(noteViewPan:)];
    [textView addGestureRecognizer:panGesture];
    [UIView animateWithDuration:0.3 animations:^{
        [textView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, i * M_1_PI / 2)];
    }];
}

@end
