//
//  AchievementsHelper.m
//  Flappy Turtle - Aquarium Adventure
//
//  Created by Bill Crews on 2/5/15.
//  Copyright (c) 2015 Bill Crews. All rights reserved.
//

#import "AchievementsHelper.h"

static NSString* const
    kHappyHatchlingAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.HappyHatchling";

static NSString* const
    kFlappingFlippersAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.FlappingFlippers";

static NSString* const
    kClappingClamsAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.ClappingClams";

static NSString* const
    kBubbleBusterAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.BubbleBuster";

static NSString* const
    kStarfishSurpriseAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.StarfishSurprise";

static NSString* const
    kJellyfishSandwichAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.JellyfishSandwich";

static NSString* const
    kEACRiderAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.EACRider";

static NSString* const
    kSuperSheldonAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.SuperSheldon";

static NSString* const
    kRayRunnerAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.RayRunner";

static NSString* const
    kDancingDaphneAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.DancingDaphne";

static NSString* const
    kInkingOllieAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.InkingOllie";

static NSString* const
    kSharkAlleyAchievementId =
    @"grp.com.BCAppDesigns.FlappyTurtleAA.SharkAlley";

static const NSInteger  kHappyHatchlingAchievementPoints    =   10;
static const NSInteger  kFlappingFlippersAchievementPoints  =   20;
static const NSInteger  kClappingClamsAchievementPoints     =   30;
static const NSInteger  kBubbleBusterAchievementPoints      =   40;
static const NSInteger  kStarfishSurpriseAchievementPoints  =   50;
static const NSInteger  kJellyfishSandwichAchievementPoints =   60;
static const NSInteger  kEACRiderAchievementPoints          =   70;
static const NSInteger  kSuperSheldonAchievementPoints      =   80;
static const NSInteger  kRayRunnerAchievementPoints         =   90;
static const NSInteger  kDancingDaphneAchievementPoints     =  100;
static const NSInteger  kInkingOllieAchievementPoints       =  110;
static const NSInteger  kSharkAlleyAchievementPoints        =  120;

NSInteger  HappyHatchlingAchievementPointsCounter          =   0;
NSInteger  FlappingFlippersAchievementPointsCounter        =   0;
NSInteger  ClappingClamsAchievementPointsCounter           =   0;
NSInteger  BubbleBusterAchievementPointsCounter            =   0;
NSInteger  StarfishSurpriseAchievementPointsCounter        =   0;
NSInteger  JellyfishSandwichAchievementPointsCounter       =   0;
NSInteger  EACRiderAchievementPointsCounter                =   0;
NSInteger  SuperSheldonAchievementPointsCounter            =   0;
NSInteger  RayRunnerAchievementPointsCounter               =   0;
NSInteger  DancingDaphneAchievementPointsCounter           =   0;
NSInteger  InkingOllieAchievementPointsCounter             =   0;
NSInteger  SharkAlleyAchievementPointsCounter              =   0;


@implementation AchievementsHelper

