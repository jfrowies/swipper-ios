//
//  SWPGalleryViewController.m
//  swipper
//
//  Created by Fer Rowies on 12/21/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPGalleryViewController.h"
#import "SWPPhotoCollectionViewCell.h"

@interface SWPGalleryViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *images;
@end

@implementation SWPGalleryViewController

static NSString * const reuseIdentifier = @"PlacePhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [NSMutableArray arrayWithCapacity:self.photosURLs.count];
    
    NSMutableArray *testURLs = [NSMutableArray arrayWithCapacity:5];
    [testURLs addObject:[NSURL URLWithString:@"http://www.amerian.com/image/hotel/2014/02/0335261-amerianhotelcasinogalaresistenciachaco.jpg"]];
    [testURLs addObject:[NSURL URLWithString:@"http://www.hotelcasinogala.com.ar/slide/s5.jpg"]];
    [testURLs addObject:[NSURL URLWithString:@""]];

    [testURLs addObject:[NSURL URLWithString:@""]];

    [testURLs addObject:[NSURL URLWithString:@""]];
    
    self.photosURLs = [testURLs copy];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //start downloading photos
    [self downloadPhotos:self.photosURLs];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWPPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.row < self.images.count) {
        cell.placePhoto.image = [self.images objectAtIndex:indexPath.row];
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

#pragma mark -

- (void)downloadPhotos:(NSArray *)photosURLs {
    __weak SWPGalleryViewController *weakSelf = self;
    for (NSURL *url in photosURLs) {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if(!connectionError) {
                [weakSelf.images addObject:[UIImage imageWithData:data]];
                [weakSelf.collectionView reloadData];
            }
        }];
    }
}

@end
