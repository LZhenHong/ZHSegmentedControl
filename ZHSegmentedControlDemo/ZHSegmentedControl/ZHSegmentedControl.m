#import "ZHSegmentedControl.h"

typedef NS_ENUM(NSUInteger, ZHSegmentedControlType) {
    ZHSegmentedControlTypeNone,
    ZHSegmentedControlTypeText,
    ZHSegmentedControlTypeImage,
    ZHSegmentedControlTypeTextAndImage // Would be implemented someday. 😅😅
};

@interface ZHSegmentedButton : UIButton
@property (nonatomic, assign) ZHSegmentedControlSectionBorderStyle borderStyle;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
- (void)resetButtonBorders;
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

- (void)resetButtonBorders {
    [self.layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
        obj.backgroundColor = self.borderColor.CGColor;
        
    }];
    if (self.borderStyle == ZHSegmentedControlSectionBorderStyleNone) {
        return;
    }
    if (self.borderStyle & ZHSegmentedControlSectionBorderStyleTop) {
        CALayer *topLayer = self.layers[0];
        topLayer.hidden = NO;
        topLayer.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.borderWidth);
    }
    if (self.borderStyle & ZHSegmentedControlSectionBorderStyleLeft) {
        CALayer *leftLayer = self.layers[1];
        leftLayer.hidden = NO;
        leftLayer.frame = CGRectMake(0.0, 0.0, self.borderWidth, self.bounds.size.height);
    }
    if (self.borderStyle & ZHSegmentedControlSectionBorderStyleBottom) {
        CALayer *bottomLayer = self.layers[2];
        bottomLayer.hidden = NO;
        bottomLayer.frame = CGRectMake(0.0, self.bounds.size.height - self.borderWidth, self.bounds.size.width, self.borderWidth);
    }
    if (self.borderStyle & ZHSegmentedControlSectionBorderStyleRight) {
        CALayer *rightLayer = self.layers[3];
        rightLayer.hidden = NO;
        rightLayer.frame = CGRectMake(self.bounds.size.width - self.borderWidth, 0.0, self.borderWidth, self.bounds.size.height);
    }
}
@end

@interface ZHSegmentedControlIndicatorView : UIView
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, readonly) NSInteger totalCount;
@property (nonatomic, readonly) ZHSegmentedControlIndicatorPosition indicatorPosition;
@property (nonatomic, readonly) ZHSegmentedControlIndicatorStyle indicatorStyle;
@property (nonatomic, readonly) CGFloat indicatorHeight;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *boxColor;
@property (nonatomic, strong) UIColor *selectedBoxColor;
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (instancetype)initWithStyle:(ZHSegmentedControlIndicatorStyle)style position:(ZHSegmentedControlIndicatorPosition)position height:(CGFloat)height count:(NSInteger)count;
@end
@interface ZHSegmentedControlIndicatorView ()
@property (nonatomic, strong) CAShapeLayer *indicatorLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@end
static const CGFloat kZHSegmentedControlArrowIndicatorDefaultHeight = 8.0f;
static const CGFloat kZHSegmentedControlIndicatorMargin = 2.0f;
@implementation ZHSegmentedControlIndicatorView {
    BOOL _first;
}

