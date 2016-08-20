// Highly inspirited by HMSegmentedControl. https://github.com/HeshamMegid/HMSegmentedControl


#import <UIKit/UIKit.h>

/**
 *  The indicator's position of the segmented control.
 */
typedef NS_ENUM(NSUInteger, ZHSegmentedControlIndicatorPosition) {
    /**
     *  Hide the indicator.
     */
    ZHSegmentedControlIndicatorPositionNone,
    /**
     *  Set the indicator to the top of the control.
     */
    ZHSegmentedControlIndicatorPositionTop,
    /**
     *  Set the indicator to the bottom of the control.
     */
    ZHSegmentedControlIndicatorPositionBottom
};

/**
 *  The options contorl the border of each section.
 */
typedef NS_OPTIONS(NSUInteger, ZHSegmentedControlSectionBorderStyle) {
    /**
     *  No border.
     */
    ZHSegmentedControlSectionBorderStyleNone = 0,
    /**
     *  Show top border.
     */
    ZHSegmentedControlSectionBorderStyleTop = 1 << 0,
    /**
     *  Show left border.
     */
    ZHSegmentedControlSectionBorderStyleLeft = 1 << 1,
    /**
     *  Show bottom border.
     */
    ZHSegmentedControlSectionBorderStyleBottom = 1 << 2,
    /**
     *  Show right border.
     */
    ZHSegmentedControlSectionBorderStyleRight = 1 << 3
};

/**
 *  The style of the indicator.
 */
typedef NS_ENUM(NSUInteger, ZHSegmentedControlIndicatorStyle) {
    /**
     *  The default style. The indicator is horizontal line.
     */
    ZHSegmentedControlIndicatorStyleDefault,
    /**
     *  The indicator is a arrow.
     */
    ZHSegmentedControlIndicatorStyleArrow,
    /**
     *  For my poor English. It's hard to explain this style. Go to the example to see the effect.
     */
    ZHSegmentedControlIndicatorStyleBox,
    /**
     *  Same with above.
     */
    ZHSegmentedControlIndicatorStyleFlood
};


@interface ZHSegmentedControl : UIControl
/**
 *  The array of each section's title.
 */
@property (nonatomic, readonly) NSArray<NSString *> *titles;
/**
 *  The property controls the text's attributes. Only effect when property `titles` has value.
 */
@property (nonatomic, copy) NSDictionary *titleTextAttributes;
/**
 *  The property controls the text's selected attributes. Only effect when property `titles` has value.
 */
@property (nonatomic, copy) NSDictionary *selectedTitleTextAttributes;
/**
 *  The array of each section's image. With `titles` property set, this property would be useless.
 */
@property (nonatomic, readonly) NSArray<UIImage *> *images;
/**
 *  The array of each section's selected image. The count of this array must be equal to the property `images`.
 */
@property (nonatomic, readonly) NSArray<UIImage *> *selectedImages;
/**
 *  Control the position of indicator. 
 *  Useless when `indicatorStyle` property set to `ZHSegmentedControlIndicatorStyleBox` or `ZHSegmentedControlIndicatorStyleFlood`.
 *  @see `ZHSegmentedControlIndicatorPosition`.
 */
@property (nonatomic, assign) ZHSegmentedControlIndicatorPosition indicatorPosition;
/**
 *  Control the style of indicator.
 *  @see `ZHSegmentedControlIndicatorStyle`.
 */
@property (nonatomic, assign) ZHSegmentedControlIndicatorStyle indicatorStyle;
/**
 *  Control the color of indicator.
 *  Default is `R:52, G:181, B:229`.
 */
@property (nonatomic, strong) UIColor *indicatorColor;
/**
 *  Only useful with `indicatorStyle` property set to `ZHSegmentedControlIndicatorStyleDefault`.
 */
@property (nonatomic, assign) CGFloat indicatorHeight;
/**
 *  Control the color of the box. Only userful with `indicatorStyle` set to `ZHSegmentedControlIndicatorStyleBox`.
 *  If no value, `selectedIndicatorColor` would be used.
 *  If `selectedIndicatorColor` == nil. [UIColor clearColor] would be set to this property.
 */
@property (nonatomic, strong) UIColor *boxColor;
/**
 *  Control the selected color of the box. Only userful with `indicatorStyle` set to `ZHSegmentedControlIndicatorStyleBox`.
 *  If no value, `boxColor` would be used.
 */
@property (nonatomic, strong) UIColor *selectedBoxColor;
/**
 *  Control each section's border style.
 *  @see `ZHSegmentedControlBorderStyle`.
 */
@property (nonatomic, assign) ZHSegmentedControlSectionBorderStyle borderStyle;
/**
 *  The color of each section's border.
 */
@property (nonatomic, strong) UIColor *borderColor;
/**
 *  The width of each section's border.
 */
@property (nonatomic, assign) CGFloat borderWidth;
/**
 *  Whether the segment control could be dragged or not.
 */
@property (nonatomic, assign, getter=isUserDraggable) BOOL userDraggable;
/**
 *  Whether animate the indicator when selected index changed.
 */
@property (nonatomic, assign) BOOL shouldAnimateUserSelection;
/**
 *  Set the selected index of the semgented control.
 */
@property (nonatomic, assign) NSInteger selectedSegmentIndex;
/**
 *  The section's number.
 */
@property (nonatomic, readonly) NSInteger numbersOfSegments;

- (void)setTitles:(NSArray<NSString *> *)titles;
- (void)setImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages;
/**
 *  The method could not trigger the control event `UIControlEventValueChanged`.
 */
- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated;

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles;
- (instancetype)initWithImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages;
+ (instancetype)segmentedControlWithTitles:(NSArray<NSString *> *)titles;
+ (instancetype)segmentedControlWithImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages;

@end

// Forgive my poor English. 😫😫 😂😂
