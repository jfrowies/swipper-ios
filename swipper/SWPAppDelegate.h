//
//  SWPAppDelegate.h
//  swipper
//
//  Created by fernando rowies on 8/29/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
