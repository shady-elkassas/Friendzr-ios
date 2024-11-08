//
//  MANativeAd.h
//  AppLovinSDK
//
//  Created by Thomas So on 5/5/20.
//

#import <AppLovinSDK/MAAdFormat.h>

NS_ASSUME_NONNULL_BEGIN

@class MANativeAdBuilder;
@class MANativeAdImage;
@class MANativeAdView;

typedef void (^MANativeAdBuilderBlock) (MANativeAdBuilder *builder);

@interface MANativeAdBuilder : NSObject

@property (nonatomic, copy,   nullable) NSString *title;
@property (nonatomic, copy,   nullable) NSString *advertiser;
@property (nonatomic, copy,   nullable) NSString *body;
@property (nonatomic, copy,   nullable) NSString *callToAction;
@property (nonatomic, strong, nullable) MANativeAdImage *icon;
@property (nonatomic, strong, nullable) MANativeAdImage *mainImage;
@property (nonatomic, strong, nullable) UIView *iconView;
@property (nonatomic, strong, nullable) UIView *optionsView;
@property (nonatomic, strong, nullable) UIView *mediaView;
@property (nonatomic, assign) CGFloat mediaContentAspectRatio;

@end

@interface MANativeAdImage : NSObject

/**
 * The native ad image.
 */
@property (nonatomic, strong, readonly, nullable) UIImage *image;

/**
 * The native ad image URL.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *URL;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * Represents a native ad to be rendered for an instance of a @c MAAd.
 */
@interface MANativeAd : NSObject

/**
 * The native ad format.
 */
@property (nonatomic, weak, readonly) MAAdFormat *format;

/**
 * The native ad title text.
 */
@property (nonatomic, copy, readonly, nullable) NSString *title;

/**
 * The native ad advertiser text.
 */
@property (nonatomic, copy, readonly, nullable) NSString *advertiser;

/**
 * The native ad body text.
 */
@property (nonatomic, copy, readonly, nullable) NSString *body;

/**
 * The native ad CTA button text.
 */
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;

/**
 * The native ad icon image.
 */
@property (nonatomic, strong, readonly, nullable) MANativeAdImage *icon;

/**
 * The native ad icon image view.
 *
 * This is only used for banners using native APIs. Native ads must provide a  `MANativeAdImage` instead.
 */
@property (nonatomic, strong, readonly, nullable) UIView *iconView;

/**
 * The native ad options view.
 */
@property (nonatomic, strong, readonly, nullable) UIView *optionsView;

/**
 * The native ad media view.
 */
@property (nonatomic, strong, readonly, nullable) UIView *mediaView;

/**
 * The native ad main image (cover image). May or may not be a locally cached file:// resource file.
 *
 * Please make sure you continue to render your native ad using @c MANativeAdLoader so impression tracking is not affected.
 *
 * Supported adapter versions:
 *
 * BidMachine  v1.9.4.1.1
 * Google Ad Manager  v9.6.0.1
 * Google AdMob  v9.6.0.2
 * Mintegral  v7.1.7.0.2
 * myTarget  v5.15.2.1
 * Pangle  v4.5.2.4.1
 * Smaato  v21.7.6.1
 * VerizonAds  v2.0.0.4
 */
@property (nonatomic, strong, readonly, nullable) MANativeAdImage *mainImage;

/**
 * The aspect ratio for the media view if provided by the network. Otherwise returns 0.0f.
 */
@property (nonatomic, assign, readonly) CGFloat mediaContentAspectRatio;

/**
 * Whether or not the ad is expired.
 */
@property (nonatomic, assign, readonly, getter=isExpired) BOOL expired;

/**
 * For internal use only.
 */
- (void)performClick;

/**
 * This method is called before the ad view is returned to the publisher.
 * The adapters should override this method to register the rendered native ad view and make sure that the view is interactable.
 *
 * @param nativeAdView a rendered native ad view.
 */
- (void)prepareViewForInteraction:(MANativeAdView *)nativeAdView __deprecated_msg("This method has been deprecated and will be removed in a future SDK version. Please use -[MANativeAd prepareForInteractionClickableViews:withContainer:] instead.");

/**
 * This method is called before the ad view is returned to the publisher.
 * The adapters should override this method to register the rendered native ad view and make sure that the view is interactable.
 *
 * @param clickableViews The clickable views for the native ad.
 * @param container The container for the native ad.
 *
 * @return @c YES if the call has been successfully handled by a subclass of @c MANativeAd.
 */
- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container;

- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
