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

@end

@interface ColorfulToolbar : UIView

-(instancetype) initWithFourTitles:(NSArray *)titles;

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *) title;

@property (nonatomic, weak) id <ColorfulToolbarDelegate> delegate;

@end