- (instancetype)initWithStyle:(ZHSegmentedControlIndicatorStyle)style position:(ZHSegmentedControlIndicatorPosition)position height:(CGFloat)height count:(NSInteger)count {
    if (self = [super init]) {
        _indicatorStyle = style;
        _indicatorPosition = position;
        _indicatorHeight = height;
        _totalCount = count;
        _index = 0;
        _first = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (!_first) { return; }
    [self.indicatorLayer removeFromSuperlayer];
    self.indicatorLayer = nil;
    [self.backgroundLayer removeFromSuperlayer];
    self.backgroundLayer = nil;
    switch (self.indicatorStyle) {
        case ZHSegmentedControlIndicatorStyleDefault: {
            self.indicatorLayer = [self defalutLayer];
            break;
        }
        case ZHSegmentedControlIndicatorStyleArrow: {
            self.indicatorLayer = [self arrowLayer];
            break;
        }
        case ZHSegmentedControlIndicatorStyleBox: {
            self.indicatorLayer = [self boxLayer];
            break;
        }
        case ZHSegmentedControlIndicatorStyleFlood:
        case ZHSegmentedControlIndicatorStyleFloodHollow: {
            self.backgroundLayer = [self backgroundLayer];
            self.backgroundLayer.contentsScale = [UIScreen mainScreen].scale;
            [self.layer addSublayer:self.backgroundLayer];
            self.indicatorLayer = [self floodLayer];
            break;
        }
    }
    self.indicatorLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.indicatorLayer];
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    _index = index;
    // layer 会有隐式动画
//    if (!animated) {
//        [self.indicatorLayers[0] removeAllAnimations];
//    } else {
//        [self.indicatorLayers[0] ]
//    }
    self.indicatorLayer.frame = [self indicatorFrame];
}

- (void)setIndicatorStyle:(ZHSegmentedControlIndicatorStyle)indicatorStyle {
    _indicatorStyle = indicatorStyle;
    _first = YES;
    [self setNeedsDisplay];
}

- (void)setIndicatorPosition:(ZHSegmentedControlIndicatorPosition)indicatorPosition {
    _indicatorPosition = indicatorPosition;
    
    if (self.indicatorStyle == ZHSegmentedControlIndicatorStyleDefault ||
        self.indicatorStyle == ZHSegmentedControlIndicatorStyleArrow) {
        // Tigger this method to reset the indicatorLayer's frame.
        [self setSelectedIndex:_index animated:NO];
    }
}

- (void)setBoxColor:(UIColor *)boxColor {
    _boxColor = boxColor;
    
    if (self.indicatorStyle == ZHSegmentedControlIndicatorStyleBox) {
        self.backgroundColor = boxColor;
    }
}

- (CAShapeLayer *)defalutLayer {
    CGRect rect = [self indicatorFrame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, rect.size}];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = self.indicatorColor.CGColor;
    layer.frame = rect;
    
    return layer;
}

- (CAShapeLayer *)arrowLayer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat height = self.indicatorHeight < kZHSegmentedControlArrowIndicatorDefaultHeight ?
                                            kZHSegmentedControlArrowIndicatorDefaultHeight : self.indicatorHeight;
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointMake(2 * height, 0.0);;
    CGPoint p3 = CGPointZero;
    
    if (self.indicatorPosition == ZHSegmentedControlIndicatorPositionTop) {
        p3 = CGPointMake(height, height);
    } else {
        p3 = CGPointMake(height, -height);
    }
    
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path closePath];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = self.indicatorColor.CGColor;
    layer.frame = [self indicatorFrame];
    
    return layer;
}

- (CAShapeLayer *)boxLayer {
    CGRect rect = [self indicatorFrame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, rect.size}];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    UIColor *fillColor = self.selectedBoxColor ? self.selectedBoxColor : self.indicatorColor;
    layer.fillColor = fillColor.CGColor;
    layer.frame = rect;
    
    return layer;
}

- (CAShapeLayer *)floodLayer {
    CGRect rect = [self indicatorFrame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, rect.size}
                                                    cornerRadius:rect.size.height * 0.5];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    UIColor *color = self.selectedBoxColor ? self.selectedBoxColor : self.indicatorColor;
    if (self.indicatorStyle == ZHSegmentedControlIndicatorStyleFlood) {
        layer.fillColor = color.CGColor;
    } else if(self.indicatorStyle == ZHSegmentedControlIndicatorStyleFloodHollow) {
        path.lineWidth = kZHSegmentedControlIndicatorMargin;
        layer.strokeColor = color.CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
    }
    layer.frame = rect;
    
    return layer;
}

- (CAShapeLayer *)backgroundLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    cornerRadius:self.bounds.size.height * 0.5];
    [path addClip];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    UIColor *fillColor = self.boxColor ? self.boxColor : self.indicatorColor;
    layer.fillColor = fillColor.CGColor;
    layer.frame = self.bounds;
    
    return layer;
}

