//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Coby West on 3/30/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCWebBrowserViewController.h"

@interface BLCWebBrowserViewController ()<UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;

//button bar
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;

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
    
    //backButton set up
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back Command") forState:UIControlStateNormal];
    
    
    //forwardButton set up
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward Command") forState:UIControlStateNormal];
    
    //stopButton set up
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop Command") forState:UIControlStateNormal];
    
    //reloadButton set up
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    [self.reloadButton setTitle:NSLocalizedString(@"Reload", @"Reload Command") forState:UIControlStateNormal];
    
    [self addButtonTargets];
    
    //adding in the views piecemeal
    /*
    [mainView addSubview:self.webview];
    [mainView addSubview:self.textField];
    [mainView addSubview:self.backButton];
    [mainView addSubview:self.forwardButton];
    [mainView addSubview:self.stopButton];
    [mainView addSubview:self.reloadButton];
     */
    
    //adding in the views with a fancy loop
    for(UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton])
    {
        [mainView addSubview:viewToAdd];
    }
    
    
    self.view = mainView;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = width /4;
    
    //now assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    CGFloat textFieldHeight = CGRectGetMaxY(self.textField.frame);
    self.webview.frame = CGRectMake(0, textFieldHeight, width, browserHeight);
    CGFloat browserFieldHeight = CGRectGetMaxY(self.webview.frame);
    
    //Add in the buttons with a fancy loop
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton])
    {
        thisButton.frame = CGRectMake(currentButtonX, browserFieldHeight, buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
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
    
    //updates buttons
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
    self.stopButton.enabled = self.isLoading > 0;
    self.reloadButton.enabled = self.isLoading <= 0 && self.webview.request.URL;
    
}

-(void) resetWebView
{
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    [self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

-(void) addButtonTargets
{
    //removes the previous targets
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton])
    {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    
    //resets the new targets
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
}

@end
