/*
 *  Copyright 2019 Adobe Systems Incorporated. All rights reserved.
 *  This file is licensed to you under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License. You may obtain a copy
 *  of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software distributed under
 *  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 *  OF ANY KIND, either express or implied. See the License for the specific language
 *  governing permissions and limitations under the License.
 *
 */

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface MyView:NSView
@end

@implementation MyView
- (BOOL) isFlipped {
    return YES;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate {
    NSWindow *window_;
    NSView *view_;
}

- (void)applicationDidFinishLaunching: (NSNotification*) aNotification {
    window_ = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 0, 0)
        styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
             NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
        backing: NSBackingStoreBuffered
        defer: NO];
    window_.autorecalculatesKeyViewLoop = YES;
    // We want to make sure Objective C does not decrement the ref counter.
    window_.releasedWhenClosed = NO;

    view_ = [MyView new];
    view_.wantsLayer = YES;
    view_.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    view_.frame = window_.contentLayoutRect;

    auto controller = [[NSViewController alloc] init];
    [controller setView: view_];

    NSString* customFontName = @".SF NS Display";
    auto fontSize = 30;

    NSFont* nsSystemFont = [NSFont systemFontOfSize: fontSize];
    [self appendTextField:@"Font created as [NSFont systemFontOfSize:] - aligned to the top" withFont:nsSystemFont frame:NSMakeRect(10, 10, 1260, 80)];

    // Create the very same font via fontWithName:size
    NSFont* nsFontWithSize = [NSFont fontWithName:customFontName size:fontSize];
    [self appendTextField:@"Font created as [NSFont fontWithName:size:] - baseline misplaced - clipped" withFont:nsFontWithSize frame:NSMakeRect(10, 150, 1260, 80)];

    [window_ setContentViewController: controller];
    [self positionWindow];
    [window_ makeKeyAndOrderFront:nil];

    [window_ makeFirstResponder:window_];
}

-(void)appendTextField:(NSString*)text withFont:(NSFont*)font frame:(NSRect)rect {
    NSTextField* textField = [[NSTextField alloc] initWithFrame:rect];
    [textField setDrawsBackground:NO];
    [textField setWantsLayer:NO];
    textField.stringValue = text;

    auto cell = textField.cell;
    [cell setWraps:NO];
    [cell setScrollable:NO];
    [cell setUsesSingleLineMode:YES]; // We DO need it to work for single line mode !!!

    [textField setFont:font];
    [textField setNeedsDisplay: YES];
    [textField setNeedsLayout: YES];
    [view_ addSubview:textField];
}

- (void)positionWindow {
    int width = 1280;
    int height = 600;

    NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
    [window_ setFrameTopLeftPoint: NSMakePoint(screenRect.origin.x,
                                              screenRect.origin.y + screenRect.size.height)];


    NSRect screenFrame = [[NSScreen mainScreen] frame];
    CGFloat x = 0, y = 0;
    CGFloat vCenter = screenFrame.size.height / 2;
    CGFloat hCenter = screenFrame.size.width / 2;
    x = hCenter - width / 2.f;
    y = vCenter - height / 2.f;

    CGRect newFrame = NSMakeRect(x, y, width, height);
    newFrame.origin.y = screenFrame.origin.y + screenFrame.size.height - newFrame.origin.y - newFrame.size.height;
    [window_ setFrame:CGRectIntegral(newFrame) display:YES];
}

@end

int main(int argc, const char * argv[]) {
    [[NSApplication sharedApplication] setDelegate:[AppDelegate new]];
    return NSApplicationMain(argc, argv);
}

