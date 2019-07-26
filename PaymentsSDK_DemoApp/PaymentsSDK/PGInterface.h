//
//  PGInterface.h
//  PaymentsSDK
//
//  Created by Pradeep Udupi on 27/12/12.
//  Copyright (c) 2012 Robosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandler)(NSDictionary *response, NSError *error, BOOL success);

@interface PGInterface : NSObject

+(void)refundTransaction:(NSDictionary *)txnDict withCompletionHandler:(CompletionHandler)completionHandler;

+(void)transactionStatus:(NSDictionary *)txnDict withCompletionHandler:(CompletionHandler)completionHandler;


@end
