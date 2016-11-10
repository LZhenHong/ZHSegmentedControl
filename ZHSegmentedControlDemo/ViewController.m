//
//  ViewController.m
//  ZHSegmentedControlDemo
//
//  Created by LZhenHong on 16/8/5.
//  Copyright © 2016年 LZhenHong. All rights reserved.
//

#import "ViewController.h"
#import "ZHSegmentedControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<UIImage *> *images = @[[UIImage imageNamed:@"Today"], [UIImage imageNamed:@"Long"], [UIImage imageNamed:@"Want"]];
    NSArray<UIImage *> *selectedImages = @[[UIImage imageNamed:@"TodaySelected"], [UIImage imageNamed:@"LongSelected"], [UIImage imageNamed:@"WantSelected"]];
    ZHSegmentedControl *segmentedControl0 = [[ZHSegmentedControl alloc] initWithImages:images selectedImages:selectedImages];
    segmentedControl0.frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 60);
    segmentedControl0.indicatorStyle = ZHSegmentedControlIndicatorStyleArrow;
    segmentedControl0.indicatorColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    [self.view addSubview:segmentedControl0];
    [segmentedControl0 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];

    NSArray<NSString *> *titles = @[@"Today", @"Long", @"Wanted"];
    ZHSegmentedControl *segmentedControl1 = [[ZHSegmentedControl alloc] initWithTitles:titles];
    segmentedControl1.bounds = CGRectMake(0.0, 0.0, self.view.bounds.size.width - 100.0, 40);
    segmentedControl1.center = self.view.center;
    segmentedControl1.indicatorHeight = 3.0;
    NSDictionary *attr3 = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
                           NSForegroundColorAttributeName: [UIColor whiteColor]
                           };
    NSDictionary *attrSel3 = @{
                               NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
                               NSForegroundColorAttributeName: [UIColor whiteColor]
                               };
    segmentedControl1.titleTextAttributes = attr3;
    segmentedControl1.selectedTitleTextAttributes = attrSel3;
    segmentedControl1.indicatorPosition = ZHSegmentedControlIndicatorPositionBottom;
    segmentedControl1.indicatorStyle = ZHSegmentedControlIndicatorStyleFloodHollow;
    segmentedControl1.boxColor = [UIColor colorWithRed:0.97 green:0.78 blue:0.76 alpha:1.00];
    segmentedControl1.selectedBoxColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    [self.view addSubview:segmentedControl1];
    [segmentedControl1 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];

    ZHSegmentedControl *segmentedControl2 = [[ZHSegmentedControl alloc] initWithTitles:titles];
    segmentedControl2.frame = CGRectMake(0.0, 300.0, self.view.bounds.size.width, 60.0);
    segmentedControl2.boxColor = [UIColor colorWithRed:0.97 green:0.78 blue:0.76 alpha:1.00];
    segmentedControl2.selectedBoxColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    segmentedControl2.indicatorStyle = ZHSegmentedControlIndicatorPositionNone;
    segmentedControl2.indicatorStyle = ZHSegmentedControlIndicatorStyleFlood;
    NSDictionary *attr2 = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:19.0f],
                           NSForegroundColorAttributeName: [UIColor whiteColor]
                           };
    segmentedControl2.titleTextAttributes = attr2;
    [self.view addSubview:segmentedControl2];
    [segmentedControl2 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    ZHSegmentedControl *segmentedControl3 = [[ZHSegmentedControl alloc] initWithTitles:titles];
    segmentedControl3.frame = CGRectMake(0.0, 400.0, self.view.bounds.size.width, 60.0);
    segmentedControl3.titleTextAttributes = attr3;
    segmentedControl3.selectedTitleTextAttributes = attrSel3;
    segmentedControl3.indicatorColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    segmentedControl3.indicatorHeight = 3.0;
    [self.view addSubview:segmentedControl3];
    [segmentedControl3 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentedControlClicked:(ZHSegmentedControl *)sender {
    NSLog(@"Index %td selected - %@", sender.selectedSegmentIndex, sender);
}

@end
