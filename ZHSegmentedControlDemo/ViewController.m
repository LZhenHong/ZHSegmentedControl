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
    ZHSegmentedControl *segmentedControl0 = [[ZHSegmentedControl alloc] initWithSectionImages:images selectedImages:selectedImages];
    segmentedControl0.frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 60);
    segmentedControl0.indicatorStyle = ZHSegmentedControlIndicatorStyleArrow;
    segmentedControl0.selectionIndicatorColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    [self.view addSubview:segmentedControl0];
    [segmentedControl0 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    NSArray<NSString *> *titles = @[@"Today", @"Long", @"Wanted"];
    ZHSegmentedControl *segmentedControl1 = [[ZHSegmentedControl alloc] initWithSectionTitles:titles];
    segmentedControl1.frame = CGRectMake(0.0, 200.0, self.view.bounds.size.width, 60);
    segmentedControl1.selectionIndicatorHeight = 3.0;
    segmentedControl1.indicatorPosition = ZHSegmentedControlIndicatorPositionTop;
    segmentedControl1.selectionIndicatorColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    [self.view addSubview:segmentedControl1];
    [segmentedControl1 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    ZHSegmentedControl *segmentedControl2 = [[ZHSegmentedControl alloc] initWithSectionTitles:titles];
    segmentedControl2.frame = CGRectMake(0.0, 300.0, self.view.bounds.size.width, 60.0);
    segmentedControl2.boxColor = [UIColor colorWithRed:0.97 green:0.78 blue:0.76 alpha:1.00];
    segmentedControl2.selectionBoxColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    segmentedControl2.indicatorViewHidden = YES;
    NSDictionary *attr2 = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:19.0f],
                           NSForegroundColorAttributeName: [UIColor whiteColor]
                           };
    segmentedControl2.titleTextAttributes = attr2;
    [self.view addSubview:segmentedControl2];
    [segmentedControl2 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    ZHSegmentedControl *segmentedControl3 = [[ZHSegmentedControl alloc] initWithSectionTitles:titles];
    segmentedControl3.frame = CGRectMake(0.0, 400.0, self.view.bounds.size.width, 60.0);
    NSDictionary *attr3 = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:19.0f],
                           NSForegroundColorAttributeName: [UIColor colorWithRed:0.97 green:0.78 blue:0.76 alpha:1.00]
                           };
    NSDictionary *attrSel3 = @{
                               NSFontAttributeName: [UIFont systemFontOfSize:19.0f],
                               NSForegroundColorAttributeName: [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00]
                               };
    segmentedControl3.titleTextAttributes = attr3;
    segmentedControl3.selectedTitleTextAttributes = attrSel3;
    segmentedControl3.selectionIndicatorColor = [UIColor colorWithRed:0.90 green:0.32 blue:0.27 alpha:1.00];
    segmentedControl3.selectionIndicatorHeight = 3.0;
    [self.view addSubview:segmentedControl3];
    [segmentedControl3 addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentedControlClicked:(ZHSegmentedControl *)sender {
    NSLog(@"Index %ld selected - %@", sender.selectedSegmentIndex, sender);
}

@end
