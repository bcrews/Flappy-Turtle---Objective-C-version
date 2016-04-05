//
//  ViewController.h
//  Flappy Turtle: Aquarium Adventure
//
//  Created by Bill Crews on 10/19/14.
//  Copyright (c) 2014 BC App Designs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController <ADBannerViewDelegate> {
    UIView *_contentView;
    ADBannerView *_adBannerView;
    BOOL _adBannerViewIsVisible;
}
@property (nonatomic,retain) ADBannerView *adBannerView;
@property (nonatomic,retain) IBOutlet UIView *contentView;
@property (nonatomic) BOOL adBannerViewIsVisible;
@property (nonatomic,retain) UIView *sourceView;

@end
