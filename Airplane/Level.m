/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "Level.h"
#import "Hero.h"
#import "GameObject.h"
#import "Enemy1.h"
#import "SimpleAudioEngine.h"
#import "Bullet.h"

#define kCJScrollFilterFactor 0.1
#define kCJDragonTargetOffset 80

@implementation Level

- (id)init {

    if (self = [super init]) {
        
        [self schedule:@selector(gameLogic:) interval:0.6];
        [self schedule:@selector(shooting) interval:0.2];
        
        monsters = [[NSMutableArray alloc] init];
        bullets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)shooting {

    if (dragon.destroyed) {
        
        return;
    }
    
    int actualX = dragon.position.x + dragon.contentSize.width / 2;
    
    Bullet *bullet = (Bullet *)[CCBReader nodeGraphFromFile:@"Bullet.ccbi"];
    bullet.position = ccp(actualX, dragon.position.y + 100);
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [self addChild:bullet];
    
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:0.1f position:ccp(actualX, winSize.height)];
    
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        
        [bullets removeObject:node];
        [node removeFromParentAndCleanup:YES];
    }];
    
    [bullet runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"bullet.mp3"];
    
    [bullets addObject:bullet];
}

- (void)addMonster {
    
    //CCSprite *monster = [CCSprite spriteWithFile:@"gameArts.png" rect:(CGRect){{82, 657}, {34, 24}}];
    //CCSprite *monster = [CCSprite spriteWithFile:@"monster.png"];
    Enemy1 *monster = (Enemy1 *)[CCBReader nodeGraphFromFile:@"Enemy1.ccbi"];
    
    // Determine where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int minX = monster.contentSize.width / 2 + 20;
    int maxX = winSize.width - monster.contentSize.width / 2 - 20;
    
    //int minY = monster.contentSize.height / 2;
    //int maxY = winSize.height - monster.contentSize.height/2;
    
    int rangeX = maxX- minX;
    //int rangeY = maxY - minY;
    
    int actualX = (arc4random() % rangeX) + minX;
    //int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(actualX, winSize.height + monster.contentSize.height / 2);
    
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 0.5;
    int maxDuration = 4.0;
    
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, -monster.contentSize.height / 2)];
    
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        
        [monsters removeObject:node];
        [node removeFromParentAndCleanup:YES];
    }];
    
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    monster.tag = 1;
    [monsters addObject:monster];
    
}

- (void)gameLogic:(ccTime)dt {
    
    [self addMonster];
}


- (void)onEnter
{
    [super onEnter];
    
    // Schedule a selector that is called every frame
    [self schedule:@selector(update:)];
    
    // Make sure touches are enabled
    //self.isTouchEnabled = YES;
    [self setTouchEnabled:YES];
}

- (void)onExit
{
    [super onExit];
    
    // Remove the scheduled selector
    [self unscheduleAllSelectors];
}

- (void)restartGame {

    CCNode *child;
    
    /*
    CCARRAY_FOREACH(self.children, child)
    {
        // Check if the child is a game object
        if ([child isKindOfClass:[GameObject class]])
        {
            GameObject *gameObject = (GameObject *)child;
            
            // Check for collisions with dragon
            if (gameObject != dragon)
            {
                [gameObject removeFromParentAndCleanup:YES];
                [monsters removeObject:gameObject];
            }
        }
    }
     */
    
    NSMutableArray *gameObjectsToRemove = [NSMutableArray array];
    
    CCARRAY_FOREACH(self.children, child) {
        
        if ([child isKindOfClass:[GameObject class]] && child != dragon) {
            
            GameObject *gameObject = (GameObject*)child;
            [gameObjectsToRemove addObject:gameObject];
        }
    }
    
    for (GameObject *gameObject in gameObjectsToRemove) {
        
        [self removeChild:gameObject cleanup:YES];
    }

     
    [dragon restart];
}

- (void)update:(ccTime)delta
{
    // Iterate through all objects in the level layer
    CCNode *child;
    CCARRAY_FOREACH(self.children, child)
    {
        // Check if the child is a game object
        if ([child isKindOfClass:[GameObject class]])
        {
            GameObject *gameObject = (GameObject *)child;
            
            // Update all game objects
            [gameObject update];
            
            // Check for collisions with dragon
            if (gameObject != dragon)
            {
                if (ccpDistance(gameObject.position, dragon.position) < gameObject.radius + dragon.radius)
                {
                    if (dragon.destroyed) {
                        
                        return;
                    }
                    
                    // Notify the game objects that they have collided
                    [gameObject handleCollisionWith:dragon];
                    [dragon handleCollisionWith:gameObject];
                    
                    [monsters removeObject:gameObject];
                    [gameObject removeFromParentAndCleanup:YES];
                    
                    [self performSelector:@selector(restartGame) withObject:nil afterDelay:3.0];
                }
            }
            
            if (gameObject != dragon && ![gameObject isKindOfClass:[Bullet class]]) {
            
                for (Bullet *bullet in bullets) {
                    
                    if (ccpDistance(gameObject.position, bullet.position) < gameObject.radius + bullet.radius) {
                        
                        //[bullets removeObject:bullet];
                        [bullet removeFromParentAndCleanup:YES];
                        
                        //[monsters removeObject:gameObject];
                        [gameObject removeFromParentAndCleanup:YES];
                        
                    }
                }
            }
        }
    }
    
    // Check for objects to remove
    NSMutableArray* gameObjectsToRemove = [NSMutableArray array];
    CCARRAY_FOREACH(self.children, child)
    {
        if ([child isKindOfClass:[GameObject class]])
        {
            GameObject *gameObject = (GameObject*)child;
            
            if (gameObject.isScheduledForRemove)
            {
                [gameObjectsToRemove addObject:gameObject];
            }
        }
    }
    
    for (GameObject *gameObject in gameObjectsToRemove)
    {
        [self removeChild:gameObject cleanup:YES];
    }
    
    /*
    // Adjust the position of the layer so dragon is visible
    float yTarget = kCJDragonTargetOffset - dragon.position.y;
    CGPoint oldLayerPosition = self.position;
    
    float xNew = oldLayerPosition.x;
    float yNew = oldLayerPosition.y ;
    // kCJScrollFilterFactor + oldLayerPosition.y * (1.0f - kCJScrollFilterFactor);
    */
     
    //self.position = ccp(xNew, yNew);
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    return;
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    dragon.xTarget = touchLocation.x;
    dragon.yTarget = touchLocation.y;
}
 

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    dragon.xTarget = touchLocation.x;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    dragon.yTarget = winSize.height - touchLocation.y;
}

@end
