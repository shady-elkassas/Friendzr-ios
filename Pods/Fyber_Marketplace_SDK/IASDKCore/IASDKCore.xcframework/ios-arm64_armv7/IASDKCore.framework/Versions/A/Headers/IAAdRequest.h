//
//  IAAdRequest.h
//  IASDKCore
//
//  Created by Fyber on 13/03/2017.
//  Copyright © 2017 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IASDKCore/IAInterfaceBuilder.h>
#import <IASDKCore/IARequest.h>
#import <IASDKCore/IAInterfaceAdDescription.h>

@class IAUserData;
@class CLLocation;
@class IADebugger;
@class IAMediation;

@protocol IAAdRequestBuilder <NSObject>

@required

@property (nonatomic) BOOL useSecureConnections;

/**
 *  @brief A mandatory parameter.
 */
@property (nonatomic, copy, nonnull) NSString *spotID;

/**
 *  @brief The request timeout in seconds before the 'ready on client' will be received.
 *
 *  @discussion The min value is 1, the max value is 180, the default is 10. In case the input param is out of bounds, the default one will be set.
 */
@property (nonatomic) NSTimeInterval timeout;

@property (nonatomic, copy, nullable) IAUserData *userData DEPRECATED_MSG_ATTRIBUTE("In current version setting this property will not affect anything. In the next SDK version this property will be removed. Please use 'userData' property of IASDKCore instance instead.");

/**
 *  @brief Single keyword string or several keywords, separated by comma.
 */
@property (nonatomic, copy, nullable) NSString *keywords DEPRECATED_MSG_ATTRIBUTE("In current version setting this property will not affect anything. In the next SDK version this property will be removed. Please use 'keywords' property of IASDKCore instead.");

/**
 *  @brief Current location. Use for better ad targeting.
 */
@property (nonatomic, copy, nullable) CLLocation *location DEPRECATED_MSG_ATTRIBUTE("In current version setting this property will will not affect anything. In the next SDK version this property will be removed. Please use 'location' property of IASDKCore instance.");

@property (nonatomic, copy, nullable) IADebugger *debugger;

/**
 *  @brief Subtype expected configuration. In case a certain type of ad has extra configuration, assign it here.
 */
@property (nonatomic, copy, nullable) id<IAInterfaceAdDescription> subtypeDescription;

@optional

/**
 *  @brief In case is enabled and the responded creative supports this feature, the creative will start interacting without sound.
 */
@property (nonatomic) BOOL muteAudio DEPRECATED_MSG_ATTRIBUTE("In current version setting this property will not affect anything. In the next SDK version this property will be removed. Please use 'muteAudio' property of IASDKCore instance instead.");

@end

@interface IAAdRequest : IARequest <IAInterfaceBuilder, IAAdRequestBuilder, NSCopying>

/**
 *  @brief Use in order to determine type of unit returned.
 *  @discussion Will be assigned at response parsing phase.
 */
@property (nonatomic, strong, nullable, readonly) NSString *unitID;

+ (instancetype _Nullable)build:(void(^ _Nonnull)(id<IAAdRequestBuilder> _Nonnull builder))buildBlock;

@end
