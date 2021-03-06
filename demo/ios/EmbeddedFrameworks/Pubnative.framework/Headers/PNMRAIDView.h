//
//  PNMRAIDView.h
//  MRAID
//
//  Created by Can Soykarafakili
//  Copyright (c) 2017 PubNative
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@class PNMRAIDView;
@protocol PNMRAIDServiceDelegate;

// A delegate for MRAIDView to listen for notification on ad ready or expand related events.
@protocol PNMRAIDViewDelegate <NSObject>

@optional

// These callbacks are for basic banner ad functionality.
- (void)mraidViewAdReady:(PNMRAIDView *)mraidView;
- (void)mraidViewAdFailed:(PNMRAIDView *)mraidView;
- (void)mraidViewWillExpand:(PNMRAIDView *)mraidView;
- (void)mraidViewDidClose:(PNMRAIDView *)mraidView;
- (void)mraidViewNavigate:(PNMRAIDView *)mraidView withURL:(NSURL *)url;

// This callback is to ask permission to resize an ad.
- (BOOL)mraidViewShouldResize:(PNMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen;

@end

@interface PNMRAIDView : UIView

@property (nonatomic, strong) id<PNMRAIDViewDelegate> delegate;
@property (nonatomic, strong) id<PNMRAIDServiceDelegate> serviceDelegate;
@property (nonatomic, weak, setter = setRootViewController:) UIViewController *rootViewController;
@property (nonatomic, assign, getter = isViewable, setter = setIsViewable:) BOOL isViewable;

// IMPORTANT: This is the only valid initializer for an MRAIDView; -init and -initWithFrame: will throw exceptions
- (id)initWithFrame:(CGRect)frame
       withHtmlData:(NSString*)htmlData
        withBaseURL:(NSURL*)bsURL
  supportedFeatures:(NSArray *)features
      isInterstital:(BOOL)isInterstitial
           delegate:(id<PNMRAIDViewDelegate>)delegate
   serviceDelegate:(id<PNMRAIDServiceDelegate>)serviceDelegate
 rootViewController:(UIViewController *)rootViewController;

- (void)cancel;

@end
