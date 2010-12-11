//
//  Chip.m
//  FourInARow
//
//  Created by John Rees on 09/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Chip.h"


@implementation Chip
@synthesize isBeingDragged, startPosition;
@end

@implementation Player1Chip
-(id) init
{
	if ((self = [super init]))
	{
		startPosition = ccp(40,40);
	}
	return self;
}
@end

@implementation Player2Chip
-(id) init
{
	if ((self = [super init]))
	{
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		startPosition = ccp(winSize.width - 40,40);
	}
	return self;
}
@end