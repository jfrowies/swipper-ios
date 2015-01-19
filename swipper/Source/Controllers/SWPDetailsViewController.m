//
//  SWPDetailsViewController.m
//  swipper
//
//  Created by Fernando Rowies on 12/19/14.
//  Copyright (c) 2014 Globant Labs. All rights reserved.
//

#import "SWPDetailsViewController.h"
#import <MapKit/MKMapItem.h>
#import "MapKit/MKUserLocation.h"
#import "SWPReviewsViewController.h"
#import "SWPGalleryViewController.h"
#import "SWPLoadingViewController.h"
#import <MessageUI/MessageUI.h>
#import "JSNetworkActivityIndicatorManager.h"
#import "SWPPlaceDetail.h"
#import "SWPRestService.h"

@interface SWPDetailsViewController () <MFMailComposeViewControllerDelegate, SWPReviewsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *placePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeDistanceLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *howToArriveBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *phoneBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reportBarButton;
@property (strong, nonatomic) SWPLoadingViewController *loadingViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) SWPPlaceDetail *placeDetails;
@property (weak, nonatomic) SWPReviewsViewController *reviewsViewController;
@property (weak, nonatomic) SWPGalleryViewController *galleryViewController;
@property (weak, nonatomic) IBOutlet UIImageView *categoryBarButtonImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsHeaderHeightConstraint;

@end

@implementation SWPDetailsViewController

#pragma mark - Getters/Setters

- (void)setPlace:(id<SWPPlace>)place {
    _place = place;
    [self loadPlaceDetail];
}

- (void)setPlaceDetails:(SWPPlaceDetail *)placeDetails {
    _placeDetails = placeDetails;
    if(_placeDetails) {
        self.infoView.hidden = YES;
        if(_placeDetails.placeURL) {
            self.shareBarButton.enabled = YES;
        }
        self.reviewsViewController.reviews = _placeDetails.reviews;
        self.galleryViewController.photosReferences = _placeDetails.photosReferences;
    }
}

- (SWPLoadingViewController *)loadingViewController {
    if(!_loadingViewController) {
        _loadingViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loadingViewController"];
    }
    return _loadingViewController;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.place.placeName;
    
    self.navigationController.navigationBar.tintColor= [UIColor whiteColor];
    
    self.placeAddressLabel.text = self.place.placeAddress;
    self.placeCityLabel.text = [NSString stringWithFormat:@"%@, %@, %@",self.place.placeCity,self.place.placeState,self.place.placeCountry];
    self.placePhoneNumberLabel.text = self.place.placePhone;
    self.categoryBarButtonImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@PinImage",self.place.placeCategory]];
    
    CLLocation *startLocation = self.userLocation.location;
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[self.place placeCoordinate].latitude longitude:[self.place placeCoordinate].longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    [self.placeDistanceLabel setText:[NSString stringWithFormat:@"%.1f km",distance / 1000]];
    
    if(!self.place.placePhone || [self.place.placePhone isEqualToString:@""]) {
        self.phoneBarButton.enabled = NO;
    }else{
        self.phoneBarButton.enabled = YES;
    }
    
    self.shareBarButton.enabled = NO;
    
    self.infoView.hidden = NO;
    self.loadingView.hidden = NO;
    
    CGFloat headerHeight = [self calculateHeaderHightForWidth:self.view.frame.size.width];
    [self setDetailsHeaderHeight:headerHeight animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppStateTransition) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppStateTransition) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.loadingViewController.isBeingPresented) {
        [self.loadingViewController hideLoadingViewControllerAnimated:YES];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self setDetailsHeaderHeight:[self calculateHeaderHightForWidth:size.width] animated:NO];
    
    self.placeAddressLabel.preferredMaxLayoutWidth = size.width;
    self.placeCityLabel.preferredMaxLayoutWidth = size.width;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"ReviewsSegue"]) {
        if([segue.destinationViewController isKindOfClass:[SWPReviewsViewController class]]) {
            SWPReviewsViewController *dvc = (SWPReviewsViewController *)segue.destinationViewController;
            self.reviewsViewController = dvc;
            self.reviewsViewController.delegate = self;
        }
    }
    
    if([segue.identifier isEqualToString:@"GallerySegue"]) {
        if([segue.destinationViewController isKindOfClass:[SWPGalleryViewController class]]) {
            SWPGalleryViewController *dvc = (SWPGalleryViewController *)segue.destinationViewController;
            self.galleryViewController = dvc;
        }
    }
}

#pragma mark - Event handling

- (void)handleAppStateTransition {
    if(self.loadingViewController.isBeingPresented) {
        [self.loadingViewController hideLoadingViewControllerAnimated:NO];
        self.backButton.enabled = YES;
    }
}

#pragma mark - Actions

