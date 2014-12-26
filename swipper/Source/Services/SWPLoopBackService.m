//
//  SWPLoopBackService.m
//  swipper
//
//  Created by fernando rowies on 9/1/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPLoopBackService.h"
#import <LoopBack/LoopBack.h>
#import "LBPlace.h"
#import "LBPlaceRepository.h"
#import "SWPAppDelegate.h"
#import "SWPSimpleReview.h"

@interface SWPLoopBackService ()

@property (nonatomic, strong, readwrite) NSURL *serviceURL;
@property (nonatomic, strong) LBRESTAdapter *loopBackAdapter;

@end

@implementation SWPLoopBackService

#pragma mark - Singleton implementation

+ (id)sharedInstance {
    static SWPLoopBackService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.serviceURL = [NSURL URLWithString:LoopBackServiceBaseURL];
        self.loopBackAdapter = [LBRESTAdapter adapterWithURL:self.serviceURL];
    }
    return self;
}

#pragma mark - Fetch operations


//- (void)fetchAllCategoriesSuccess:(void (^) (NSArray *categories))successBlock
//                          failure:(void (^) (NSError *error))failureBlock
//{
//    LBCategoryRepository *repository = (LBCategoryRepository *)[self.loopBackAdapter repositoryWithClass:[LBCategoryRepository class]];
//    [repository allWithSuccess:^(NSArray *models) {
//        successBlock(models);
//    } failure:^(NSError *error) {
//        failureBlock(error);
//    }];
//    
//}

- (void)fetchPlacesBetweenNorthWest:(CLLocationCoordinate2D)northWestCoordinate
                          southEast:(CLLocationCoordinate2D)southEastCoordinate
                            success:(void (^) (NSArray *places))successBlock
                            failure:(void (^) (NSError *error))failureBlock
{
    LBPlaceRepository *repository = (LBPlaceRepository *)[self.loopBackAdapter repositoryWithClass:[LBPlaceRepository class]];
    
    NSDictionary *northWestDict = @{
                                    @"lat": [NSNumber numberWithDouble:northWestCoordinate.latitude],
                                    @"lng": [NSNumber numberWithDouble:northWestCoordinate.longitude]
                                    };
    
    NSString *northWestString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:northWestDict options:0 error:nil]
                                                      encoding:NSUTF8StringEncoding];

    NSDictionary *southEastDict = @{
                                    @"lat": [NSNumber numberWithDouble:southEastCoordinate.latitude],
                                    @"lng": [NSNumber numberWithDouble:southEastCoordinate.longitude]
                                    };
    
    NSString *southEastString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:southEastDict options:0 error:nil]
                                                      encoding:NSUTF8StringEncoding];
    
    [repository invokeStaticMethod:@"nearBy"
                              parameters:@{
                                           @"northWest":northWestString,
                                           @"southEast":southEastString
                                           }
                                 success:^(id value) {
                                     NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);
                                     NSMutableArray *models = [NSMutableArray array];
                                     [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [models addObject:[repository modelWithDictionary:obj]];
                                     }];
                                     successBlock(models);
                                 }
                                 failure:^(NSError *error) { 
                                     NSLog(@"Failed to load locations with error: %@", error.description);
                                     failureBlock(error);
                                 }];
}

#define PlaceDetailsURL @"http://swipper-luciopoveda.rhcloud.com:80/api/places/details"

- (void)fetchPlaceReviewsWithPlaceId:(NSString *)placeId
                        success:(void (^) (NSArray *reviews))successBlock
                        failure:(void (^) (NSError *error))failureBlock {

    NSString *post = [NSString stringWithFormat:@"idPlace=%@",placeId];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",[postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:PlaceDetailsURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError) {
            
            NSError *deserializationError = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&deserializationError];
            NSArray *reviews = [result valueForKey:@"reviews"];
            
            NSMutableArray *reviewObjectsArray = [NSMutableArray array];
            
            for (NSDictionary *review in reviews) {
                NSString *reviewText = [review valueForKey:@"text"];
                int reviewStars = (int)[[review valueForKey:@"rating"] integerValue];
                [reviewObjectsArray addObject:[SWPSimpleReview reviewWithText:reviewText andStars:reviewStars]];
            }
            
            successBlock(reviewObjectsArray);
        }else{
            failureBlock(connectionError);
        }
    }];
    
}

@end
