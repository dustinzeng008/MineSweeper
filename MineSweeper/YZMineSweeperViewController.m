//
//  YZMineSweeperViewController.m
//  MineSweeper
//
//  Created by Yong Zeng on 11/10/16.
//  Copyright © 2016 Yong Zeng. All rights reserved.
//
#import "YZMineSweeperViewController.h"
#import "UIButton+Property.h"

#define LEVEL_EASY_BOARD_SIZE       8
#define LEVEL_MEDIUM_BOARD_SIZE     16
#define LEVEL_HARD_BOARD_SIZE       32

#define NUMBER_OF_COLUMNS_PER_SCREEN 8

#define LEVEL_EASY      1
#define LEVEL_MEDIUM    2
#define LEVEL_HARD      3

#define ZERO_VALUE      0
#define ONE_VALUE       1
#define TWO_VALUE       2
#define THREE_VALUE     3
#define FOUR_VALUE      4
#define FIVE_VALUE      5
#define SIX_VALUE       6
#define SEVEN_VALUE     7
#define EIGHT_VALUE     8
#define MINE_VALUE      9

#define STATE_CLOSE     1
#define STATE_FLAG      2
#define STATE_QUESTION  3
#define STATE_EMPTY     4
#define STATE_NUMBER    5
#define STATE_EXPLODE   6

#define TAG_START       100000
#define INIT_TIME       999

#define KDEVICEWIDTH [[UIScreen mainScreen] bounds].size.width
#define KDEVICEHEIGHT [[UIScreen mainScreen] bounds].size.height
#define TILEWIDTH [[UIScreen mainScreen] bounds].size.width/8

@interface YZMineSweeperViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *board;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *resetButton;

@property (nonatomic) int totalMines;
@property (nonatomic) int mineSizePerRow;
@property (nonatomic) int gameLevel;

@property (nonatomic) int flags;
@property (nonatomic) int mineDigits;
@property (nonatomic) int mineMarked;

@property (nonatomic, strong) UIButton*mineDigits1;
@property (nonatomic, strong) UIButton*mineDigits2;
@property (nonatomic, strong) UIButton*mineDigits3;
@property (nonatomic, strong) UIButton*timerDigits1;
@property (nonatomic, strong) UIButton*timerDigits2;
@property (nonatomic, strong) UIButton*timerDigits3;

@property BOOL win;
@property BOOL gameOver;
@property BOOL gameStart;
@property (nonatomic) int seconds;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation YZMineSweeperViewController

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KDEVICEWIDTH, KDEVICEHEIGHT)];
    }
    return _scrollView;
}

- (int)mineSizePerRow{
    if (self.gameLevel == LEVEL_EASY) {
        return LEVEL_EASY_BOARD_SIZE;
    } else if (self.gameLevel == LEVEL_MEDIUM){
        return LEVEL_MEDIUM_BOARD_SIZE;
    }else if (self.gameLevel == LEVEL_HARD){
        return LEVEL_HARD_BOARD_SIZE;
    }
    return LEVEL_EASY_BOARD_SIZE;
}

- (int)totalMines{
    return self.mineSizePerRow;
}

- (NSMutableArray *)board{
    if (!_board) {
        _board = [NSMutableArray array];
    }
    return _board;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1];
    [self initNavigationBar];
    [self initViews];
}

- (void)setScrollViewContentSize{
    int contentSizeWidth = TILEWIDTH*self.mineSizePerRow;
    int contentSizeHeight = TILEWIDTH*self.mineSizePerRow > self.scrollView.frame.size.width ?
                            TILEWIDTH*self.mineSizePerRow: self.scrollView.frame.size.width;
    self.scrollView.contentSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
}

- (void)setGameLevel:(int)gameLevel{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _gameLevel = gameLevel;
    [self setScrollViewContentSize];
    [self initBoardValues];
    [self setBoardTiles];
}

- (void) initViews{
    [self.view addSubview: self.scrollView];
    
    [self setGameLevel:LEVEL_EASY];
}