- (IBAction)didTouchedBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTouchedHowToArriveBarButton:(UIBarButtonItem *)sender {
    
    id<SWPPlace> place = self.place;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[place placeCoordinate].latitude longitude:[place placeCoordinate].longitude];
    
    self.loadingViewController.message = @"Launching maps app";
    self.loadingViewController.showSpinner = YES;
    [self.loadingViewController presentLoadingViewControllerInViewController:self andView:self.view animated:YES];
    
    self.backButton.enabled = NO;
    
    [[JSNetworkActivityIndicatorManager sharedManager] startActivity];
    
    __weak SWPDetailsViewController *weakSelf = self;
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [[JSNetworkActivityIndicatorManager sharedManager] endActivity];
        
        if (weakSelf.isViewLoaded && weakSelf.view.window) {
            if(!error) {
                //launching maps app
                MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:placemarks.firstObject];
                NSArray *mapItems = [NSArray arrayWithObject:destinationMapItem];
                NSDictionary *launchOptions = [NSDictionary dictionaryWithObject:MKLaunchOptionsDirectionsModeWalking forKey:MKLaunchOptionsDirectionsModeKey];
                [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
            } else {
                //show error and hide loading vc
                self.loadingViewController.message = @"Error loading address";
                self.loadingViewController.showSpinner = NO;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.backButton.enabled = YES;
                    [self.loadingViewController hideLoadingViewControllerAnimated:YES];
                });
            }
        }
    }];
}

- (IBAction)didTouchedPhoneCallBarButton:(UIBarButtonItem *)sender {
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel://%@", self.place.placePhone]];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)didTouchedShareBarButton:(UIBarButtonItem *)sender {
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[self.place.placeName,self.placeDetails.placeURL]
                                      applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList] ;
    
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
}

- (IBAction)didTouchedSendReportBarButton:(UIBarButtonItem *)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        id<SWPPlace> place = self.place;
        NSString *mailBody = [NSString stringWithFormat:@"<b>%@</b><br>%@<br>%@<br>%@<br><br>What's the problem?",place.placeName,place.placeAddress,[NSString stringWithFormat:@"%@, %@, %@",place.placeCity,place.placeState,place.placeCountry],place.placePhone];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Swipper Report"];
        [mail setMessageBody:mailBody isHTML:YES];
        [mail setToRecipients:@[@"swipper-contact@globant.com"]];
        [self presentViewController:mail animated:YES completion:NULL];
    }
//    else
//    {
//        NSLog(@"This device cannot send email");
//    }
//    
}

#pragma mark - <MFMailComposeViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
//    switch (result) {
//        case MFMailComposeResultSent:
//            NSLog(@"You sent the email.");
//            break;
//        case MFMailComposeResultSaved:
//            NSLog(@"You saved a draft of this email");
//            break;
//        case MFMailComposeResultCancelled:
//            NSLog(@"You cancelled sending this email.");
//            break;
//        case MFMailComposeResultFailed:
//            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
//            break;
//        default:
//            NSLog(@"An error occurred when trying to compose this email");
//            break;
//    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Service Calls

- (void)loadPlaceDetail{
    self.loadingView.hidden = NO;
    [[SWPRestService sharedInstance] fetchPlaceDetailWithPlaceId:self.place.placeId success:^(SWPPlaceDetail *placeDetail) {
        self.loadingView.hidden = YES;
        if (placeDetail) {
            self.placeDetails = placeDetail;
        }
    } failure:^(NSError *error) {
        //TODO: handle error properly
        self.loadingView.hidden = YES;
    }];
}

#pragma mark - Header configuration

- (CGFloat)calculateHeaderHightForWidth:(CGFloat)headerWidth{
    
    id<SWPPlace> place = self.place;
    
    NSDictionary *placeAddressAtributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:@"HelveticaNeue" size:15.0], NSFontAttributeName,
                                           nil];
    
    NSMutableAttributedString *placeDistanceString = [[NSMutableAttributedString alloc] initWithString:self.placeDistanceLabel.text attributes:placeAddressAtributes];
    
    CGRect placeDistanceRect = [placeDistanceString boundingRectWithSize:CGSizeMake(headerWidth, 999) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGSize constrainedSizeForAddress = CGSizeMake(headerWidth - 39, 999);
    CGSize constrainedSizeForCity = CGSizeMake(headerWidth - placeDistanceRect.size.width - 55, 999);
    
    NSMutableAttributedString *placeAddressString = [[NSMutableAttributedString alloc] initWithString:place.placeAddress attributes:placeAddressAtributes];
    NSMutableAttributedString *placeCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@, %@",place.placeCity,place.placeState,place.placeCountry] attributes:placeAddressAtributes];
    
    CGRect placeAddressRect = [placeAddressString boundingRectWithSize:constrainedSizeForAddress options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGRect placeCityRect = [placeCityString boundingRectWithSize:constrainedSizeForCity options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return   placeAddressRect.size.height + placeCityRect.size.height + 32;
}

#define headerHeightAnimationDuration 0.2

- (void)setDetailsHeaderHeight:(CGFloat)height animated:(BOOL)animated {
    
    if(animated) {
        [UIView animateWithDuration:headerHeightAnimationDuration animations:^{
            self.detailsHeaderHeightConstraint.constant = height;
            [self.view layoutIfNeeded];
        }];
    } else {
        self.detailsHeaderHeightConstraint.constant = height;
        [self.view layoutIfNeeded];
    }
}

#pragma mark - <SWPReviewsViewControllerDelegate>

- (CGFloat)reviewsViewController:(SWPReviewsViewController *)reviewsViewController topInsetForViewWidth:(CGFloat)width {
    return [self calculateHeaderHightForWidth:width];
}

@end
