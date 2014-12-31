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
#import "JSNetworkActivityIndicatorManager.h"

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
    
    [[JSNetworkActivityIndicatorManager sharedManager] startActivity];
    
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
                                     
                                     [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
                                     
                                     successBlock(models);
                                 }
                                 failure:^(NSError *error) { 
                                     NSLog(@"Failed to load locations with error: %@", error.description);
                                     
                                     [[JSNetworkActivityIndicatorManager sharedManager] endActivity];

                                     
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
    
    [[JSNetworkActivityIndicatorManager sharedManager] startActivity];

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
            
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
            
            successBlock(reviewObjectsArray);
        }else{
            
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];

            failureBlock(connectionError);
        }
    }];
}

- (void)fetchPlacePhotosURLsWithPlaceId:(NSString *)placeId
                             success:(void (^) (NSArray *photosURLs))successBlock
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
    
    [[JSNetworkActivityIndicatorManager sharedManager] startActivity];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError) {
            
            NSError *deserializationError = nil;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&deserializationError];
            NSArray *photos = [result valueForKey:@"photos"];
            
            NSMutableArray *photosRequestsURLsArray = [NSMutableArray array];
            
            for (NSDictionary *photo in photos) {
                NSString *photoRef = [photo valueForKey:@"photo_reference"];
                
                [photosRequestsURLsArray addObject:[self urlForPhotoReference:photoRef]];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *photosURLs = [self fetchPlacePhotosURLsWithGoogleRequests:photosRequestsURLsArray];
                
                [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
                
                successBlock(photosURLs);
            });
    
        }else{
            
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
            
            failureBlock(connectionError);
        }
    }];
}

- (NSArray *)fetchPlacePhotosURLsWithGoogleRequests:(NSArray *)googleRequests {
    
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:googleRequests.count];
    
    for (NSURL *googleRequest in googleRequests) {
        NSHTTPURLResponse *response;
        NSError *error;
        [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:googleRequest] returningResponse:&response error:&error];
        if(!error) {
            [urls addObject:response.URL];
        }
        
    }
    return urls;
}

#define PhotosAPIKey @"AIzaSyDT_7HU59iNKx1zEQDj2wbCGP65BkoEXqs"
#define PhotoMaxWidth 300

- (NSURL *)urlForPhotoReference:(NSString *)photoReference {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%d&photoreference=%@&key=%@", PhotoMaxWidth, photoReference, PhotosAPIKey];
    
    return [NSURL URLWithString:urlString];
}

@end
