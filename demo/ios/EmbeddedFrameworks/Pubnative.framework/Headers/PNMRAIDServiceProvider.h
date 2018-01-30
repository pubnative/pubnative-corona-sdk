//
//  PNMRAIDServiceProvider.h
//  sdk.framework
//
//  Created by Can Soykarafakili on 04.12.17.
//  Copyright © 2017 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNMRAIDServiceProvider : NSObject

- (void)openBrowser:(NSString *)urlString;
- (void)playVideo:(NSString *)urlString;
- (void)storePicture:(NSString *)urlString;
- (void)createEvent:(NSString *)eventJSON;
- (void)sendSMS:(NSString *)urlString;
- (void)callNumber:(NSString *)urlString;

@end
