//
//  Board.m
//  FourInARow
//
//  Created by John Rees on 08/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameComponents.h"
#import "Chip.h"
#import "SimpleAudioEngine.h"

@implementation BoardLayer
@synthesize columns, rows;
@synthesize spritesheet;
@synthesize currentChip;
@synthesize activeColumn;
@synthesize board;
@synthesize boardArray;
@synthesize chips;
@synthesize gameEnded;
@synthesize popup;

typedef enum{
	All,
	Top,
	TopRight,
	Right,
	BottomRight,
	Bottom,
	BottomLeft,
	Left,
	TopLeft
} Directions;

-(id) initWithColumns:(int)_columns andRows:(int)_rows
{
	if ((self = [super init]))
	{
		self.columns = _columns;
		self.rows = _rows;
		chips = [[NSMutableArray alloc] init];

		spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"FourAssets.png"];
		[self addChild:spritesheet];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"FourAssets.plist"];
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
		[self preloadSoundEffects];
		[self makePopup];
		[self makeBoard];
	}
	return self;
}

- (void) preloadSoundEffects
{
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"drop.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"end.wav"];
}

- (int)valueOfHoleAtC:(int)c r:(int)r
{
	return boardHoles[c][r];
}

- (void)setHoleAtC:(int)c r:(int)r toValue:(int)v 
{
	boardHoles[c][r] = v;
}

-(void) makeBoard
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	board = [CCSprite spriteWithSpriteFrameName:@"hole.png"];
	board.anchorPoint = ccp(0,0);
	board.position = ccp(winSize.width/2 - (columns * 40)/2,
											 winSize.height/2 - ( (rows + 1) * 40)/2);
	[spritesheet addChild:board];
	
	for (int col = 0; col < columns; col++) {		
		for (int row = 0; row < rows; row++) {
			Hole *hole = [Hole spriteWithSpriteFrameName:@"hole.png"];
			hole.anchorPoint = ccp(0,0);
			hole.position = ccp(	hole.textureRect.size.width * col,
														hole.textureRect.size.height * row);
			[board addChild:hole];
		}
	}
	[self reset];	
}

- (void) reset
{
	gameEnded = NO;
	
	for (int col = 0; col < columns; col++) {		
		for (int row = 0; row < rows; row++) {
			boardHoles[col][row] = HoleEmpty;
		}
	}
	
	if ([chips count] > 0){
		currentChip = nil;
		NSMutableArray *chipsToDelete = [[NSMutableArray alloc] init];
		for (uint i = 0; i < [chips count]; i++) {
			[chipsToDelete addObject:[chips objectAtIndex:i]];
		}
		for (Chip *chip in chipsToDelete) {
			[chips removeObject:chip];
			[self removeChild:chip cleanup:YES];									
		}
		[chipsToDelete release];
	}
	
	[self newChip];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
	
	if (ccpDistance(touchLocation, currentChip.position) < currentChip.textureRect.size.width * 2){
		currentChip.isBeingDragged = YES;
	}
	return YES;    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	if (currentChip.isBeingDragged) {
		currentChip.isBeingDragged = NO;
		if (activeColumn >= 0)
		{
			for (uint row = 0; row < rows; row++) {

				if (boardHoles[activeColumn][row] == HoleEmpty){			
					
					CGPoint newPosition = ccpAdd(ccp(activeColumn*40,row*40),
																				ccp(board.position.x+20,board.position.y+20));
					
					float time = (rows-row);
					time = time/16;
					CCLOG(@"pp%i-%i=%f",rows,row,time);
					
					id fall = [CCMoveTo actionWithDuration:time position:newPosition];									 
					id checkWins = [CCCallFuncN actionWithTarget:self selector:@selector(checkWins)];
					
					[[SimpleAudioEngine sharedEngine] playEffect:@"drop.wav"];
					
					[currentChip runAction:[CCSequence actions:fall,checkWins, nil]];
					
					int status;
					if ([currentChip isKindOfClass:[Player1Chip class]])
						status = Player1;
					else
						status = Player2;
					
					boardHoles[activeColumn][row] = status;
					break;
				}
			}
		}
		else
			currentChip.position = currentChip.startPosition;
	}
}

-(void)makePopup {
	popup = [[UIAlertView alloc] init];
	[popup setDelegate:self];
	[popup setTitle:@"You Win!"];
	[popup setMessage:@"Play Again?"];
	[popup addButtonWithTitle:@"Yes"];
//[popup addButtonWithTitle:@"Human vs Human"];
}