- (CGRect)indicatorFrame {
    CGFloat x = 0.0, y = 0.0, w = 0.0, h = 0.0;
    CGFloat eachW = self.bounds.size.width / self.totalCount;
    switch (self.indicatorStyle) {
        case ZHSegmentedControlIndicatorStyleDefault: {
            w = eachW;
            x = self.index * w;
            h = self.indicatorHeight;
            y = self.indicatorPosition == ZHSegmentedControlIndicatorPositionTop ? 0.0 : self.bounds.size.height - h;
            break;
        }
        case ZHSegmentedControlIndicatorStyleArrow: {
            h = self.indicatorHeight < kZHSegmentedControlArrowIndicatorDefaultHeight ?
                                       kZHSegmentedControlArrowIndicatorDefaultHeight : self.indicatorHeight;
            w = 2 * h;
            x = eachW * (0.5 + self.index) - h;
            y = self.indicatorPosition == ZHSegmentedControlIndicatorPositionTop ? 0.0 : self.bounds.size.height - h;
            break;
        }
        case ZHSegmentedControlIndicatorStyleBox: {
            w = eachW;
            h = self.bounds.size.height;
            x = self.index * w;
            y = 0.0;
            break;
        }
        case ZHSegmentedControlIndicatorStyleFlood:
        case ZHSegmentedControlIndicatorStyleFloodHollow: {
            w = eachW - 2 * kZHSegmentedControlIndicatorMargin;
            h = self.bounds.size.height - 2 * kZHSegmentedControlIndicatorMargin;
            x = self.index * eachW + kZHSegmentedControlIndicatorMargin;
            y = kZHSegmentedControlIndicatorMargin;
            break;
        }
    }
    return CGRectMake(x, y, w, h);
}

@end

@interface ZHSegmentedControl ()
@property (nonatomic, strong) NSMutableArray<ZHSegmentedButton *> *buttons;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) ZHSegmentedControlIndicatorView *indicatorView;
@property (nonatomic, weak) ZHSegmentedButton *selectedButton;

@property (nonatomic, assign) ZHSegmentedControlType type;

@property (nonatomic, strong) NSSet<NSString *> *kvoProperties;
@property (nonatomic, strong) NSSet<NSString *> *borderKVOProperties;
@property (nonatomic, strong) NSSet<NSString *> *indicatorKVOProperties;
@end

static void *ZHSegmentedControlObserverContext = &ZHSegmentedControlObserverContext;

@implementation ZHSegmentedControl {
    BOOL _first, _animated;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setTitles:titles];
        
        [self p_commonInit];
    }
    return self;
}

+ (instancetype)segmentedControlWithTitles:(NSArray<NSString *> *)titles {
    return [[self alloc] initWithTitles:titles];
}

- (instancetype)initWithImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setImages:images selectedImages:selectedImages];
        
        [self p_commonInit];
    }
    return self;
}

+ (instancetype)segmentedControlWithImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages {
    return [[self alloc] initWithImages:images selectedImages:selectedImages];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self p_commonInit];
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = [titles copy];
}

- (void)setImages:(NSArray<UIImage *> *)images selectedImages:(NSArray<UIImage *> *)selectedImages {
    NSParameterAssert(images.count == selectedImages.count);
    _images = [images copy];
    _selectedImages = [selectedImages copy];
}

- (void)p_commonInit {
    _indicatorPosition = ZHSegmentedControlIndicatorPositionBottom;
    _indicatorStyle = ZHSegmentedControlIndicatorStyleDefault;
    _indicatorHeight = 1.0f;
    _indicatorColor = [UIColor colorWithRed:52.0f / 255.0f green:181.0f / 255.0f blue:229.0f / 255.0f alpha:1.0f];
    _boxColor = [UIColor clearColor];
    _selectedBoxColor = [UIColor clearColor];
    _borderStyle = ZHSegmentedControlSectionBorderStyleNone;
    _borderColor = [UIColor blackColor];
    _borderWidth = 1.0f;
    _userDraggable = YES;
    _shouldAnimateUserSelection = YES;
    _selectedSegmentIndex = 0;
    
    _first = YES;
    _buttons = [NSMutableArray array];
    self.backgroundColor = [UIColor whiteColor];
    
    [self p_setupKVOObserver];
}

