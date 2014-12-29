// JSNetworkActivityIndicatorManager.h

#import <Foundation/Foundation.h>

@interface JSNetworkActivityIndicatorManager : NSObject

// Get class singleton
+ (JSNetworkActivityIndicatorManager *)sharedManager;

// Show network activity indicator
// Each call adds an activity to the internal queue
- (void)startActivity;

// Hide network activity indicator
// Will not hide the indicator until all activities are complete
- (void)endActivity;

// Hide the network activity indicator
// This will hide the indicator regardless of how many activities have been started
- (void)allActivitiesComplete;

@end