-(void)winPopup {
	int status;
	if ([currentChip isKindOfClass:[Player1Chip class]])
		[popup setTitle:@"Player 1 Wins!"];
	else
		[popup setTitle:@"Player 2 Wins!"];

	[[SimpleAudioEngine sharedEngine] playEffect:@"end.wav"];
	gameEnded = TRUE;
	[popup show];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0) {
		[self reset];	
	}
}


-(void) checkWins
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"hit.wav"];
	
	for (int col = 0; col < columns; col++) {		
		for (int row = 0; row < rows; row++) {
			[self checkForWinAtCol:col andRow:row+1 andCount:0 andDirection:Top];//t
			[self checkForWinAtCol:col+1 andRow:row+1 andCount:0 andDirection:TopRight];//tr
			[self checkForWinAtCol:col+1 andRow:row andCount:0 andDirection:Right];//r
			[self checkForWinAtCol:col+1 andRow:row-1 andCount:0 andDirection:BottomRight];//br
			[self checkForWinAtCol:col andRow:row-1 andCount:0 andDirection:Bottom];//b
			[self checkForWinAtCol:col-1 andRow:row-1 andCount:0 andDirection:BottomLeft];//bl
			[self checkForWinAtCol:col-1 andRow:row andCount:0 andDirection:Left];//l
			[self checkForWinAtCol:col-1 andRow:row+1 andCount:0 andDirection:TopLeft];//tl
		}
	}
	
	[self newChip];
}
	

- (void) checkForWinAtCol:(int)col andRow:(int)row andCount:(int)count andDirection:(int)direction
{
	if (!gameEnded){
	if (boardHoles[col][row] == [self chipPlayer])
	{
		count++;		
		//[self traceBoard];
		if (count == 4)
			[self winPopup];
		else {
			switch (direction) {
				case Top:
					[self checkForWinAtCol:col andRow:row+1 andCount:count andDirection:direction];//t
					break;
				case TopRight:
					[self checkForWinAtCol:col+1 andRow:row+1 andCount:count andDirection:direction];//tr
					break;
				case Right:
					[self checkForWinAtCol:col+1 andRow:row andCount:count andDirection:direction];//r
					break;
				case BottomRight:
					[self checkForWinAtCol:col+1 andRow:row-1 andCount:count andDirection:direction];//br
					break;
				case Bottom:
					[self checkForWinAtCol:col andRow:row-1 andCount:count andDirection:direction];//b
					break;
				case BottomLeft:
					[self checkForWinAtCol:col-1 andRow:row-1 andCount:count andDirection:direction];//bl
					break;
				case Left:
					[self checkForWinAtCol:col-1 andRow:row andCount:count andDirection:direction];//l
					break;
				case TopLeft:
					[self checkForWinAtCol:col-1 andRow:row+1 andCount:count andDirection:direction];//tl
					break;
				default:
					break;
			}
		}
	}
	}
}

- (void) dealloc
{
	[popup dealloc];
	[super dealloc];
}

- (void) traceBoard
{
	NSString *line;
	CCLOG(@"\n");
	for (uint r = 0; r < rows; r++) {
		line = @"";
		for (uint c = 0; c < columns; c++) {
			line = [NSString stringWithFormat:@"%@ %i", line, boardHoles[c][r] ];
		}
		CCLOG(@"%@",line);
	}
	CCLOG(@"\n");
}

- (int) chipPlayer
{
	if ([currentChip isKindOfClass:[Player1Chip class]])
		return Player1;
	else
		return Player2;
}

- (void) newChip
{
	Chip *newChip;
	
	if (currentChip && [currentChip isKindOfClass:[Player1Chip class]])
		newChip = [Player2Chip spriteWithSpriteFrameName:@"yellow.png"];
	else
		newChip = [Player1Chip spriteWithSpriteFrameName:@"red.png"];
	
	[chips addObject:newChip];
	newChip.position = newChip.startPosition;
	
	currentChip = newChip;
	[self addChild:currentChip z:-1];
}
			
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

	if (currentChip.isBeingDragged){
		
		CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
		CGPoint newLocation = touchLocation;
		activeColumn = -1;
		
		for (uint col = 0; col < columns; col++) {
			
			int columnPosition = col * 40;			
			if (touchLocation.x >= columnPosition + board.position.x
					&& touchLocation.x < columnPosition + 40 + board.position.x)
			{
				activeColumn = col;
				newLocation = ccp(columnPosition + 20 + board.position.x,rows * 40 + 40);
			}
			
		}
		currentChip.position = newLocation;
		
	}
}
@end

@implementation Hole
@synthesize status;
@synthesize chip;
-(id) init
{
	if ((self = [super init]))
		self.status = HoleEmpty;
	return self;
}

@end