- (void)p_setupKVOObserver {
    _indicatorKVOProperties = [NSSet setWithObjects:NSStringFromSelector(@selector(indicatorPosition)),
                                                    NSStringFromSelector(@selector(indicatorStyle)),
                                                    NSStringFromSelector(@selector(indicatorHeight)),
                                                    NSStringFromSelector(@selector(indicatorColor)),
                                                    NSStringFromSelector(@selector(boxColor)),
                                                    NSStringFromSelector(@selector(selectedBoxColor)),
                                                    nil];
    _borderKVOProperties = [NSSet setWithObjects:NSStringFromSelector(@selector(borderStyle)),
                                                 NSStringFromSelector(@selector(borderColor)),
                                                 NSStringFromSelector(@selector(borderWidth)),
                                                 nil];
    _kvoProperties = [NSSet setWithObjects:NSStringFromSelector(@selector(titles)),
                                           NSStringFromSelector(@selector(titleTextAttributes)),
                                           NSStringFromSelector(@selector(selectedTitleTextAttributes)),
                                           NSStringFromSelector(@selector(images)),
                                           NSStringFromSelector(@selector(selectedImages)),
                                           nil];
    [_indicatorKVOProperties enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew context:ZHSegmentedControlObserverContext];
        }
    }];
    [_borderKVOProperties enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew context:ZHSegmentedControlObserverContext];
        }
    }];
    [_kvoProperties enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ZHSegmentedControlObserverContext];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (_first || context != ZHSegmentedControlObserverContext) { return; }
    id newValue = [change valueForKey:NSKeyValueChangeNewKey];
    SEL selector = NSSelectorFromString(keyPath);
    if ([self.kvoProperties containsObject:keyPath]) {
        id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
        if ([self respondsToSelector:selector] && newValue != nil) {
            if (([keyPath isEqualToString:@"titles"] || [keyPath isEqualToString:@"images"] ||
                 [keyPath isEqualToString:@"selectedImages"]) && ![oldValue isMemberOfClass:[NSNull class]]) {
                _first = !([newValue count] == [oldValue count]);
            }
            [self setNeedsLayout];
        }
    } else if ([self.indicatorKVOProperties containsObject:keyPath]) {
        if ([self.indicatorView respondsToSelector:selector] && newValue != nil) {
            [self.indicatorView setValue:newValue forKeyPath:keyPath];
        }
    } else if ([self.borderKVOProperties containsObject:keyPath]) {
        [self.buttons enumerateObjectsUsingBlock:^(ZHSegmentedButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:selector]) {
                [obj setValue:newValue forKey:keyPath];
                [obj resetButtonBorders];
            }
        }];
    }
}

- (void)dealloc {
    [self.indicatorKVOProperties enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self removeObserver:self forKeyPath:obj context:ZHSegmentedControlObserverContext];
        }
    }];
    [self.borderKVOProperties enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self removeObserver:self forKeyPath:obj context:ZHSegmentedControlObserverContext];
        }
    }];
    [self.kvoProperties enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self respondsToSelector:NSSelectorFromString(obj)]) {
            [self removeObserver:self forKeyPath:obj context:ZHSegmentedControlObserverContext];
        }
    }];
    self.indicatorKVOProperties = nil;
    self.borderKVOProperties = nil;
    self.kvoProperties = nil;
}

- (ZHSegmentedControlType)type {
    if (self.titles.count != 0) {
        return ZHSegmentedControlTypeText;
    } else if (self.images.count != 0) {
        return ZHSegmentedControlTypeImage;
    }
    return ZHSegmentedControlTypeNone;
}

