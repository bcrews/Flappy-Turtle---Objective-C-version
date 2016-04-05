//
//  ViewController.m
//  Flappy Turtle: Aquarium Adventure
//
//  Created by Bill Crews on 10/19/14.
//  Copyright (c) 2014 BC App Designs, LLC. All rights reserved.
//


#import "ViewController.h"
#import "MyScene.h"
#import "SharingActivityProvider.h"
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
#import "GameKitHelper.h"

@import AVFoundation;

@interface ViewController() <MySceneDelegate>

@end


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
  /* Retrieve scene file path from the application bundle */
  NSString *nodePath =
  [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
  
  /* Unarchive the file to an SKScene object */
  NSData *data = [NSData dataWithContentsOfFile:nodePath
                                        options:NSDataReadingMappedIfSafe
                                          error:nil];
  NSKeyedUnarchiver *arch =
  [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  
  [arch setClass:self forClassName:@"SKScene"];
  SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
  [arch finishDecoding];
  
  return scene;
}

@end


@implementation ViewController

@synthesize contentView             = _contentView;
@synthesize adBannerView            = _adBannerView;
@synthesize adBannerViewIsVisible   = _adBannerViewIsVisible;

- (void)viewDidLoad
{
  
  [super viewDidLoad];
  
  
  _adBannerView.delegate  = self;
  _adBannerView.hidden    = YES;
  
  SKView * skView = (SKView *) self.originalContentView;
  skView.showsFPS = NO;
  skView.showsNodeCount = NO;
  skView.showsPhysics   = NO;
  
  /* Sprite Kit applies additional optimizations to improve rendering performance */
  skView.ignoresSiblingOrder = YES;
  
  // Create and configure the scene.
  //    MyScene *scene = [MyScene unarchiveFromFile:@"MyScene"];
  SKScene *scene;
  if ([UIScreen mainScreen].scale > 2.1) {
    scene = [[MyScene alloc] initWithSize:CGSizeMake(skView.bounds.size.width,
                                                     skView.bounds.size.height)
                            sceneDelegate:self
                                    state:GameStateMainMenu];
    
  } else {
    scene = [[MyScene alloc] initWithSize:skView.bounds.size
                              sceneDelegate:self
                              state:GameStateMainMenu];
  }
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  
  // Present the scene.
  [skView presentScene:scene];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(showAuthenticationViewController)
   name:PresentAuthenticationViewController
   object:nil];
  
  [[GameKitHelper sharedGameKitHelper]
   authenticateLocalPlayer];
  
  // iAd's
  self.canDisplayBannerAds = YES;
}

-(void)viewWillLayoutSubviews {
  
  
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

-(UIImage *)screenshot  {
  
  UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1.0);
  [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
  UIImage *image  = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

-(void)shareString:(NSString *)string score:(int)score url:(NSURL *)url image:(UIImage *)image {
  
  // This section was used for basic sharing when no customization was needed
  
  // Create the custom activity provider
  SharingActivityProvider *sharingActivityProvider = [[SharingActivityProvider alloc] initWithPlaceholderItem:@""];
  
  // put the activity provider (for the text), the image, and the URL together in an array
  NSArray *activityProviders = @[sharingActivityProvider, image, url];
  
  // Create the activity view controller passing in the activity provider, image and url we want to share
  UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                      initWithActivityItems:activityProviders
                                                      applicationActivities:nil];
  
  NSString *subject = [NSString stringWithFormat:@"I scored %d points in "
                       "Flappy Turtle: Aquarium Adventure",score];
  
  [activityViewController setValue:subject forKey:@"subject"];
  
  [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                          BOOL completed,
                                                          NSArray *returnedItems,
                                                          NSError *activityError)
   {
     // Here to check what activity.
     if ([activityType isEqualToString:UIActivityTypeMail]) {
       //  NSLog(@"Mail");
     } else if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
       //  NSLog(@"Facebook");
     } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
       NSLog(@"Twitter");
     }
     
   }];
  
  
  // tell the activity view controller which activities should NOT appear
  activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                   UIActivityTypeCopyToPasteboard,
                                                   UIActivityTypeAssignToContact];
  
  // display the options for sharing
  activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  [self presentViewController:activityViewController animated:YES completion:nil];
  
  // IOS 8+
  if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
    UIPopoverPresentationController *presentationController =
      [activityViewController popoverPresentationController];
    
    presentationController.sourceView = self.view;
  }
}


#pragma mark - ADBannerViewDelegate

- (void)displayBannerAds:(BOOL)controlFlag {
  if (controlFlag == TRUE) {
    self.canDisplayBannerAds = YES;
  }
  if (controlFlag == FALSE) {
    self.canDisplayBannerAds = NO;
  }
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
  _adBannerView.hidden = FALSE;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
  _adBannerView.hidden = YES;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
  NSLog(@"Banner view is beginning an ad action");
  
  // pause audio
  [[AVAudioSession sharedInstance] setActive:NO withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
  
  return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
  NSLog(@"Banner view is finishing an ad action");
  
  // resume audio
  [[AVAudioSession sharedInstance] setActive:YES error:nil];
  
}

- (void)showAuthenticationViewController
{
  GameKitHelper *gameKitHelper =
  [GameKitHelper sharedGameKitHelper];
  
  [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