- (void)initNavigationBar{
    self.navigationItem.titleView = [self navTitleView];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Easy" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftNavButton:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cheat" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightNavButton:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (UIView *)navTitleView{
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat width = 24.6*6+44;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, navBarHeight)];
    
    UIButton* mineDigits1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24.6, 44)];
    _mineDigits1 = mineDigits1;
    [containerView addSubview:mineDigits1];
    [mineDigits1 setBackgroundImage:[UIImage imageNamed:@"d0"] forState:UIControlStateNormal];
    
    UIButton* mineDigits2 = [[UIButton alloc] initWithFrame:CGRectMake(24.6*1, 0, 24.6, 44)];
    _mineDigits2 = mineDigits2;
    [containerView addSubview:mineDigits2];
    [mineDigits2 setBackgroundImage:[UIImage imageNamed:@"d0"] forState:UIControlStateNormal];
    
    UIButton* mineDigits3 = [[UIButton alloc] initWithFrame:CGRectMake(24.6*2, 0, 24.6, 44)];
    _mineDigits3 = mineDigits3;
    [containerView addSubview:mineDigits3];
    [mineDigits3 setBackgroundImage:[UIImage imageNamed:@"d0"] forState:UIControlStateNormal];
    
    
    UIButton* resetButton = [[UIButton alloc] initWithFrame:CGRectMake(24.6*3, 0, 44, 44)];
    _resetButton = resetButton;
    [containerView addSubview:resetButton];
    [resetButton setBackgroundImage:[UIImage imageNamed:@"smile"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetBoard) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton* timerDigits1= [[UIButton alloc] initWithFrame:CGRectMake(24.6*3 + 44, 0, 24.6, 44)];
    _timerDigits1 = timerDigits1;
    [containerView addSubview:timerDigits1];
    [timerDigits1 setBackgroundImage:[UIImage imageNamed:@"d0"] forState:UIControlStateNormal];
    
    UIButton* timerDigits2 = [[UIButton alloc] initWithFrame:CGRectMake(24.6*4 + 44, 0, 24.6, 44)];
    _timerDigits2 = timerDigits2;
    [containerView addSubview:timerDigits2];
    [timerDigits2 setBackgroundImage:[UIImage imageNamed:@"d0"] forState:UIControlStateNormal];
    
    UIButton* timerDigits3 = [[UIButton alloc] initWithFrame:CGRectMake(24.6*5 + 44, 0, 24.6, 44)];
    _timerDigits3 = timerDigits3;
    [containerView addSubview:timerDigits3];
    [timerDigits3 setBackgroundImage:[UIImage imageNamed:@"d0"] forState:UIControlStateNormal];
    
    return containerView;
}

- (void)clickLeftNavButton:(id)sender{
    UIBarButtonItem* barButtonItem = (UIBarButtonItem*)sender;
    if (self.gameLevel == LEVEL_EASY) {
        self.gameLevel = LEVEL_MEDIUM;
        [barButtonItem setTitle:@"Medium"];
        [self setGameLevel:LEVEL_MEDIUM];
    } else if (self.gameLevel == LEVEL_MEDIUM){
        self.gameLevel = LEVEL_HARD;
        [barButtonItem setTitle:@"Hard"];
        [self setGameLevel:LEVEL_HARD];
    }else if (self.gameLevel == LEVEL_HARD){
        self.gameLevel = LEVEL_EASY;
        [barButtonItem setTitle:@"Easy"];
        [self setGameLevel:LEVEL_EASY];
    }
}

- (void)clickRightNavButton:(id)sender{    
    [self turnOverBoard];
}

- (void) turnOverBoard{
    for (int row = 0; row < self.mineSizePerRow; row++) {
        for (int col = 0; col < self.mineSizePerRow; col++) {
            int tag = TAG_START + row*100 + col;
            int val = [self getBoardValueAtRow:row column:col];
            UIButton *button = (UIButton *)[self.scrollView viewWithTag:tag];
            if (ZERO_VALUE < val && val <= EIGHT_VALUE) {
                UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", val]];
                [button setBackgroundImage:image forState:UIControlStateNormal];
            }
            
            if (MINE_VALUE == val) {
                if ([button.status intValue] != STATE_EXPLODE) {
                    UIImage *image = [UIImage imageNamed:@"mine"];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                }
                
            }
            if (ZERO_VALUE == val) {
                UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", val]];
                [button setBackgroundImage:image forState:UIControlStateNormal];
            }
        }
    }
}

- (int) getBoardValueAtRow:(int)row column:(int)col{
    if (row < 0 || row >= self.mineSizePerRow || col < 0 || col >= self.mineSizePerRow) {
        return 0;
    }
    NSMutableArray *rowArray = [self.board objectAtIndex:row];
    return [[rowArray objectAtIndex:col] intValue];
}

- (void) updateBoardValueAtRow:(int)row column:(int)col withObject:(id)object{
    if (row < 0 || row >= self.mineSizePerRow || col < 0 || col >= self.mineSizePerRow) {
        return;
    }
    
    NSMutableArray *rowArray = [self.board objectAtIndex:row];
    [rowArray replaceObjectAtIndex:col withObject:object];
}

