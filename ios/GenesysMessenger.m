//
//  GenesysMessenger.m
//  InAppChat
//
//  Created by HoangDoan on 15/11/2022.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "GenesysCloudModule.h"
#import <GenesysCloud/GenesysCloud.h>
#import <GenesysCloud/ChatHandler.h>
#import <GenesysCloud/BaseChatHandler.h>




@interface RCT_EXTERN_MODULE(GenesysMessenger, NSObject)
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}
RCT_EXTERN_METHOD(setupGenesis)
RCT_EXTERN_METHOD(uploadAttachment:(NSData)data withFileName:NSString()filename )
RCT_EXTERN_METHOD(sendMessage:(NSString)message)

@end

