//
//  Hero.m
//  Airplane
//
//  Created by Bruce on 13-8-13.
//  Copyright (c) 2013年 Bruce. All rights reserved.
//

#import "Hero.h"
#import "GameScene.h"
#import "CCBAnimationManager.h"
#import "Enemy1.h"
#import "SimpleAudioEngine.h"

#define kCJStartSpeed 8
#define kCJCoinSpeed 8
#define kCJStartTarget 160

#define kCJTargetFilterFactor 0.05
#define kCJSlowDownFactor 0.995
#define kCJGravitySpeed 0.1
#define kCJGameOverSpeed -10
#define kCJDeltaToRotationFactor 0//5

@implementation Hero

@synthesize xTarget;
@synthesize yTarget;
@synthesize destroyed;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    xTarget = kCJStartTarget;
    yTarget = 91;
    ySpeed = kCJStartSpeed;
    
    destroyed = NO;
    
    return self;
}

- (void)update
{
    if (self.destroyed) {
        
        return;
    }
    
    // Calculate new position
    CGPoint oldPosition = self.position;
    
    float xNew = xTarget * kCJTargetFilterFactor + oldPosition.x * (1-kCJTargetFilterFactor);
    //float yNew = oldPosition.y + ySpeed;
    float yNew = yTarget * kCJTargetFilterFactor + oldPosition.y * (1-kCJTargetFilterFactor);
    
    self.position = ccp(xNew, yNew);
    
    // Update the vertical speed
    ySpeed = (ySpeed - kCJGravitySpeed) * kCJSlowDownFactor;
    
    // Tilt the dragon depending on horizontal speed
    float xDelta = xNew - oldPosition.x;
    self.rotation = xDelta * kCJDeltaToRotationFactor;
    
    // Check for game over
    if (ySpeed < kCJGameOverSpeed)
    {
        [[GameScene sharedScene] handleGameOver];
    }
}

- (void)restart {
    
    CCBAnimationManager* animationManager = self.userObject;
    NSLog(@"animationManager: %@", animationManager);
    [animationManager runAnimationsForSequenceNamed:@"fly"];

    xTarget = 160.0;
    yTarget = 91.0;
    
    self.position = ccp(160, 91);
    
    destroyed = NO;
}


- (void)handleCollisionWith:(GameObject *)gameObject
{
    
    if (!destroyed && [gameObject isKindOfClass:[Enemy1 class]]) {
        
        NSLog(@"撞了");
        
        destroyed = YES;
        
        CCBAnimationManager* animationManager = self.userObject;
        NSLog(@"animationManager: %@", animationManager);
        [animationManager runAnimationsForSequenceNamed:@"blowup"];
        [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.mp3"];
    }
    
    /*
    if ([gameObject isKindOfClass:[Coin class]])
    {
        // Took a coin
        ySpeed = kCJCoinSpeed;
        
        [GameScene sharedScene].score += 1;
    }
    else if ([gameObject isKindOfClass:[Bomb class]])
    {
        // Hit a bomb
        if (ySpeed > 0) ySpeed = 0;
        
        CCBAnimationManager* animationManager = self.userObject;
        NSLog(@"animationManager: %@", animationManager);
        [animationManager runAnimationsForSequenceNamed:@"Hit"];
    }
     */
}


- (float) radius
{
    return 30;
}


@end
