#import "GameLayer.h"
#import "GameComponents.h"

@implementation GameLayer

+(id) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		BoardLayer *boardLayer = [[[BoardLayer alloc] initWithColumns:7 andRows: 6] autorelease];
		[self addChild:boardLayer];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}
@end
