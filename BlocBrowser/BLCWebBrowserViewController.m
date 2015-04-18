//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Coby West on 3/30/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "ColorfulToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back Command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward Command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop Command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload Command")

@interface BLCWebBrowserViewController ()<UIWebViewDelegate, UITextFieldDelegate, ColorfulToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;

@property(nonatomic, strong) ColorfulToolbar *awesomeToolbar;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) NSUInteger *isLoading;

@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

-(void)loadView {
    UIView *mainView = [UIView new];//the course is telling me specifically to do this, bad practice?
    
    //webview set up
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    //textField set up
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Search Query", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[ColorfulToolbar alloc] initWithFourTitles:@[kWebBrowserBackString,
                                                                        kWebBrowserForwardString,
                                                                        kWebBrowserRefreshString,
                                                                        kWebBrowserStopString]];
    self.awesomeToolbar.delegate = self;
    
    //adding in the views with a fancy loop
    for(UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar])
    {
        [mainView addSubview:viewToAdd];
    }
    
    
    self.view = mainView;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //now assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    CGFloat textFieldHeight = CGRectGetMaxY(self.textField.frame);
    self.webview.frame = CGRectMake(0, textFieldHeight, width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}


-(void) floatingToolbar:(ColorfulToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset
{
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame))
    {
        toolbar.frame = potentialNewFrame;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = [[NSMutableString alloc] init];
    
    URLString = textField.text;
    
    NSRange spaceRange = [URLString rangeOfString:@" "];
    NSRange dotRange = [URLString rangeOfString:@"."];
    
    if (spaceRange.location != NSNotFound || dotRange.location == NSNotFound) //if there is a space or no dot its a search query
    {
        URLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        URLString = [NSString stringWithFormat:@"google.com/search?q=%@", URLString];
    }
    NSURL *URL = [NSURL URLWithString:URLString];

    if (!URL.scheme) {
        //if the user forgot the http bit
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }

    if (URL){
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    return NO;
}

#pragma mark - UIWebViewDelegate

-(void) webViewDidStartLoad:(UIWebView *)webView{
    self.isLoading ++;
    [self updateButtonsAndTitle];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    self.isLoading --;
    [self updateButtonsAndTitle];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[error localizedDescription]
                                                   delegate: nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [self updateButtonsAndTitle];
    self.isLoading--;
}

#pragma mark - Miscellaneous

-(void) updateButtonsAndTitle
{
    //updates title bar
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if(webpageTitle)
    {
        self.title = webpageTitle;
    }
    else
    {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.isLoading > 0)
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.isLoading > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.isLoading == 0 forButtonWithTitle:kWebBrowserRefreshString];
    
}

-(void) resetWebView
{
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    

    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}



#pragma mark - ColorfulToolbarDelegate

- (void) floatingToolbar:(ColorfulToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title
{
    if ([title isEqual:kWebBrowserBackString])
    {
        [self.webview goBack];
    }
    else if ([title isEqual:kWebBrowserForwardString])
    {
        [self.webview goForward];
    }
    else if ([title isEqual:kWebBrowserStopString])
    {
        [self.webview stopLoading];
    }
    else if ([title isEqual:kWebBrowserRefreshString])
    {
        [self.webview reload];
    }
}

@end
