//
//  ZHSegmentedControl.h
//  ZHSegmentedControl
//
//  Created by LZhenHong on 16/7/25.
//  Copyright © 2016年 LZhenHong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZHSegmentedControlIndicatorPosition) {
    ZHSegmentedControlIndicatorPositionTop,
    ZHSegmentedControlIndicatorPositionBottom
};

typedef NS_OPTIONS(NSUInteger, ZHSegmentedControlBorderStyle) {
    ZHSegmentedControlBorderStyleNone = 0,
    ZHSegmentedControlBorderStyleTop = 1 << 0,
    ZHSegmentedControlBorderStyleLeft = 1 << 1,
    ZHSegmentedControlBorderStyleBottom = 1 << 2,
    ZHSegmentedControlBorderStyleRight = 1 << 3
};

typedef NS_ENUM(NSUInteger, ZHSegmentedControlIndicatorStyle) {
    ZHSegmentedControlIndicatorStylDefault,
    ZHSegmentedControlIndicatorStyleArrow,
    ZHSegmentedControlIndicatorStyleFlood // Not implement now!!!
};

@interface ZHSegmentedControl : UIControl

@property (nonatomic, copy) NSArray<NSString *> *sectionTitles;
@property (nonatomic, readonly) NSArray<UIImage *> *images;
@property (nonatomic, readonly) NSArray<UIImage *> *selectedImages;
@property (nonatomic, copy) NSDictionary *titleTextAttributes;
@property (nonatomic, copy) NSDictionary *selectedTitleTextAttributes;

@property (nonatomic, assign) ZHSegmentedControlIndicatorPosition indicatorPosition;
@property (nonatomic, assign) ZHSegmentedControlIndicatorStyle indicatorStyle;

@property (nonatomic, assign) ZHSegmentedControlBorderStyle borderStyle;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, strong) UIColor *selectionIndicatorColor; // Default is `R:52, G:181, B:229`
@property (nonatomic, strong) UIColor *boxColor; // Default is [UIColor clearColor]
@property (nonatomic, strong) UIColor *selectionBoxColor; // Default is [UIColor clearColor]

@property (nonatomic, assign, getter=isUserDraggable) BOOL userDraggable;
@property (nonatomic, assign) BOOL shouldAnimateUserSelection;
@property (nonatomic, assign, getter=isIndicatorViewHidden) BOOL indicatorViewHidden;
@property (nonatomic, assign) CGFloat selectionIndicatorHeight; // Default is 1.0f

@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, readonly) NSInteger numbersOfSegments;

- (instancetype)initWithSectionTitles:(NSArray<NSString *> *)sectionTitles;
- (instancetype)initWithSectionImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages;
- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setSectionImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages;

@end
