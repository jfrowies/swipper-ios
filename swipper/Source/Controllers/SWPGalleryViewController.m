//
//  SWPGalleryViewController.m
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPGalleryViewController.h"
#import "SWPPhotoCollectionViewCell.h"
#import "SWPRestService.h"

@interface SWPGalleryViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *images;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@end

@implementation SWPGalleryViewController

static NSString * const reuseIdentifier = @"PlacePhotoCell";

#pragma mark - Getters/Setters

- (void)setPhotosRequestsURLs:(NSArray *)photosRequestsURLs {
    _photosRequestsURLs = photosRequestsURLs;
    
    if(photosRequestsURLs.count > 0) {
        self.infoView.hidden = YES;
        [self.collectionView reloadData];
        [self downloadPhotos:_photosRequestsURLs];
    }else {
        self.infoView.hidden = NO;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosRequestsURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWPPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.row < self.images.count) {
        cell.placePhoto.image = [self.images objectAtIndex:indexPath.row];
    }else {
        cell.placePhoto.image = nil;
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Photos fetching

- (void)downloadPhotos:(NSArray *)photosRequestsURLs {
    self.images = [NSMutableArray arrayWithCapacity:photosRequestsURLs.count];
    __weak SWPGalleryViewController *weakSelf = self;
    
    //sending google photo request
    for (NSURL *url in photosRequestsURLs) {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if(!connectionError) {
                
                //obtaining the actual image URL from the response and downloading it
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:response.URL] queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if(!connectionError) {
                        [weakSelf.images addObject:[UIImage imageWithData:data]];
                        [weakSelf.collectionView reloadData];
                    }else {
                        //TODO: retry? show error?
                    }
                }];
                
            }else {
                //TODO: retry? show error?
            }
        }];
    }
}

@end
