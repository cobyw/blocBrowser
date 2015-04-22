//
//  ColorfulToolbar.m
//  BlocBrowser
//
//  Created by Coby West on 4/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ColorfulToolbar.h"

@interface ColorfulToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray *labelsArray;

//gestures
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation ColorfulToolbar

#pragma mark Initializer and layout

-(instancetype) initWithFourTitles:(NSArray *)titles
{
    self = [super init];
    
    if (self)
    {
        self.text =nil;
        self.currentTitles = titles;
        self.colors = [@[[ UIColor colorWithRed:199/255. green:158/255. blue:203/255. alpha:1],
                        [ UIColor colorWithRed:255/255. green:105/255. blue:97/255. alpha:1],
                        [ UIColor colorWithRed:222/255. green:165/255. blue:164/255. alpha:1],
                        [ UIColor colorWithRed:255/255. green:179/255. blue:71/255. alpha:1]] mutableCopy];

        
        self.labelsArray =[[NSMutableArray alloc] init];
        
        [self drawObject];
        
        self.labels = self.labelsArray;
        
        for (UILabel *thisLabel in self.labels)
        {
            [self addSubview:thisLabel];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    return self;
}

- (void) drawObject
{
    for (NSString *currentTitle in self.currentTitles)
    {
        UILabel *label = [[UILabel alloc] init];
        label.userInteractionEnabled = NO;
        label.alpha =0.25;
        
        NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
        NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
        UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        label.text = titleForThisLabel;
        label.backgroundColor = colorForThisLabel;
        label.textColor = [UIColor whiteColor];
        
        [self.labelsArray addObject:label];
//        [label layoutIfNeeded];
    }
}

- (void) layoutSubviews
{
    for (UILabel *thisLabel in self.labels)
    {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) /2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) /2;
        CGFloat labelX=0;
        CGFloat labelY=0;
        
        if (currentLabelIndex < 2)
        {
            labelY = 0;
        }
        else
        {
            labelY = CGRectGetHeight(self.bounds)/2;
        }
        
        if (currentLabelIndex % 2 == 0)
        {
            labelX = 0;
        }
        else
        {
            labelX= labelWidth;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        
    }
}

#pragma mark - Touch Handling

-(void) tapFired: (UITapGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView])
        {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)])
            {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *) tappedView).text];
            }
        }
    }
}

-(void) panFired:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)])
        {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) pinchFired:(UIPinchGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self.delegate floatingToolbar:self didTryToScale:recognizer.scale];
        [recognizer setScale:1.];
    }
}

-(void) longPressFired:(UILongPressGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        NSLog(@"Long Press fired");
        //move the colors around within the color array
        int numberOfColors = [self.colors count];
        for (int x = 0; x < numberOfColors; x++)
        {
            int temp = x+1;
            if (temp != numberOfColors)
            {
                [self.colors exchangeObjectAtIndex:x withObjectAtIndex:temp];
            }
            else
            {
                [self.colors exchangeObjectAtIndex:x withObjectAtIndex:0];
            }
            
        }
        [self updateLabels];

        //set the array to actually show the new colors
    }
}

-(void) updateLabels
{
    int numberOfLabels = [self.labels count];
    for (int index = 0; index < numberOfLabels; index++)
    {
        UIColor *labelColor = [self.colors objectAtIndex:index];
        UILabel *labelToUpdate = [self.labels objectAtIndex:index];
        labelToUpdate.backgroundColor = labelColor;
        [labelToUpdate layoutIfNeeded];
    }
}


#pragma mark - Button Enabling

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title
{
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound)
    {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0: 0.25;
    }
}

@end