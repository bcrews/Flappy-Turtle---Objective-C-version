//
//  AchievementsHelper.h
//  Flappy Turtle - Aquarium Adventure
//
//  Created by Bill Crews on 2/5/15.
//  Copyright (c) 2015 Bill Crews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h> 

@interface AchievementsHelper: NSObject

+ (GKAchievement *)achievementEarned:(int)score;
+ (void)resetAchievementPointsCounter;

@end
