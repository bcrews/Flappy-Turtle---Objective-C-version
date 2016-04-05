//
//  MyScene.h
//  Flappy Turtle: Aquarium Adventure
//
//  Created by Bill Crews on 10/19/14.
//  Copyright (c) 2014 BC App Designs, LLC. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(int, GameState) {
    GameStateMainMenu,
    GameStateTutorial,
    GameStatePlay,
    GameStateFalling,
    GameStateShowingScore,
    GameStateGameOver
};

@protocol MySceneDelegate

-(UIImage *)screenshot;
-(void)shareString:(NSString *)string score:(int)score url:(NSURL *)url image:(UIImage *)image;
-(void)displayBannerAds:(BOOL)controlFlag;
@end

@interface MyScene : SKScene

-(id)initWithSize:(CGSize)size sceneDelegate:(id<MySceneDelegate>)sceneDelegate state:(GameState)state;

@property (strong,nonatomic) id<MySceneDelegate> sceneDelegate;

@end
