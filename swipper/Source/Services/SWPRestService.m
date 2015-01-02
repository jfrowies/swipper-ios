//
//  SWPLoopBackService.m
//  swipper
//
//  Created by fernando rowies on 9/1/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPRestService.h"
#import <LoopBack/LoopBack.h>
#import "LBPlace.h"
#import "LBPlaceRepository.h"
#import "SWPReview.h"
#import "JSNetworkActivityIndicatorManager.h"

@interface SWPRestService ()
@property (nonatomic, strong, readwrite) NSURL *serviceURL;
@property (nonatomic, strong) LBRESTAdapter *loopBackAdapter;
@end

@implementation SWPRestService

#pragma mark - Singleton implementation

+ (id)sharedInstance {
    static SWPRestService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#define LoopBackServiceBaseURL @"http://swipper-luciopoveda.rhcloud.com:80/api/"

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

- (void)fetchPlaceDetailWithPlaceId:(NSString *)placeId
                        success:(void (^) (SWPPlaceDetail *placeDetail))successBlock
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
                if(reviewText && ![reviewText isEqualToString:@""]) {
                    [reviewObjectsArray addObject:[SWPReview reviewWithText:reviewText andStars:reviewStars]];
                }
            }
            
            NSArray *photos = [result valueForKey:@"photos"];
            NSMutableArray *photosRequestsURLsArray = [NSMutableArray array];
            for (NSDictionary *photo in photos) {
                NSString *photoRef = [photo valueForKey:@"photo_reference"];
                [photosRequestsURLsArray addObject:[self urlForPhotoReference:photoRef]];
            }
            
            NSURL *placeURL;
            NSString *urlString = [result valueForKey:@"url"];
            if(urlString)
                placeURL = [NSURL URLWithString:urlString];

            SWPPlaceDetail *placeDetail = nil;
            if(reviewObjectsArray.count >0 || photosRequestsURLsArray.count > 0) {
                placeDetail = [SWPPlaceDetail placeDetailForPlace:placeId url:placeURL withReviews:[reviewObjectsArray copy] andPhotos:[photosRequestsURLsArray copy]];
            }
            
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
            successBlock(placeDetail);
            
        }else{
            
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
            failureBlock(connectionError);
        }
    }];
}

#define PhotosAPIKey @"AIzaSyDT_7HU59iNKx1zEQDj2wbCGP65BkoEXqs"
#define PhotoMaxWidth 300

- (NSURL *)urlForPhotoReference:(NSString *)photoReference {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=%d&photoreference=%@&key=%@", PhotoMaxWidth, photoReference, PhotosAPIKey];
    
    return [NSURL URLWithString:urlString];
}

- (void)downloadPhotoWithRequestURL:(NSURL *)url
                            success:(void (^) (UIImage *photo))successBlock
                            failure:(void (^) (NSError *error))failureBlock {
    
    [[JSNetworkActivityIndicatorManager sharedManager] startActivity];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError) {
            //obtaining the actual image URL from the response and downloading it
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:response.URL] queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if(!connectionError) {
                    [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
                    successBlock([UIImage imageWithData:data]);
                }else {
                    //TODO: retry? show error?
                    [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
                    failureBlock(connectionError);
                }
            }];
        }else {
            //TODO: retry? show error?
            [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
            failureBlock(connectionError);
        }
    }];
}

@end
