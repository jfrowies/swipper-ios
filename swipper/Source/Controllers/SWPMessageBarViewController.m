//
//  SWPMessageBarViewController.m
//  swipper
//
//  Created by Fer Rowies on 12/9/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPMessageBarViewController.h"
#import "SWPMessageBarView.h"
#import "Reachability.h"

@interface SWPMessageBarViewController ()

@property (strong, nonatomic) IBOutlet SWPMessageBarView *barView;
@property (strong, nonatomic) Reachability *internetReachability;
@property (nonatomic) NetworkStatus lastKnownNetworkStatus;

@end

@implementation SWPMessageBarViewController

#define messageBarTopSpaceConstantShow 0.0f
#define messageBarTopSpaceConstantHide -30.0f
#define messageBarHeight 30.0f

#pragma mark - Getters/Setters

- (void)setMessage:(NSString *)message {
    _message = message;
    [self.barView.messageLabel setText:_message];
}

- (void)setMessageBarType:(MessageBarType)messageBarType {
    _messageBarType = messageBarType;
    
//    switch (_messageBarType) {
//        case MessageBarInfo:
//            self.barView.backgroundColor = [UIColor yellowColor];
//            break;
//        case MessageBarWarning:
//            self.barView.backgroundColor = [UIColor orangeColor];
//            break;
//        case MessageBarError:
//            self.barView.backgroundColor = [UIColor redColor];
//            break;
//        default:
//            break;
//    }
}

- (BOOL)isShowingMessage {
    if(self.barView && [self.barView.superview isEqual:self.view] && self.barView.frame.origin.y == messageBarTopSpaceConstantShow) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"SWPMessageBarView" owner:self options:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    self.lastKnownNetworkStatus = self.internetReachability.currentReachabilityStatus;
    [self.internetReachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantHide, self.view.frame.size.width, messageBarHeight)];
    if(self.internetReachability.currentReachabilityStatus == NotReachable) {
        [self updateInterfaceWithReachability:self.internetReachability];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability* currentReachability = [notification object];
    NSParameterAssert([currentReachability isKindOfClass:[Reachability class]]);
    
    NetworkStatus currentNetworkStatus = [currentReachability currentReachabilityStatus];
    
    if(self.lastKnownNetworkStatus != currentNetworkStatus) {
        [self.class cancelPreviousPerformRequestsWithTarget:self];
        self.lastKnownNetworkStatus = currentNetworkStatus;
        [self performSelector:@selector(updateInterfaceWithReachability:) withObject:currentReachability afterDelay:5.0f];
    }
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable) {
        [self showMessage:@"no internet conection" withBarType:MessageBarNoInternet animated:YES];
    } else {
        [self showMessage:@"internet connection is ok" withBarType:MessageBarInternetRestored animated:NO];
        [self hideMessageAfterDelay:2.0f Animated:YES];
    }
}


#pragma mark - Show/Hide Message

- (void)showMessage:(NSString *)message withBarType:(MessageBarType)barType animated:(BOOL)animated {
    
    if(self.messageBarType == MessageBarNoInternet && barType!= MessageBarInternetRestored)
        return;
    
    self.message = message;
    self.messageBarType = barType;
    
    if(self.isShowingMessage)
        return;
    
    [self.view addSubview:self.barView];
    [self.view layoutIfNeeded];

    if(animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantShow, self.view.frame.size.width, messageBarHeight)];
            [self.view layoutIfNeeded];
        }];
    }else {
        [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantShow, self.view.frame.size.width, messageBarHeight)];
        [self.view layoutIfNeeded];
    }
}

- (void)hideMessageAnimated:(BOOL)animated {
    
    if(!self.isShowingMessage || self.messageBarType == MessageBarNoInternet) return;
    
    if(animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantHide, self.view.frame.size.width, messageBarHeight)];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.barView removeFromSuperview];
        }];
    }else {
        [self.barView setFrame:CGRectMake(0.0f, messageBarTopSpaceConstantHide, self.view.frame.size.width, messageBarHeight)];
        [self.view layoutIfNeeded];
        [self.barView removeFromSuperview];
    }
}

- (void)hideMessageAfterDelay:(NSTimeInterval)delay Animated:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideMessageAnimated:animated];
    });
}


@end
