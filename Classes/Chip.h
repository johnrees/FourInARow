//
//  Chip.h
//  FourInARow
//
//  Created by John Rees on 09/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Chip : CCSprite {
	BOOL isBeingDragged;
	CGPoint startPosition;
}

@property (nonatomic) BOOL isBeingDragged;
@property (nonatomic) CGPoint startPosition;
@end

@interface Player1Chip : Chip
@end

@interface Player2Chip : Chip
@end
