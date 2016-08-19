//
//  ZHSegmentedControl.m
//  ZHSegmentedControl
//
//  Created by LZhenHong on 16/7/25.
//  Copyright © 2016年 LZhenHong. All rights reserved.
//

#import "ZHSegmentedControl.h"

typedef NS_ENUM(NSUInteger, ZHSegmentedControlType) {
    ZHSegmentedControlTypeText,
    ZHSegmentedControlTypeImage,
    ZHSegmentedControlTypeNone,
};

@interface ZHSegmentedButton : UIButton
@property (nonatomic, assign) ZHSegmentedControlBorderStyle borderStyle;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
- (void)setupButtonBorder;
@end
@interface ZHSegmentedButton ()
@property (nonatomic, strong) NSArray<CALayer *> *layers;
@end
@implementation ZHSegmentedButton
- (NSArray<CALayer *> *)layers {
    if (!_layers) {
        _layers = [NSArray arrayWithObjects:[CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], nil];
        [_layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.layer addSublayer:obj];
        }];
    }
    return _layers;
}

- (void)setHighlighted:(BOOL)highlighted {}

- (void)setupButtonBorder {
    [self.layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
        obj.backgroundColor = self.borderColor.CGColor;
        
    }];
    if (self.borderStyle == ZHSegmentedControlBorderStyleNone) {
        return;
    }
    if (self.borderStyle & ZHSegmentedControlBorderStyleTop) {
        CALayer *topLayer = self.layers[0];
        topLayer.hidden = NO;
        topLayer.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.borderWidth);
    }
    if (self.borderStyle & ZHSegmentedControlBorderStyleLeft) {
        CALayer *leftLayer = self.layers[1];
        leftLayer.hidden = NO;
        leftLayer.frame = CGRectMake(0.0, 0.0, self.borderWidth, self.bounds.size.height);
    }
    if (self.borderStyle & ZHSegmentedControlBorderStyleBottom) {
        CALayer *bottomLayer = self.layers[2];
        bottomLayer.hidden = NO;
        bottomLayer.frame = CGRectMake(0.0, self.bounds.size.height - self.borderWidth, self.bounds.size.width, self.borderWidth);
    }
    if (self.borderStyle & ZHSegmentedControlBorderStyleRight) {
        CALayer *rightLayer = self.layers[3];
        rightLayer.hidden = NO;
        rightLayer.frame = CGRectMake(self.bounds.size.width - self.borderWidth, 0.0, self.borderWidth, self.bounds.size.height);
    }
}
@end

@interface ZHSegmentedControl ()
@property (nonatomic, strong) NSMutableArray<ZHSegmentedButton *> *buttons;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CALayer *indicatorLayer;

@property (nonatomic, weak) ZHSegmentedButton *selectedButton;

@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL first;
@property (nonatomic, assign) ZHSegmentedControlType type;

@property (nonatomic, strong) NSSet<NSString *> *kvoProperties;
@end

static void *ZHSegmentedControlObserverContext = &ZHSegmentedControlObserverContext;

@implementation ZHSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithSectionTitles:(NSArray<NSString *> *)sectionTitles {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _sectionTitles = [sectionTitles copy];
        
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithSectionImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setSectionImages:images selectedImages:selectedImages];
        
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)setSectionImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImagess {
    NSParameterAssert(images.count == selectedImagess.count);
    _images = [images copy];
    _selectedImages = [selectedImagess copy];
}

- (void)commonInit {
    _selectionIndicatorColor = [UIColor colorWithRed:52.0f / 255.0f green:181.0f / 255.0f blue:229.0f / 255.0f alpha:1.0f];
    _selectionIndicatorHeight = 1.0f;
    _userDraggable = YES;
    _shouldAnimateUserSelection = YES;
    _selectedSegmentIndex = 0;
    _boxColor = [UIColor clearColor];
    _selectionBoxColor = [UIColor clearColor];
    _indicatorPosition = ZHSegmentedControlIndicatorPositionBottom;
    _borderStyle = ZHSegmentedControlBorderStyleNone;
    _indicatorStyle = ZHSegmentedControlIndicatorStyleDefault;
    _borderColor = [UIColor blackColor];
    _borderWidth = 1.0f;
    
    _first = YES;
    _buttons = [NSMutableArray array];
    self.backgroundColor = [UIColor whiteColor];
    
    _kvoProperties = [NSSet setWithObjects:NSStringFromSelector(@selector(sectionTitles)),
                                           NSStringFromSelector(@selector(titleTextAttributes)),
                                           NSStringFromSelector(@selector(selectedTitleTextAttributes)),
                                           NSStringFromSelector(@selector(selectionIndicatorColor)),
                                           NSStringFromSelector(@selector(selectionIndicatorHeight)),
                                           NSStringFromSelector(@selector(boxColor)),
                                           NSStringFromSelector(@selector(selectionBoxColor)),
                                           NSStringFromSelector(@selector(images)),
                                           NSStringFromSelector(@selector(selectedImages)),
                                           NSStringFromSelector(@selector(indicatorPosition)),
                                           NSStringFromSelector(@selector(borderStyle)),
                                           NSStringFromSelector(@selector(borderColor)),
                                           NSStringFromSelector(@selector(borderWidth)),
                                           nil];
    [_kvoProperties enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ZHSegmentedControlObserverContext];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.first) { return; }
    if ([self.kvoProperties containsObject:keyPath] && (context == ZHSegmentedControlObserverContext)) {
        id newValue = [change valueForKey:NSKeyValueChangeNewKey];
        id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
        SEL selector = NSSelectorFromString(keyPath);
        if ([self respondsToSelector:selector] && newValue != nil) {
            if ([keyPath isEqualToString:@"sectionTitles"] && ![oldValue isMemberOfClass:[NSNull class]]) {
                self.first = !([newValue count] == [oldValue count]);
            }
            [self setNeedsLayout];
        }
    }
}

