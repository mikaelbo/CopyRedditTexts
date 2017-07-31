@interface BaseTextView : UITextView
- (void)MB_addLongPressRecognizer;
@end

@interface Comment : NSObject
@property (nonatomic, copy) NSString *bodyText;
@end

@interface CommentTextView : UIView 
@property (nonatomic, strong) Comment *comment;
- (void)MB_addLongPressRecognizer;
- (BOOL)MB_canPerformCopy;
@end

@interface Post : NSObject
@property (nonatomic, copy) NSString *selfText;
@end

@interface FeedPostSelfTextView : UIView
@property (nonatomic, strong) Post *post;
- (void)MB_addLongPressRecognizer;
- (BOOL)MB_canPerformCopy;
@end

// Post title

%hook BaseTextView

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(copy:) ? YES : %orig;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    [self MB_addLongPressRecognizer];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aCoder {
    self = %orig;
    [self MB_addLongPressRecognizer];
    return self;
}

%new
- (void)MB_addLongPressRecognizer {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(MB_didLongPress:)];
    recognizer.minimumPressDuration = 0.25;
    [self addGestureRecognizer:recognizer];
    self.userInteractionEnabled = YES;
}

%new
- (void)MB_didLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan && self.text.length) {  return;  }
    [self becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:self.frame inView:self.superview];
    [menuController setMenuVisible:YES animated:YES];
}

%new
- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
}

%end

// Post body

%hook FeedPostSelfTextView

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(copy:) ? YES : %orig;
}

- (void)configureWithData:(id)data andDelegate:(id)delegate {
    %orig;
    [self MB_addLongPressRecognizer];
}

%new
- (void)MB_addLongPressRecognizer {
    if (![self MB_canPerformCopy]) { return; }
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(MB_didLongPress:)];
    recognizer.minimumPressDuration = 0.25;
    [self addGestureRecognizer:recognizer];
    self.userInteractionEnabled = YES;
}

%new
- (BOOL)MB_canPerformCopy {
    return [self respondsToSelector:@selector(post)] ? [self.post respondsToSelector:@selector(selfText)] : NO;
}

%new
- (void)MB_didLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {  return;  }
    [self becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:self.frame inView:self.superview];
    [menuController setMenuVisible:YES animated:YES];
}

%new
- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.post.selfText];
}

%end

// Comment

%hook CommentTextView

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(copy:) ? YES : %orig;
}

- (void)configureWithData:(id)data andDelegate:(id)delegate {
    %orig;
    [self MB_addLongPressRecognizer];
}

%new
- (void)MB_addLongPressRecognizer {
    if (![self MB_canPerformCopy]) { return; }
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(MB_didLongPress:)];
    recognizer.minimumPressDuration = 0.25;
    [self addGestureRecognizer:recognizer];
    self.userInteractionEnabled = YES;
}

%new
- (BOOL)MB_canPerformCopy {
    return [self respondsToSelector:@selector(comment)] ? [self.comment respondsToSelector:@selector(bodyText)] : NO;
}

%new
- (void)MB_didLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {  return;  }
    [self becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:self.frame inView:self.superview];
    [menuController setMenuVisible:YES animated:YES];
}

%new
- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.comment.bodyText];
}

%end