- (void)initBoardValues{
    _board = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.mineSizePerRow; i++) {
        NSMutableArray* rowArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < self.mineSizePerRow; j++) {
            [rowArray addObject:[NSNumber numberWithInt:ZERO_VALUE]];
            //[self updateBoardValueAtRow:i column:j withObject:[NSNumber numberWithInt:ZERO_VALUE]];
        }
        [_board addObject:rowArray];
    }
    
    // Generate mines randomly in the board
    int range = (int)[[self.board objectAtIndex:0] count];
    int i = 0;
    while (i < [self totalMines]) {
        int x = arc4random_uniform(range);
        int y = arc4random_uniform(range);
        int val = [self getBoardValueAtRow:x column:y];
        if (val != MINE_VALUE) {
            [self updateBoardValueAtRow:x column:y withObject:[NSNumber numberWithInt:MINE_VALUE]];
            i++;
        }
    }
    
    // Calculate the mines around (x,y) if there is no mine at (x,y)
    for (int i = 0; i < self.mineSizePerRow; i++) {
        for (int j = 0; j < self.mineSizePerRow; j++) {
            [self setMineValuesAroundRow:i column:j];
        }
    }
    
    self.gameOver = NO;
    // No flag in the board
    self.flags = 0;
    self.mineMarked = 0;
    [self setMineDigits:self.totalMines];
    [self setTimerDigits:self.seconds];
}

- (void)setMineValuesAroundRow:(int)x column:(int)y{
    int sum = 0;
    if ([self getBoardValueAtRow:x column:y] == MINE_VALUE) return;
    
    if ([self getBoardValueAtRow:x-1 column:y-1] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x-1 column:y] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x-1 column:y+1] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x column:y-1] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x column:y+1] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x+1 column:y-1] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x+1 column:y] == MINE_VALUE) sum+=1;
    if ([self getBoardValueAtRow:x+1 column:y+1] == MINE_VALUE) sum+=1;
    
    [self updateBoardValueAtRow:x column:y withObject:[NSNumber numberWithInt:sum]];
}


// How many mines that user marked.
- (void)setMineDigits:(int)mineDigits{
    _mineDigits = mineDigits;
    
    NSString* strImageName1 = [NSString stringWithFormat:@"d%i", mineDigits/100];
    [self.mineDigits1 setBackgroundImage:[UIImage imageNamed:strImageName1] forState:UIControlStateNormal];
    
    NSString* strImageName2 = [NSString stringWithFormat:@"d%i", (mineDigits%100)/10];
    [self.mineDigits2 setBackgroundImage:[UIImage imageNamed:strImageName2] forState:UIControlStateNormal];
    
    NSString* strImageName3 = [NSString stringWithFormat:@"d%i", (mineDigits%100)%10];
    [self.mineDigits3 setBackgroundImage:[UIImage imageNamed:strImageName3] forState:UIControlStateNormal];
}

- (void)setTimerDigits:(int)seconds{
    NSString* strImageName1 = [NSString stringWithFormat:@"d%i", seconds/100];
    [self.timerDigits1 setBackgroundImage:[UIImage imageNamed:strImageName1] forState:UIControlStateNormal];
    
    NSString* strImageName2 = [NSString stringWithFormat:@"d%i", (seconds%100)/10];
    [self.timerDigits2 setBackgroundImage:[UIImage imageNamed:strImageName2] forState:UIControlStateNormal];
    
    NSString* strImageName3 = [NSString stringWithFormat:@"d%i", (seconds%100)%10];
    [self.timerDigits3 setBackgroundImage:[UIImage imageNamed:strImageName3] forState:UIControlStateNormal];
}

