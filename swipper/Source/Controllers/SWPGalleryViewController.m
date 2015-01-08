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
#import "MWPhotoBrowser.h"

@interface SWPGalleryViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *images;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@end

@implementation SWPGalleryViewController

static NSString * const reuseIdentifierPhoto = @"PlacePhotoCell";
static NSString * const reuseIdentifierLoadingPhoto = @"PlacePhotoLoadingCell";

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
    
    if(indexPath.row < self.images.count) {
        SWPPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierPhoto forIndexPath:indexPath];
        cell.placePhoto.image = [self.images objectAtIndex:indexPath.row];
        return cell;
    }else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierLoadingPhoto forIndexPath:indexPath];
        return cell;
    }
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
    
    for (NSURL *url in photosRequestsURLs) {
        [[SWPRestService sharedInstance] downloadPhotoWithRequestURL:url success:^(UIImage *photo) {
            [weakSelf.images addObject:photo];
            [weakSelf.collectionView reloadData];
        } failure:^(NSError *error) {
            //TODO: show error?
        }];
    }
}

@end