+ (GKAchievement *)achievementEarned:(int)score
{
    
    CGFloat percent = 0;
    NSString *achievementId = @"";
    
    if (score == kHappyHatchlingAchievementPoints &&
    HappyHatchlingAchievementPointsCounter == 0) {
        achievementId = kHappyHatchlingAchievementId;
        percent = (score/kHappyHatchlingAchievementPoints) * 100;
        HappyHatchlingAchievementPointsCounter++;
        
    } else if (score == kFlappingFlippersAchievementPoints &&
    FlappingFlippersAchievementPointsCounter == 0){
        achievementId = kFlappingFlippersAchievementId;
        percent = (score/kFlappingFlippersAchievementPoints) * 100;
        FlappingFlippersAchievementPointsCounter++;
        
    } else if (score == kClappingClamsAchievementPoints &&
    ClappingClamsAchievementPointsCounter == 0){
        achievementId = kClappingClamsAchievementId;
        percent = (score/kClappingClamsAchievementPoints) * 100;
        ClappingClamsAchievementPointsCounter++;
        
    } else if (score == kBubbleBusterAchievementPoints &&
    BubbleBusterAchievementPointsCounter == 0){
        achievementId = kBubbleBusterAchievementId;
        percent = (score/kBubbleBusterAchievementPoints) * 100;
        BubbleBusterAchievementPointsCounter++;
        
    } else if (score == kStarfishSurpriseAchievementPoints &&
    StarfishSurpriseAchievementPointsCounter == 0){
        achievementId = kStarfishSurpriseAchievementId;
        percent = (score/kStarfishSurpriseAchievementPoints) * 100;
        StarfishSurpriseAchievementPointsCounter++;
        
    } else if (score == kJellyfishSandwichAchievementPoints &&
    JellyfishSandwichAchievementPointsCounter == 0){
        achievementId = kJellyfishSandwichAchievementId;
        percent = (score/kJellyfishSandwichAchievementPoints) * 100;
        JellyfishSandwichAchievementPointsCounter++;
        
    } else if (score == kEACRiderAchievementPoints &&
    EACRiderAchievementPointsCounter == 0){
        achievementId = kEACRiderAchievementId;
        percent = (score/kEACRiderAchievementPoints) * 100;
        EACRiderAchievementPointsCounter++;
        
    } else if (score == kSuperSheldonAchievementPoints &&
    SuperSheldonAchievementPointsCounter == 0){
        achievementId = kSuperSheldonAchievementId;
        percent = (score/kSuperSheldonAchievementPoints) * 100;
        SuperSheldonAchievementPointsCounter++;
        
    } else if (score == kRayRunnerAchievementPoints &&
    RayRunnerAchievementPointsCounter == 0){
        achievementId = kRayRunnerAchievementId;
        percent = (score/kRayRunnerAchievementPoints) * 100;
        RayRunnerAchievementPointsCounter++;
        
    } else if (score == kDancingDaphneAchievementPoints &&
    DancingDaphneAchievementPointsCounter == 0){
        achievementId = kDancingDaphneAchievementId;
        percent = (score/kDancingDaphneAchievementPoints) * 100;
        DancingDaphneAchievementPointsCounter++;
        
    } else if (score == kInkingOllieAchievementPoints &&
    InkingOllieAchievementPointsCounter == 0){
        achievementId = kInkingOllieAchievementId;
        percent = (score/kInkingOllieAchievementPoints) * 100;
        InkingOllieAchievementPointsCounter++;
        
    } else if (score == kSharkAlleyAchievementPoints &&
    SharkAlleyAchievementPointsCounter == 0){
        achievementId = kSharkAlleyAchievementId;
        percent = (score/kSharkAlleyAchievementPoints) * 100;
        SharkAlleyAchievementPointsCounter++;
        
    }
    
    GKAchievement *achievementEarned =
    [[GKAchievement alloc] initWithIdentifier:achievementId];
    
    achievementEarned.percentComplete = percent;
    achievementEarned.showsCompletionBanner = YES;

    
    return achievementEarned;
}

+ (void)resetAchievementPointsCounter
{
    HappyHatchlingAchievementPointsCounter          =   0;
    FlappingFlippersAchievementPointsCounter        =   0;
    ClappingClamsAchievementPointsCounter           =   0;
    BubbleBusterAchievementPointsCounter            =   0;
    StarfishSurpriseAchievementPointsCounter        =   0;
    JellyfishSandwichAchievementPointsCounter       =   0;
    EACRiderAchievementPointsCounter                =   0;
    SuperSheldonAchievementPointsCounter            =   0;
    RayRunnerAchievementPointsCounter               =   0;
    DancingDaphneAchievementPointsCounter           =   0;
    InkingOllieAchievementPointsCounter             =   0;
    SharkAlleyAchievementPointsCounter              =   0;
 
}

@end