- (NSInteger)numbersOfSegments {
    if (self.type == ZHSegmentedControlTypeText) {
        return self.titles.count;
    } else if (self.type == ZHSegmentedControlTypeImage) {
        return self.images.count;
    } else {
        return 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_first) {
        if (self.numbersOfSegments) {
            self.scrollView = [[UIScrollView alloc] init];
            self.scrollView.backgroundColor = [UIColor clearColor];
            self.scrollView.scrollsToTop = NO;
            self.scrollView.showsVerticalScrollIndicator = NO;
            self.scrollView.showsHorizontalScrollIndicator = NO;
            self.scrollView.scrollEnabled = self.isUserDraggable;
            [self addSubview:self.scrollView];
            
            if (self.indicatorPosition != ZHSegmentedControlIndicatorPositionNone) {
                self.indicatorView = [[ZHSegmentedControlIndicatorView alloc] initWithStyle:self.indicatorStyle
                                                                                   position:self.indicatorPosition
                                                                                     height:self.indicatorHeight
                                                                                      count:self.numbersOfSegments];
                self.indicatorView.indicatorColor = self.indicatorColor;
                self.indicatorView.boxColor = self.boxColor;
                self.indicatorView.selectedBoxColor = self.selectedBoxColor;
                [self.scrollView addSubview:self.indicatorView];
            }
            
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            CGFloat w = [self maxSegmentWidth];
            CGFloat h = self.bounds.size.height;
            for (int i = 0; i < self.numbersOfSegments; ++i) {
                x = i * w;
                ZHSegmentedButton *btn = [[ZHSegmentedButton alloc] init];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [btn addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = CGRectMake(x, y, w, h);
                [self.scrollView addSubview:btn];
                [self.buttons addObject:btn];
            }
            self.scrollView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, h);
            self.scrollView.contentSize = CGSizeMake(self.buttons.count * w, h);
            self.indicatorView.frame = (CGRect){CGPointZero, self.scrollView.contentSize};
        }
        _first = NO;
    }
    
    if (self.buttons.count != 0) {
        [self p_setupSubviews];
        [self p_animateIndicatorView];
    }
}

- (void)p_setupSubviews {
    [self.buttons enumerateObjectsUsingBlock:^(ZHSegmentedButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.type == ZHSegmentedControlTypeText) {
            [btn setAttributedTitle:[self attributedTitleAtIndex:idx selected:NO] forState:UIControlStateNormal];
            [btn setAttributedTitle:[self attributedTitleAtIndex:idx selected:YES] forState:UIControlStateSelected];
        } else {
            [btn setImage:self.images[idx] forState:UIControlStateNormal];
            [btn setImage:self.selectedImages[idx] forState:UIControlStateSelected];
        }
    }];
}

- (void)p_animateIndicatorView {
    self.selectedButton.selected = NO;
    self.selectedButton = [self.buttons objectAtIndex:self.selectedSegmentIndex];
    self.selectedButton.selected = YES;
    
    [self.indicatorView setSelectedIndex:self.selectedSegmentIndex animated:_animated];
    
    CGFloat segmentWidth = [self maxSegmentWidth];
    CGFloat x = self.selectedSegmentIndex * segmentWidth;
    CGRect scrollRect = CGRectMake(x, 0.0f, segmentWidth, self.bounds.size.height);
    CGFloat selectedSegmentOffset = (CGRectGetWidth(self.frame) / 2) - (segmentWidth / 2);
    scrollRect.origin.x -= selectedSegmentOffset;
    scrollRect.size.width += selectedSegmentOffset * 2;
    [self.scrollView scrollRectToVisible:scrollRect animated:_animated];
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
        [self.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

// Steal from HMSegmentedControl. https://github.com/HeshamMegid/HMSegmentedControl/blob/master/HMSegmentedControl/HMSegmentedControl.m#L860
- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    id title = self.titles[index];
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
    id title = self.titles[index];
    if ([title isKindOfClass:[NSAttributedString class]]) {
        return (NSAttributedString *)title;
    } else {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        return [[NSAttributedString alloc] initWithString:(NSString *)title attributes:titleAttrs];
    }
}

@end
