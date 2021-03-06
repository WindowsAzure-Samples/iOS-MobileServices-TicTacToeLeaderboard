//
//  TicTacToeViewController.m
//  TicTacToeLeaderboard
//
//  Created by Chris Risner on 1/21/13.
//  Copyright (c) 2013 Microsoft. All rights reserved.
//

#import "TicTacToeViewController.h"
#import "TicTacToeService.h"

@interface TicTacToeViewController ()

@end

@implementation TicTacToeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    int turnIndicator = arc4random() % 2;
    if (turnIndicator == 0) {
        playersTurn = NO;
        computersTurn = YES;
        playerCharacter = @"O";
    } else {
        playersTurn = YES;
        computersTurn = NO;
        playerCharacter = @"X";
    }

    gameOver = NO;
    currentCharacter = @"X";
    spotsRemaining = 9;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    distance = self.view.bounds.size.width / 3;
    
    UIView *topHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 140, self.view.bounds.size.width, 3)];
    topHorizontalLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topHorizontalLine];
    
    
    UIView *bottomHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 240, self.view.bounds.size.width, 3)];
    bottomHorizontalLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomHorizontalLine];

    
    UIView *leftVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(distance, 40, 3, self.view.bounds.size.width)];
    leftVerticalLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftVerticalLine];
    
    UIView *rightVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(distance * 2, 40, 3, self.view.bounds.size.width)];
    rightVerticalLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightVerticalLine];
    
    
        
    tableValueArray = [[NSMutableArray alloc] initWithCapacity: 3];
    
    [tableValueArray insertObject:[NSArray arrayWithObjects:self.btnTopLeft,self.btnTopMiddle,self.btnTopRight,nil] atIndex:0];
    [tableValueArray insertObject:[NSArray arrayWithObjects:self.btnMiddleLeft,self.btnMiddleMiddle,self.btnMiddleRight,nil] atIndex:1];
    [tableValueArray insertObject:[NSArray arrayWithObjects:self.btnBottomLeft,self.btnBottomMiddle,self.btnBottomRight,nil] atIndex:2];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (computersTurn) {
        self.lblInfo.text = @"Computer's turn";
        [self computerTurn];
    } else {
        self.lblInfo.text = @"Your turn!";
    }
}

- (IBAction)tappedPlaySquare:(id)sender {
    
    if (gameOver)
        return;
    
    UIButton *tappedButton = sender;
    if ([tappedButton.currentTitle length] == 0) {
        [tappedButton setTitle:currentCharacter forState:UIControlStateNormal];
        spotsRemaining--;
        
        if ([self checkForGameover] || spotsRemaining == 0) {
            [self gameover];
            return;
        }
        if ([currentCharacter isEqualToString:@"X"])
            currentCharacter = @"O";
        else
            currentCharacter = @"X";
        
        playersTurn = !playersTurn;
        computersTurn = !computersTurn;
        
        if (computersTurn) {
            [self computerTurn];
        }
    }
}

- (void) computerTurn {
    //Kick off computers turn in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIButton *pickedButton;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                pickedButton = tableValueArray[i][j];
                if ([pickedButton.currentTitle length] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self computerPicksButton:pickedButton];
                    });
                    return;
                }
            }
        }
    });
}

- (void)computerPicksButton:(UIButton *)pickedButton{
    UIButton *button = pickedButton;
    [button setTitle:currentCharacter forState:UIControlStateNormal];
    
    spotsRemaining--;
    
    if ([self checkForGameover] || spotsRemaining == 0) {
        [self gameover];
        return;
    }
    
    if ([currentCharacter isEqualToString:@"X"])
        currentCharacter = @"O";
    else
        currentCharacter = @"X";
    
    playersTurn = !playersTurn;
    computersTurn = !computersTurn;
    self.lblInfo.text = @"Your turn!";
}

- (void)gameover {
    gameOver = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"name"];
    
    TicTacToeService *tttService = [TicTacToeService getInstance];
    
    if ([winningCharacter length] == 0) {
        self.lblInfo.text = @"No winner!";
        self.btnTopLeft.backgroundColor = self.btnTopMiddle.backgroundColor =
        self.btnTopRight.backgroundColor = self.btnMiddleLeft.backgroundColor =
        self.btnMiddleMiddle.backgroundColor = self.btnMiddleRight.backgroundColor  =
        self.btnBottomLeft.backgroundColor = self.btnBottomMiddle.backgroundColor = self.btnBottomRight.backgroundColor = [UIColor redColor];
        [tttService saveTie:userName completion:nil];
    }
    else {
        if ([winningCharacter isEqualToString:playerCharacter]) {
            self.lblInfo.text = @"YOU WIN!";
            [tttService saveWin:userName completion:nil];
        } else {
            self.lblInfo.text = @"YOU Lose :(";
            [tttService saveLoss:userName completion:nil];
        }

    }
}

