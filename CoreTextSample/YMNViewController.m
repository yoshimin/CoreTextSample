//
//  YMNViewController.m
//  CoreTextSample
//
//  Created by Shingai Yoshimi on 8/3/14.
//  Copyright (c) 2014 Shingai Yoshimi. All rights reserved.
//

#import "YMNViewController.h"
#import "YMNCoreTextView.h"

@interface YMNViewController ()

@property (nonatomic, strong) IBOutlet YMNCoreTextView *textView;

@end

@implementation YMNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSString *text = @"Lorem ipsum dolor sit amet, <printlog>consectetur</printlog> adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud <printlog>exercitation ullamco laboris</printlog> nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in <printlog>voluptate velit esse</printlog> cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia <printlog>deserunt</printlog> mollit anim id est laborum.";
    
    YMNCoreTextItem *item = [[YMNCoreTextItem alloc] initWithTag:@"printlog"
                                                          action:^{
                                                              NSLog(@"お、おされたー");
                                                          }];
    self.textView = [[YMNCoreTextView alloc] initWithText:text item:@[item]];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.frame = CGRectMake(0.f, 20.f, self.view.frame.size.width, self.view.frame.size.height);
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:self.textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
