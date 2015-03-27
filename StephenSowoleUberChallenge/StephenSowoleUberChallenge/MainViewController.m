//
//  MainViewController.m
//  StephenSowoleUberChallenge
//
//  Created by Stephen Sowole on 23/03/2015.
//  Copyright (c) 2015 Stephen Sowole. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "SearchTableViewController.h"
#import "AsyncImageView.h"

@interface MainViewController ()

@end

@implementation MainViewController {
    
    NSMutableArray *googleResponseArray;
    int currentPageNumber, y, numberOfImages, startNo;
    UIScrollView *scrollView;
    NSString *searchString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = MAIN_TITLE;
    
    googleResponseArray = [[NSMutableArray alloc] init];
    
    [self initialiseVariables];
    
    [self addNavigationBarItems];
    
    [self createScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchImage:) name:NS_SEARCH_STRING object:nil];
}

- (void) initialiseVariables {
    
    currentPageNumber = 0, y = 0, numberOfImages = 0, startNo = 0;
}

- (void) createScrollView {
    
    scrollView = [[UIScrollView alloc] init];
    
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    scrollView.contentInset = UIEdgeInsetsZero;
    
    scrollView.delegate = self;
    
    [self.view addSubview:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)thisScrollView willDecelerate:(BOOL)decelerate {
    
    NSInteger currentOffset = thisScrollView.contentOffset.y;
    NSInteger maximumOffset = thisScrollView.contentSize.height - thisScrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 0) {
        
        [self getGoogleImages];
    }
}

- (void) searchImage:(NSNotification*)notification {
    
    searchString = [notification object];
    
    searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    for (UIView *subview in [scrollView subviews]) {
        
        [subview removeFromSuperview];
    }
    
    [self initialiseVariables];
    
    [googleResponseArray removeAllObjects];
    
    [self getGoogleImages];
}

- (void) getGoogleImages {

    if (startNo <= MAX_API_IMAGES) {
        
        for (int i = 0; i < PAGES_PER_SEARCH; i++) {
            
            startNo = currentPageNumber++ * NUMBER_OF_COLUMNS * 2;
            
            NSURL *url = [NSURL URLWithString:
                          [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=%i&start=%i&q=%@",
                           NUMBER_OF_COLUMNS * 2, startNo, searchString]];
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                                         returningResponse:nil error:nil];
            
            NSError *error;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            
            NSArray *resultArray = [[responseDictionary objectForKey:@"responseData"] objectForKey:@"results"];
            
            for (int i = 0; i < resultArray.count; i++) {
                
                [googleResponseArray addObject:[resultArray objectAtIndex:i]];
            }
        }
        
        [self performSelector:@selector(displayImages) withObject:nil];
        
        if (scrollView.contentSize.height < self.view.frame.size.height) {
            
            [self getGoogleImages];
        }
    }
}

- (void) displayImages {
    
    double split = IMAGE_SIZE * NUMBER_OF_COLUMNS;
    split = self.view.frame.size.width - split;
    split = split / (NUMBER_OF_COLUMNS + 1);
    
    int yVal = split;
    
    if (y) {
        
        yVal = y;
    }
    
    for (int row = 1; row < ((PAGES_PER_SEARCH * 2) + 1); row++) {
        
        double xVal = split;
        xVal += IMAGE_SIZE/2;
        
        for (int column = 1; column < (NUMBER_OF_COLUMNS + 1); column++) {
            
            [self createImageFromPosition:numberOfImages++ :CGPointMake(xVal, yVal)];
            xVal += (IMAGE_SIZE + split);
        }
        
        yVal += (IMAGE_SIZE + split);
    }
    
    y = yVal;
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yVal);
}

- (void) createImageFromPosition:(int)arrayPosition :(CGPoint)position {
    
    AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE)];
    asyncImage.center = CGPointMake(position.x, position.y);
    asyncImage.layer.anchorPoint = CGPointMake(0.5, 0);
    asyncImage.contentMode = UIViewContentModeScaleAspectFit;
    asyncImage.clipsToBounds = YES;
    asyncImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    asyncImage.layer.cornerRadius = 5;
    asyncImage.layer.borderWidth = 1.0f;
    asyncImage.imageURL = [NSURL URLWithString:[[googleResponseArray objectAtIndex:arrayPosition]objectForKey:@"tbUrl"]];
    [scrollView addSubview:asyncImage];
}

- (void) addNavigationBarItems {
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toggleSearch)];
    
    self.navigationItem.leftBarButtonItem = searchButton;
}

- (void) toggleSearch {
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    
    SearchTableViewController *searchTableViewController = [[SearchTableViewController alloc] init];
    
    navigationController.viewControllers = [NSArray arrayWithObject:searchTableViewController];
    
    searchTableViewController.title = SEARCH_VIEW_TITLE;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
