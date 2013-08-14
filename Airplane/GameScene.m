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

#import "GameScene.h"
#import "CCBReader.h"
#import "SimpleAudioEngine.h"

#define kPicMoveBy [CCMoveBy actionWithDuration:1.0f position:ccp(0, -567)]

static GameScene *sharedScene;

@implementation GameScene

@synthesize score;
@synthesize background1;
@synthesize background2;

+ (GameScene *)sharedScene
{
    return sharedScene;
}



- (void)actionFinishedWithSprite:(CCSprite *)theSprite {
    
    if (theSprite.position.y == -567){
        
        [theSprite setPosition:ccp(0, 567)];
    }
    
    CCCallBlock *picFinish = [CCCallBlock actionWithBlock:^(void){[self actionFinishedWithSprite:theSprite];}];
    [theSprite runAction:[CCSequence actions:kPicMoveBy, picFinish, nil]];
}

- (id)init {

    if (self = [super init]) {
    
        background1 = [CCSprite spriteWithFile:@"gameArts.png" rect:(CGRect){{0, 0}, {320, 568}}];
        background2 = [CCSprite spriteWithFile:@"gameArts.png" rect:(CGRect){{0, 0}, {320, 568}}];
        
        background1.anchorPoint = ccp(0, 0);
        background2.anchorPoint = ccp(0, 0);
        
        background1.position = ccp(0, 0);
        background2.position = ccp(0, 567);
        
        [self addChild:background1];
        [self addChild:background2];
        
        //CCMoveBy *pic1MoveBy=[CCMoveBy actionWithDuration:1.0f position:ccp(0,-320)];
        //CCMoveBy *pic2MoveBy=[CCMoveBy actionWithDuration:1.0f position:ccp(0,-320)];
        
        CCCallBlock *pic1Finish = [CCCallBlock actionWithBlock:^(void){[self actionFinishedWithSprite:background1];}];
        CCCallBlock *pic2Finish = [CCCallBlock actionWithBlock:^(void){[self actionFinishedWithSprite:background2];}];
        
        [background1 runAction:[CCSequence actions:kPicMoveBy, pic1Finish, nil]];
        [background2 runAction:[CCSequence actions:kPicMoveBy, pic2Finish, nil]];
    }
    
    return self;
}

- (void) didLoadFromCCB
{
    
    sharedScene = self;
    
    self.score = 0;
    
    // Load the level
    level = [CCBReader nodeGraphFromFile:@"Level.ccbi"];
    
    // And add it to the game scene
    [levelLayer addChild:level];
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3"];
}

- (void) setScore:(int)s
{
    score = s;
    [scoreLabel setString:[NSString stringWithFormat:@"%d", s]];
}


- (void) handleGameOver
{
    //[[CCDirector sharedDirector] replaceScene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]];
}

- (void) handleLevelComplete
{
    //[[CCDirector sharedDirector] replaceScene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]];
}


- (void) dealloc
{
	
    [background1 release];
    [background2 release];
    
    [super dealloc];
}

@end