- (void)dealloc {
    [self.kvoProperties enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self removeObserver:self forKeyPath:obj context:ZHSegmentedControlObserverContext];
        }
    }];
    self.kvoProperties = nil;
}

- (ZHSegmentedControlType)type {
    if (self.sectionTitles != 0) {
        return ZHSegmentedControlTypeText;
    } else if (self.images.count != 0) {
        return ZHSegmentedControlTypeImage;
    }
    return ZHSegmentedControlTypeNone;
}

- (NSInteger)numbersOfSegments {
    if (self.type == ZHSegmentedControlTypeText) {
        return self.sectionTitles.count;
    } else if (self.type == ZHSegmentedControlTypeImage) {
        return self.images.count;
    } else {
        return 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.first) {
        if (self.numbersOfSegments) {
            self.scrollView = [[UIScrollView alloc] init];
            self.scrollView.backgroundColor = [UIColor clearColor];
            self.scrollView.scrollsToTop = NO;
            self.scrollView.showsVerticalScrollIndicator = NO;
            self.scrollView.showsHorizontalScrollIndicator = NO;
            self.scrollView.scrollEnabled = self.isUserDraggable;
            [self addSubview:self.scrollView];
            
            for (int i = 0; i < self.numbersOfSegments; ++i) {
                ZHSegmentedButton *btn = [ZHSegmentedButton buttonWithType:UIButtonTypeCustom];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [btn addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollView addSubview:btn];
                [self.buttons addObject:btn];
            }
            
            if (!self.isIndicatorViewHidden) {
                self.indicatorLayer = [CALayer layer];
                [self.scrollView.layer addSublayer:self.indicatorLayer];
            }
        }
        self.first = NO;
    }
    
    if (self.buttons.count != 0) {
        [self setupSubviews];
        [self animateIndicatorView];
    }
}

- (CAShapeLayer *)arrowLayerWithIndicatorBounds:(CGRect)bounds {
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    CGPoint p3 = CGPointZero;
    
    CGFloat height = bounds.size.height < 10 ? 10 : bounds.size.height;
    if (self.indicatorPosition == ZHSegmentedControlIndicatorPositionBottom) {
        p1 = CGPointMake(bounds.size.width * 0.5, 0.0);
        p2 = CGPointMake(bounds.size.width * 0.5 + height, height);
        p3 = CGPointMake(bounds.size.width * 0.5 - height, height);
    } else {
        p1 = CGPointMake(bounds.size.width * 0.5 - height, 0.0);
        p2 = CGPointMake(bounds.size.width * 0.5 + height, 0.0);
        p3 = CGPointMake(bounds.size.width * 0.5, height);
    }
    
    [arrowPath moveToPoint:p1];
    [arrowPath addLineToPoint:p2];
    [arrowPath addLineToPoint:p3];
    [arrowPath closePath];
    
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.path = arrowPath.CGPath;
    bounds.size.height = height;
    arrowLayer.frame = bounds;
    
    return arrowLayer;
}

- (void)setupSubviews {
    CGFloat segmentWidth = [self maxSegmentWidth];
    CGFloat height = self.bounds.size.height;
    CGFloat y = 0.0f;
    [self.buttons enumerateObjectsUsingBlock:^(ZHSegmentedButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = idx * segmentWidth;
        btn.frame = CGRectMake(x, y, segmentWidth, height);
        btn.backgroundColor = self.boxColor;
        btn.borderStyle = self.borderStyle;
        btn.borderColor = self.borderColor;
        btn.borderWidth = self.borderWidth;
        [btn setupButtonBorder];
        if (self.type == ZHSegmentedControlTypeText) {
            [btn setAttributedTitle:[self attributedTitleAtIndex:idx selected:NO] forState:UIControlStateNormal];
            [btn setAttributedTitle:[self attributedTitleAtIndex:idx selected:YES] forState:UIControlStateSelected];
        } else {
            [btn setImage:self.images[idx] forState:UIControlStateNormal];
            [btn setImage:self.selectedImages[idx] forState:UIControlStateSelected];
        }
    }];
    
    self.indicatorLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    
    self.scrollView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, height);
    self.scrollView.contentSize = CGSizeMake(self.buttons.count * segmentWidth, height);
}

