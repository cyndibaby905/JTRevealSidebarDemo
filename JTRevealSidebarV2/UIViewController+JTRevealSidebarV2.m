/*
 * This file is part of the JTRevealSidebar package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIViewController+JTRevealSidebarV2.h"
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"
#import <objc/runtime.h>
UITapGestureRecognizer *tapGesForLeftSidebar;
UISwipeGestureRecognizer *swipeGesForLeftSidebar;
UIPanGestureRecognizer *panGesForLeftSidebar;

UITapGestureRecognizer *tapGesForRightSidebar;
UISwipeGestureRecognizer *swipeGesForRightSidebar;
UIPanGestureRecognizer *panGesForRightSidebar;


@interface UIViewController (JTRevealSidebarV2Private)

- (UIViewController *)selectedViewController;
- (void)revealLeftSidebar:(BOOL)showLeftSidebar;
- (void)revealRightSidebar:(BOOL)showRightSidebar;

@end

@implementation UIViewController (JTRevealSidebarV2)

static char *revealedStateKey;

- (void)setRevealedState:(JTRevealedState)revealedState {
    JTRevealedState currentState = self.revealedState;

    if (revealedState == currentState) {
        return;
    }

    id <JTRevealSidebarV2Delegate> delegate = [self selectedViewController].navigationItem.revealSidebarDelegate;
    // notify delegate for controller will change state
    if ([delegate respondsToSelector:@selector(willChangeRevealedStateForViewController:)]) {
        [delegate willChangeRevealedStateForViewController:self];
    }

    objc_setAssociatedObject(self, &revealedStateKey, [NSNumber numberWithInt:revealedState], OBJC_ASSOCIATION_RETAIN);

    switch (currentState) {
        case JTRevealedStateNo:
            if (revealedState == JTRevealedStateLeft) {
                [self revealLeftSidebar:YES];
            } else if (revealedState == JTRevealedStateRight) {
                [self revealRightSidebar:YES];
            } else {
                // Do Nothing
            }
            break;
        case JTRevealedStateLeft:
            if (revealedState == JTRevealedStateNo) {
                [self revealLeftSidebar:NO];
            } else if (revealedState == JTRevealedStateRight) {
                [self revealLeftSidebar:NO];
                [self revealRightSidebar:YES];
            } else {
                [self revealLeftSidebar:YES];
            }
            break;
        case JTRevealedStateRight:
            if (revealedState == JTRevealedStateNo) {
                [self revealRightSidebar:NO];
            } else if (revealedState == JTRevealedStateLeft) {
                [self revealRightSidebar:NO];
                [self revealLeftSidebar:YES];
            } else {
                [self revealRightSidebar:YES];
            }
        default:
            break;
    }
}

- (void)closeLeftSideBar:(id)sender {
    [self toggleRevealState:JTRevealedStateLeft];
}

- (void)panLeftSideBar:(UIPanGestureRecognizer*)ges {
    id <JTRevealSidebarV2Delegate> delegate = [self selectedViewController].navigationItem.revealSidebarDelegate;
    
    if ( ! [delegate respondsToSelector:@selector(viewForLeftSidebar)]) {
        return;
    }
    UIView *revealedView = [delegate viewForLeftSidebar];
    CGFloat width = CGRectGetWidth(revealedView.frame);
    CGPoint translate = [ges translationInView:self.view];
    CGRect frame = self.view.frame;
    
    CGFloat offsetX = frame.size.width + translate.x - (frame.size.width - width);
    if (offsetX <= 0) {
        offsetX = 0.f;
    }
    else if(offsetX >= width) {
        offsetX = width;
    }
    frame.origin.x = offsetX;
    self.view.frame = frame;
    
    if (ges.state == UIGestureRecognizerStateEnded) {
        [self toggleRevealState:JTRevealedStateLeft];
    }
    else if (ges.state == UIGestureRecognizerStateCancelled) {
        [self toggleRevealState:JTRevealedStateLeft];
    }
}

- (void)closeRightSideBar:(id)sender {
    [self toggleRevealState:JTRevealedStateRight];
}

- (void)panRightSideBar:(UIPanGestureRecognizer*)ges {
    id <JTRevealSidebarV2Delegate> delegate = [self selectedViewController].navigationItem.revealSidebarDelegate;
    
    if ( ! [delegate respondsToSelector:@selector(viewForRightSidebar)]) {
        return;
    }
    UIView *revealedView = [delegate viewForRightSidebar];
    CGFloat width = CGRectGetWidth(revealedView.frame);
    CGPoint translate = [ges translationInView:self.view];
    CGRect frame = self.view.frame;
    
    CGFloat offsetX = -width + translate.x;
    
    
    
    
    if (offsetX <= -width) {
        offsetX = -width;
    }
    else if(offsetX >= 0) {
        offsetX = 0;
    }
    frame.origin.x = offsetX;
    self.view.frame = frame;
    
    if (ges.state == UIGestureRecognizerStateEnded) {
        [self toggleRevealState:JTRevealedStateRight];
    }
    else if (ges.state == UIGestureRecognizerStateCancelled) {
        [self toggleRevealState:JTRevealedStateRight];
    }
}

- (JTRevealedState)revealedState {
    return (JTRevealedState)[objc_getAssociatedObject(self, &revealedStateKey) intValue];
}

- (CGAffineTransform)baseTransform {
    CGAffineTransform baseTransform;
    
    return self.view.transform;
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            baseTransform = CGAffineTransformIdentity;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            baseTransform = CGAffineTransformMakeRotation(-M_PI/2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            baseTransform = CGAffineTransformMakeRotation(M_PI/2);
            break;
        default:
            baseTransform = CGAffineTransformMakeRotation(M_PI);
            break;
    }
    return baseTransform;
}

// Converting the applicationFrame from UIWindow is founded to be always correct
- (CGRect)applicationViewFrame {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect expectedFrame = [self.view convertRect:appFrame fromView:nil];
    return expectedFrame;
}

- (void)toggleRevealState:(JTRevealedState)openingState {
    JTRevealedState state = openingState;
    if (self.revealedState == openingState) {
        state = JTRevealedStateNo;
    }
    [self setRevealedState:state];
}

@end


@implementation UIViewController (JTRevealSidebarV2Private)

- (UIViewController *)selectedViewController {
    return self;
}

// Looks like we collasped with the official animationDidStop:finished:context: 
// implementation in the default UITabBarController here, that makes us never
// getting the callback we wanted. So we renamed the callback method here.
- (void)animationDidStop2:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"hideSidebarView"]) {
        // Remove the sidebar view after the sidebar closes.
        UIView *view = [self.view.superview viewWithTag:(int)context];
        [self.view removeGestureRecognizer:tapGesForLeftSidebar];
        tapGesForLeftSidebar = nil;
        [self.view removeGestureRecognizer:swipeGesForLeftSidebar];
        swipeGesForLeftSidebar = nil;
        [self.view removeGestureRecognizer:panGesForLeftSidebar];
        panGesForLeftSidebar = nil;
        
        [self.view removeGestureRecognizer:tapGesForRightSidebar];
        tapGesForRightSidebar = nil;
        [self.view removeGestureRecognizer:swipeGesForRightSidebar];
        swipeGesForRightSidebar = nil;
        [self.view removeGestureRecognizer:panGesForRightSidebar];
        panGesForRightSidebar = nil;
        
        [view removeFromSuperview];
    }
    
    // notify delegate for controller changed state
    id <JTRevealSidebarV2Delegate> delegate = 
        [self selectedViewController].navigationItem.revealSidebarDelegate;
    if ([delegate respondsToSelector:@selector(didChangeRevealedStateForViewController:)]) {
        [delegate didChangeRevealedStateForViewController:self];
    }
}

- (void)revealLeftSidebar:(BOOL)showLeftSidebar {

    id <JTRevealSidebarV2Delegate> delegate = [self selectedViewController].navigationItem.revealSidebarDelegate;

    if ( ! [delegate respondsToSelector:@selector(viewForLeftSidebar)]) {
        return;
    }

    UIView *revealedView = [delegate viewForLeftSidebar];
    revealedView.tag = LEFT_SIDEBAR_VIEW_TAG;
    CGFloat width = CGRectGetWidth(revealedView.frame);

    if (showLeftSidebar) {
        if (![self.view.superview viewWithTag:LEFT_SIDEBAR_VIEW_TAG]) {
            [self.view.superview insertSubview:revealedView belowSubview:self.view];
        }
        tapGesForLeftSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftSideBar:)];
        tapGesForLeftSidebar.numberOfTapsRequired = 1;
        tapGesForLeftSidebar.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tapGesForLeftSidebar];
        
        swipeGesForLeftSidebar = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftSideBar:)];
        swipeGesForLeftSidebar.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeGesForLeftSidebar];
        
        
        panGesForLeftSidebar = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeftSideBar:)];
        [self.view addGestureRecognizer:panGesForLeftSidebar];
        [UIView beginAnimations:@"" context:nil];
//        self.view.transform = CGAffineTransformTranslate([self baseTransform], width, 0);
        
        self.view.frame = CGRectOffset(self.view.bounds, width, 0);
        
    } else {
        [UIView beginAnimations:@"hideSidebarView" context:(void *)LEFT_SIDEBAR_VIEW_TAG];
        //        self.view.transform = CGAffineTransformTranslate([self baseTransform], -width, 0);
        
        self.view.frame = CGRectOffset(self.view.bounds, 0, 0);
    }

    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop2:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    NSLog(@"%@", NSStringFromCGAffineTransform(self.view.transform));


    [UIView commitAnimations];
}

- (void)revealRightSidebar:(BOOL)showRightSidebar {

    id <JTRevealSidebarV2Delegate> delegate = [self selectedViewController].navigationItem.revealSidebarDelegate;
    
    if ( ! [delegate respondsToSelector:@selector(viewForRightSidebar)]) {
        return;
    }

    UIView *revealedView = [delegate viewForRightSidebar];
    revealedView.tag = RIGHT_SIDEBAR_VIEW_TAG;
    CGFloat width = CGRectGetWidth(revealedView.frame);
    revealedView.frame = (CGRect){self.view.frame.size.width - width, revealedView.frame.origin.y, revealedView.frame.size};

    if (showRightSidebar) {
        if (![self.view.superview viewWithTag:RIGHT_SIDEBAR_VIEW_TAG]) {
            [self.view.superview insertSubview:revealedView belowSubview:self.view];
        }

        tapGesForRightSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeRightSideBar:)];
        tapGesForRightSidebar.numberOfTapsRequired = 1;
        tapGesForRightSidebar.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tapGesForRightSidebar];
        
        swipeGesForRightSidebar = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeRightSideBar:)];
        swipeGesForRightSidebar.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeGesForRightSidebar];
        
        
        panGesForRightSidebar = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRightSideBar:)];
        [self.view addGestureRecognizer:panGesForRightSidebar];
        
        [UIView beginAnimations:@"" context:nil];
//        self.view.transform = CGAffineTransformTranslate([self baseTransform], -width, 0);
        
        self.view.frame = CGRectOffset(self.view.bounds, -width, 0);
    } else {
        [UIView beginAnimations:@"hideSidebarView" context:(void *)RIGHT_SIDEBAR_VIEW_TAG];
//        self.view.transform = CGAffineTransformTranslate([self baseTransform], width, 0);
        self.view.frame = CGRectOffset(self.view.bounds, 0, 0);
    }
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop2:finished:context:)];
    [UIView setAnimationDelegate:self];

    NSLog(@"%@", NSStringFromCGAffineTransform(self.view.transform));
    
    [UIView commitAnimations];
}

@end


@implementation UINavigationController (JTRevealSidebarV2)

- (UIViewController *)selectedViewController {
    return self.topViewController;
}

@end