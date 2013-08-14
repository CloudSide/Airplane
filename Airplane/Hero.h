//
//  Hero.h
//  Airplane
//
//  Created by Bruce on 13-8-13.
//  Copyright (c) 2013年 Bruce. All rights reserved.
//

#import "GameObject.h"

@interface Hero : GameObject
{
    
    float ySpeed;
    float xTarget;
    float yTarget;
    BOOL destroyed;
}

@property (nonatomic,assign) float xTarget;
@property (nonatomic,assign) float yTarget;
@property (nonatomic, assign) BOOL destroyed;

- (void)restart;

@end