- (void)animateIndicatorView {
    self.selectedButton.selected = NO;
    [self.selectedButton setBackgroundColor:self.boxColor];
    self.selectedButton = [self.buttons objectAtIndex:self.selectedSegmentIndex];
    self.selectedButton.selected = YES;
    [self.selectedButton setBackgroundColor:self.selectionBoxColor];
    
    CGFloat segmentWidth = [self maxSegmentWidth];
    CGFloat centerY = self.indicatorPosition == ZHSegmentedControlIndicatorPositionTop ?
    self.selectionIndicatorHeight * 0.5 :
    self.bounds.size.height - self.selectionIndicatorHeight * 0.5;
    CGRect indicatorBounds = CGRectMake(0.0, 0.0, segmentWidth, self.selectionIndicatorHeight);
    
    if (self.indicatorStyle == ZHSegmentedControlIndicatorStyleArrow) {
        self.indicatorLayer.mask = nil;
        CAShapeLayer *layer = [self arrowLayerWithIndicatorBounds:indicatorBounds];
        indicatorBounds.size.height = layer.bounds.size.height;
        layer.position = CGPointMake(segmentWidth * 0.5, layer.bounds.size.height * 0.5);
        self.indicatorLayer.mask = layer;
    }
    
    if (!CGRectEqualToRect(self.indicatorLayer.frame, CGRectZero) && self.animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.indicatorLayer.bounds = indicatorBounds;
            self.indicatorLayer.position = CGPointMake(self.selectedButton.center.x, centerY);
        } completion:nil];
    } else {
        self.indicatorLayer.bounds = indicatorBounds;
        self.indicatorLayer.position = CGPointMake(self.selectedButton.center.x, centerY);
    }
    
    CGFloat x = self.selectedSegmentIndex * segmentWidth;
    CGRect scrollRect = CGRectMake(x, 0.0f, segmentWidth, self.bounds.size.height);
    CGFloat selectedSegmentOffset = (CGRectGetWidth(self.frame) / 2) - (segmentWidth / 2);
    scrollRect.origin.x -= selectedSegmentOffset;
    scrollRect.size.width += selectedSegmentOffset * 2;
    [self.scrollView scrollRectToVisible:scrollRect animated:self.animated];
}

- (void)segmentButtonClicked:(ZHSegmentedButton *)sender {
    NSInteger index = [self.buttons indexOfObject:sender];
    if (self.selectedSegmentIndex == index) { return; }
    
    [self setSelectedSegmentIndex:index animated:self.shouldAnimateUserSelection];
    
    if (self.superview) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:NO];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated {
    NSParameterAssert(selectedSegmentIndex <= self.numbersOfSegments);
    if (_selectedSegmentIndex == selectedSegmentIndex) { return; }
    
    _selectedSegmentIndex = selectedSegmentIndex;
    _animated = animated;
    
    [self setNeedsLayout];
}

- (CGFloat)maxSegmentWidth {
    __block CGFloat segmentWidth = self.bounds.size.width / self.numbersOfSegments;
    
    if (self.type == ZHSegmentedControlTypeText) {
        [self.sectionTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat w = [self measureTitleAtIndex:idx].width;
            segmentWidth = MAX(w, segmentWidth);
        }];
    } else if (self.type == ZHSegmentedControlTypeImage) {
        [self.images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            segmentWidth = MAX(obj.size.width, segmentWidth);
        }];
    }
    return segmentWidth;
}

// Steal from HMSegmentedControl https://github.com/HeshamMegid/HMSegmentedControl/blob/master/HMSegmentedControl/HMSegmentedControl.m#L860
- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    CGSize size = CGSizeZero;
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    if ([title isKindOfClass:[NSString class]]) {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        size = [(NSString *)title sizeWithAttributes:titleAttrs];
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        size = [(NSAttributedString *)title size];
    } else {
        NSAssert(title == nil, @"Unexpected type of segment title: %@", [title class]);
        size = CGSizeZero;
    }
    return CGRectIntegral((CGRect){CGPointZero, size}).size;
}

- (NSDictionary *)resultingTitleTextAttributes {
    NSDictionary *defaults = @{
                               NSFontAttributeName: [UIFont systemFontOfSize:19.0f],
                               NSForegroundColorAttributeName: [UIColor blackColor],
                               };
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:defaults];
    if (self.titleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.titleTextAttributes];
    }
    
    return [resultingAttrs copy];
}

- (NSDictionary *)resultingSelectedTitleTextAttributes {
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];
    if (self.selectedTitleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.selectedTitleTextAttributes];
    }
    
    return [resultingAttrs copy];
}

- (NSAttributedString *)attributedTitleAtIndex:(NSUInteger)index selected:(BOOL)selected {
    id title = self.sectionTitles[index];
    if ([title isKindOfClass:[NSAttributedString class]]) {
        return (NSAttributedString *)title;
    } else {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        return [[NSAttributedString alloc] initWithString:(NSString *)title attributes:titleAttrs];
    }
}

@end
