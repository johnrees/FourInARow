//#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Chip.h"

// Board
@interface BoardLayer : CCLayer {
	uint columns, rows;
	int activeColumn;
	CCSpriteBatchNode *spritesheet;
	Chip *currentChip;
	CCSprite *board;
	int boardHoles[7][6];
	NSMutableArray *chips;
	BOOL gameEnded;
	UIAlertView* popup;
}

- (id) initWithColumns:(int)columns andRows:(int)rows;
- (void) checkForWinAtCol:(int)col andRow:(int)row andCount:(int)count andDirection:(int)direction;
- (int) chipPlayer;
- (int) valueOfHoleAtC:(int)c r:(int)r;
- (void) setHoleAtC:(int)c r:(int)r toValue:(int)v;
- (void) makeBoard;
- (void) newChip;
- (void) reset;
- (void) checkWins;

@property (nonatomic, retain) CCSprite *board;
@property (nonatomic, retain) NSMutableArray *chips;
@property (nonatomic, retain) CCSpriteBatchNode *spritesheet;
@property (nonatomic, retain) Chip *currentChip;
@property (nonatomic, retain) UIAlertView *popup;
@property (nonatomic) uint columns, rows;
@property (nonatomic) int activeColumn, boardArray;
@property (nonatomic) BOOL gameEnded;

@end

// Hole
typedef enum {
	HoleEmpty,
	Player1,
	Player2,
} HoleStatus;

@interface Hole : CCSprite {
	Chip *chip;
	HoleStatus status;
}

@property (nonatomic, retain) Chip *chip;
@property (nonatomic) HoleStatus status;

@end