- (BOOL)checkForGameover {
    //If there are over 6 spots, the game can't be over
    if (spotsRemaining > 6)
        return NO;

    //Horizontal Wins
    if ([self.btnTopLeft.currentTitle isEqualToString:self.btnTopMiddle.currentTitle] &&
        [self.btnTopLeft.currentTitle isEqualToString:self.btnTopRight.currentTitle]) {
        winningCharacter = self.btnTopLeft.currentTitle;
        self.btnTopLeft.backgroundColor = self.btnTopMiddle.backgroundColor = self.btnTopRight.backgroundColor = [UIColor greenColor];
            
        return YES;
    }

    if ([self.btnMiddleLeft.currentTitle isEqualToString:self.btnMiddleMiddle.currentTitle] &&
        [self.btnMiddleLeft.currentTitle isEqualToString:self.btnMiddleRight.currentTitle]) {
        winningCharacter = self.btnMiddleLeft.currentTitle;
        
        self.btnMiddleLeft.backgroundColor = self.btnMiddleMiddle.backgroundColor = self.btnMiddleRight.backgroundColor = [UIColor greenColor];
        
        return YES;
    }
    if ([self.btnBottomLeft.currentTitle isEqualToString:self.btnBottomMiddle.currentTitle] &&
        [self.btnBottomLeft.currentTitle isEqualToString:self.btnBottomRight.currentTitle]) {
        winningCharacter = self.btnBottomLeft.currentTitle;

        self.btnBottomLeft.backgroundColor = self.btnBottomMiddle.backgroundColor = self.btnBottomRight.backgroundColor = [UIColor greenColor];
        
        return YES;
    }
    
    //Vertical Wins
    if ([self.btnTopLeft.currentTitle isEqualToString:self.btnMiddleLeft.currentTitle] &&
        [self.btnTopLeft.currentTitle isEqualToString:self.btnBottomLeft.currentTitle]) {
        winningCharacter = self.btnTopLeft.currentTitle;
        
        self.btnTopLeft.backgroundColor = self.btnMiddleLeft.backgroundColor = self.btnBottomLeft.backgroundColor = [UIColor greenColor];

        return YES;
    }
    if ([self.btnTopMiddle.currentTitle isEqualToString:self.btnMiddleMiddle.currentTitle] &&
        [self.btnTopMiddle.currentTitle isEqualToString:self.btnBottomMiddle.currentTitle]) {
        winningCharacter = self.btnTopMiddle.currentTitle;

        self.btnTopMiddle.backgroundColor = self.btnMiddleMiddle.backgroundColor = self.btnBottomMiddle.backgroundColor = [UIColor greenColor];
        
        return YES;
    }
    if ([self.btnTopRight.currentTitle isEqualToString:self.btnMiddleRight.currentTitle] &&
        [self.btnTopRight.currentTitle isEqualToString:self.btnBottomRight.currentTitle]) {
        winningCharacter = self.btnTopRight.currentTitle;
        
        self.btnTopRight.backgroundColor = self.btnMiddleRight.backgroundColor = self.btnBottomRight.backgroundColor = [UIColor greenColor];
    
        return YES;
    }

    //Diagonal top left to bottom right
    if ([self.btnTopLeft.currentTitle isEqualToString:self.btnMiddleMiddle.currentTitle] &&
        [self.btnTopLeft.currentTitle isEqualToString:self.btnBottomRight.currentTitle]) {
        winningCharacter = self.btnTopLeft.currentTitle;
        
        self.btnTopLeft.backgroundColor = self.btnMiddleMiddle.backgroundColor = self.btnBottomRight.backgroundColor = [UIColor greenColor];
    
        return YES;
    }
    //Diagonal bottom left to top right
    if ([self.btnTopRight.currentTitle isEqualToString:self.btnMiddleMiddle.currentTitle] &&
        [self.btnTopRight.currentTitle isEqualToString:self.btnBottomLeft.currentTitle]) {
        winningCharacter = self.btnTopRight.currentTitle;
        
        self.btnTopRight.backgroundColor = self.btnMiddleMiddle.backgroundColor = self.btnBottomLeft.backgroundColor = [UIColor greenColor];
        return YES;
    }
    return NO;
}






@end