- (void)setBoardTiles{
    int marginTop = 0;
    if (self.mineSizePerRow * TILEWIDTH < KDEVICEHEIGHT) {
        marginTop = (KDEVICEHEIGHT - self.mineSizePerRow * TILEWIDTH -64) / 2;
    } else {
        marginTop = 20;
    }
    for (int row = 0; row < self.mineSizePerRow; row++) {
        for (int col = 0; col < self.mineSizePerRow; col++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(col*TILEWIDTH, marginTop + row*TILEWIDTH, TILEWIDTH, TILEWIDTH);
            button.tag = TAG_START + row*100 + col;
            [button addTarget:self action:@selector(mineTilePressed:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(mineTileLongPressed:)];
            longPress.minimumPressDuration = 1.0f;
            [button addGestureRecognizer:longPress];
            button.status = [NSNumber numberWithInt:STATE_CLOSE];
            button.layer.borderWidth = 1.0f;
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            [button setBackgroundImage:[UIImage imageNamed:@"unopen"] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleToFill;
            [self.scrollView addSubview:button];
        }
    }
}

- (void)mineTilePressed:(id)sender{
    if (self.gameStart == NO) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(clockTimer) userInfo:nil repeats:YES];
        self.gameStart = YES;
    }
    
    UIButton *button = (UIButton*)sender;
    int x = (int)(button.tag - TAG_START) / 100;
    int y = (int)(button.tag - TAG_START) % 100;
    
    [self traversalAtRow:x col:y];
    if (self.gameOver) {
        [self turnOverBoard];
        self.gameStart = NO;
        [self.timer invalidate];
        self.scrollView.userInteractionEnabled = NO;
        [self.resetButton setBackgroundImage:[UIImage imageNamed:@"cry"] forState:UIControlStateNormal];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Fail"
                                                       message:@"Do you want start a new game?"
                                                      delegate:self
                                             cancelButtonTitle:@"No"
                                             otherButtonTitles:@"YES", nil];
        [alert show];
    }
}

- (void)clockTimer {
    self.seconds++;
    [self setTimerDigits:self.seconds];
}

#pragma AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self resetBoard];
    }
}

- (void)mineTileLongPressed:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded){
        
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        UIButton *button = (UIButton*)[sender view];
        int x = (int)(button.tag - TAG_START) / 100;
        int y = (int)(button.tag - TAG_START) % 100;
        int val = [self getBoardValueAtRow:x column:y];
        
        int buttonStatus = [button.status intValue];
        if (buttonStatus == STATE_CLOSE) {
            UIImage* image = [UIImage imageNamed:@"flag"];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.status = [NSNumber numberWithInt:STATE_FLAG];
            self.flags++;
            
            if (MINE_VALUE == val) {
                self.mineMarked++;
            }
            
        } else if (buttonStatus == STATE_FLAG){
            UIImage* image = [UIImage imageNamed:@"question"];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.status = [NSNumber numberWithInt:STATE_QUESTION];
            self.flags--;
            
            if (MINE_VALUE == val) {
                self.mineMarked--;
            }
            
        } else if (buttonStatus == STATE_QUESTION){
            UIImage* image = [UIImage imageNamed:@"unopen"];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.status = [NSNumber numberWithInt:STATE_CLOSE];
        }
        [self checkWin];
    }
}

- (void)checkWin{
    if (self.mineMarked == [self totalMines]) {
        _win = YES;
        self.scrollView.userInteractionEnabled = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulation! You success!"
                                                       message:@"Do you want start a new game?"
                                                      delegate:self
                                             cancelButtonTitle:@"No"
                                             otherButtonTitles:@"YES", nil];
        [alert show];
    }
}

- (void)traversalAtRow:(int)x col:(int)y{
    if (x < 0 || x >= self.mineSizePerRow || y < 0 || y >= self.mineSizePerRow) {
        return;
    }
    if (self.win == YES) {
        return;
    }
    UIButton* button = (UIButton*)[self.scrollView viewWithTag:TAG_START + 100*x + y];
    int buttonStatus = [button.status intValue];
    
    // Only check the button unrevealed.
    if (buttonStatus == STATE_CLOSE) {
        int val = [self getBoardValueAtRow:x column:y];
        
        if (ZERO_VALUE < val && val <= EIGHT_VALUE) {
            UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", val]];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.status = [NSNumber numberWithInt:STATE_NUMBER];
            return;
        }
        
        if (MINE_VALUE == val) {
            UIImage *image = [UIImage imageNamed:@"explode"];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.status = [NSNumber numberWithInt:STATE_EXPLODE];
            self.gameOver = YES;
            return;
        }
        if (ZERO_VALUE == val) {
            UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", val]];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            button.status = [NSNumber numberWithInt:STATE_EMPTY];
        }
        [self traversalAtRow:x col:y-1];
        [self traversalAtRow:x col:y+1];
        [self traversalAtRow:x+1 col:y];
        [self traversalAtRow:x+1 col:y];
    }
}

- (void)resetBoard{
    self.win = NO;
    self.gameStart = NO;
    self.seconds = 0;
    [self.timer invalidate];
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.resetButton setImage:[UIImage imageNamed:@"smile"] forState:UIControlStateNormal];
    [self initBoardValues];
    [self setBoardTiles];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
