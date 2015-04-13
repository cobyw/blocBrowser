//
//  ColorfulToolbar.h
//  BlocBrowser
//
//  Created by Coby West on 4/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorfulToolbar;

@protocol ColorfulToolbarDelegate <NSObject>

@optional

-(void) floatingToolbar:(ColorfulToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(ColorfulToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;

@end

@interface ColorfulToolbar : UIView

-(instancetype) initWithFourTitles:(NSArray *)titles;

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *) title;

-(void) tapFired: (UITapGestureRecognizer *) recognizer;

-(void) panFired:(UIPanGestureRecognizer *)recognizer;

@property (nonatomic, weak) id <ColorfulToolbarDelegate> delegate;

@end
