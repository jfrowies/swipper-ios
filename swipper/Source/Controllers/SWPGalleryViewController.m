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
#import "Flurry.h"

@interface SWPGalleryViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) NSMutableDictionary *photosURLs;
@property (strong, nonatomic) NSMutableDictionary *thumbnailsURLs;
@property (strong, nonatomic) NSMutableDictionary *thumbnailsImages;
@end

@implementation SWPGalleryViewController

static NSString * const reuseIdentifierPhoto = @"PlacePhotoCell";
static NSString * const reuseIdentifierLoadingPhoto = @"PlacePhotoLoadingCell";

#pragma mark - Getters/Setters

- (void)setPhotosReferences:(NSArray *)photosReferences {
    _photosReferences = photosReferences;
    
    if(_photosReferences.count > 0) {
        self.infoView.hidden = YES;
        [self.collectionView reloadData];
        [self downloadPhotos:_photosReferences];
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
    return self.photosReferences.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reference = [self.photosReferences objectAtIndex:indexPath.row];

    if([self.thumbnailsImages objectForKey:reference]) {
        SWPPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierPhoto forIndexPath:indexPath];
        cell.placePhoto.image = [self.thumbnailsImages objectForKey:reference];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    
    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:indexPath.row];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - <MWPhotoBrowserDelegate>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photosReferences.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    NSString *reference = [self.photosReferences objectAtIndex:index];
    return [MWPhoto photoWithURL:[self.photosURLs objectForKey:reference]];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    NSString *reference = [self.photosReferences objectAtIndex:index];
    return [MWPhoto photoWithURL:[self.thumbnailsURLs objectForKey:reference]];
}

#pragma mark - Photos fetching

- (void)downloadPhotos:(NSArray *)photosReferences {
    self.photosURLs = [NSMutableDictionary dictionaryWithCapacity:photosReferences.count];
    self.thumbnailsURLs = [NSMutableDictionary dictionaryWithCapacity:photosReferences.count];
    self.thumbnailsImages = [NSMutableDictionary dictionaryWithCapacity:photosReferences.count];

    __weak SWPGalleryViewController *weakSelf = self;
    
    for (NSString *photoReference in photosReferences) {
        
        NSURL *photoRequestURL = [[SWPRestService sharedInstance] urlForPhotoReference:photoReference maxWidth:2208];
        
        [[SWPRestService sharedInstance] resolvePhotoURLWithRequestURL:photoRequestURL success:^(NSURL *photoURL) {
            [weakSelf.photosURLs setObject:photoURL forKey:photoReference];
        } failure:^(NSError *error) {
             [Flurry logError:@"RESOLVE_PHOTO_URL_ERROR" message:error.description exception:nil];
        }];
        
        NSURL *thumbnailRequestURL = [[SWPRestService sharedInstance] urlForPhotoReference:photoReference maxWidth:400];
        
        [[SWPRestService sharedInstance] resolvePhotoURLWithRequestURL:thumbnailRequestURL success:^(NSURL *photoURL) {
            
            [weakSelf.thumbnailsURLs setObject:photoURL forKey:photoReference];
            
            [[SWPRestService sharedInstance] downloadPhotoWithPhotoURL:photoURL success:^(UIImage *photo) {
                [weakSelf.thumbnailsImages setObject:photo forKey:photoReference];
                [weakSelf.collectionView reloadData];
            } failure:^(NSError *error) {
                [Flurry logError:@"DOWNLOAD_PHOTO_ERROR" message:error.description exception:nil];
            }];
            
        } failure:^(NSError *error) {
             [Flurry logError:@"RESOLVE_PHOTO_URL_ERROR" message:error.description exception:nil];
        }];
    
    }
}

@end
