/********* FaceTecSDK.m Cordova Plugin Implementation *******/

#import <DigitalIDZoomAuthenticationCordovaPlugin/FaceTecCordovaSDK.h>
#import <FaceTecSDK/FaceTecSDK.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

@implementation FaceTecCordovaSDK

NSString *logoName;

- (void)initializeInDevelopmentMode:(CDVInvokedUrlCommand*)command {
    NSString *deviceKeyIdentifier = command.arguments[0];
    NSString *publicEncryptionKey = command.arguments[1];
       
    __weak FaceTecCordovaSDK *weakSelf = self;
    [[FaceTec sdk] initializeInDevelopmentMode: deviceKeyIdentifier
                         faceScanEncryptionKey: publicEncryptionKey
                                    completion: ^(BOOL validationResult) {
        
        CDVPluginResult* pluginResult;
        if (validationResult) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            NSString* status = [weakSelf getSdkStatusString];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
        }
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        [weakSelf setupCustomization];
    }];
}

- (void)initializeInProductionMode:(CDVInvokedUrlCommand*)command {
    NSString *productionKey = command.arguments[0];
    NSString *deviceKeyIdentifier = command.arguments[1];
    NSString *publicEncryptionKey = command.arguments[2];
        
    __weak FaceTecCordovaSDK *weakSelf = self;
    [self.commandDelegate runInBackground:^{
        [[FaceTec sdk] initializeInProductionMode: productionKey
                              deviceKeyIdentifier: deviceKeyIdentifier
                            faceScanEncryptionKey: publicEncryptionKey
                                       completion:^(BOOL validationResult) {
            
            CDVPluginResult* pluginResult;
            if (validationResult) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                NSString* status = [weakSelf getSdkStatusString];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            [weakSelf setupCustomization];
        }];
    }];
}

- (void)setupCustomization {
    FaceTecCustomization *customization = [self customCustomization];
    FaceTecCustomization *lowLightCustomization = [self customLowLightCustomization];
    FaceTecCustomization *dynamicDimmingCustomization = [self customDynamicDimmingCustomization];
    [[FaceTec sdk] setCustomization:customization];
    [[FaceTec sdk] setLowLightCustomization:lowLightCustomization];
    [[FaceTec sdk] setDynamicDimmingCustomization:dynamicDimmingCustomization];
}

- (void)createSession:(CDVInvokedUrlCommand*)command {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self setupCustomization];
    });
    self.pendingCommand = command;
    NSString *sessionToken = command.arguments[0];
    UIViewController* vc = [[FaceTec sdk] createSessionVCWithFaceScanProcessor:self sessionToken:sessionToken];
    [self.viewController presentViewController:vc animated:true completion:nil];
}

- (void)onFaceTecSDKCompletelyDone {
    
}

- (void)processSessionWhileFaceTecSDKWaits:(id<FaceTecSessionResult> _Nonnull)sessionResult
                    faceScanResultCallback:(id<FaceTecFaceScanResultCallback> _Nonnull)faceScanResultCallback {
    self.faceScanResultCallback = faceScanResultCallback;
    
    CDVPluginResult *pluginResult;
    if (sessionResult.status == FaceTecSessionStatusSessionCompletedSuccessfully) {
        NSArray* pluginMessage = @[
            @(sessionResult.status),
            sessionResult.faceScanBase64,
            sessionResult.auditTrailCompressedBase64
        ];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:pluginMessage];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self faceScanResultCallback] onFaceScanResultCancel];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pendingCommand.callbackId];
}

- (void)onFaceMapResultSucceed:(CDVInvokedUrlCommand*)command {
    [[self faceScanResultCallback] onFaceScanResultSucceed];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onFaceMapResultRetry:(CDVInvokedUrlCommand*)command {
    [[self faceScanResultCallback] onFaceScanResultRetry];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onFaceMapResultCancel:(CDVInvokedUrlCommand*)command {
    [[self faceScanResultCallback] onFaceScanResultCancel];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getSdkStatus:(CDVInvokedUrlCommand*)command {
    int sdkStatusValue = (int)[[FaceTec sdk] getStatus];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt: sdkStatusValue];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureLocalization:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setLanguageAndZoomHeader:(CDVInvokedUrlCommand*)command {
    NSString *currentLanguage = command.arguments[0];
    NSString *userName = command.arguments[1];
    [[FaceTec sdk] setLanguage:currentLanguage];
    [self setZoomHeader:currentLanguage userName:userName];
}

- (void)setLanguage:(CDVInvokedUrlCommand*)command {
    NSString *currentLanguage = command.arguments[0];
    [[FaceTec sdk] setLanguage:currentLanguage];
}

- (void)setLogo:(CDVInvokedUrlCommand*)command {
    NSString *productName = command.arguments[0];
    logoName = [productName stringByAppendingString:@"-logo"];
}

- (NSString*)getSdkStatusString {
    switch ([[FaceTec sdk] getStatus]) {
        case FaceTecSDKStatusNeverInitialized:
            return @"NeverInitialized";
        case FaceTecSDKStatusInitialized:
            return @"Initialized";
        case FaceTecSDKStatusNetworkIssues:
            return @"NetworkIssues";
        case FaceTecSDKStatusInvalidDeviceKeyIdentifier:
            return @"InvalidDeviceLicenseKeyIdentifier";
        case FaceTecSDKStatusVersionDeprecated:
            return @"StatusVersionDeprecated";
        case FaceTecSDKStatusOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
        case FaceTecSDKStatusUnknownError:
            return @"UnknownError";
        case FaceTecSDKStatusDeviceLockedOut:
            return @"DeviceLockedOut";
        case FaceTecSDKStatusDeviceInLandscapeMode:
            return @"DeviceInLandscapeMode";
        case FaceTecSDKStatusDeviceInReversePortraitMode:
            return @"DeviceInReversePortraitMode";
        case FaceTecSDKStatusKeyExpiredOrInvalid:
            return @"LicenseExpiredOrInvalid";
        case FaceTecSDKStatusEncryptionKeyInvalid:
            return @"EncryptionKeyInvalid";
    }
    return nil;
}

- (void)setZoomHeader:(NSString*)language userName:(NSString*)userName {
    NSString *welcome = @"С возвращением, ";
    if (language != nil) {
        if ([language isEqualToString:@"kk"]) {
            welcome = @"Қайта оралуыңызбен, ";
        } else if ([language isEqualToString:@"en"]) {
            welcome = @"Welcome back, ";
        }
    }
    
    [[FaceTec sdk] configureLocalizationWithTable:@"FaceTec" bundle:[NSBundle bundleForClass:[self class]]];
    
    if (userName != nil && ![userName isEqualToString:@""]) {
        NSString *welcomeBack = [welcome stringByAppendingString:userName];
        NSDictionary *userNameDictionary = @{ @"FaceTec_instructions_header_ready_1": welcomeBack };
        [[FaceTec sdk] setDynamicStrings:userNameDictionary];
    }
}

- (FaceTecCustomization *)customCustomization {
    
    // For Color Customization
    UIColor *frameColor = UIColorFromRGB(0xffffff);
    UIColor *borderColor = UIColorFromRGB(0xffffff);
    UIColor *buttonAndFeedbackBarTextColor = UIColorFromRGB(0xffffff);
    UIColor *buttonColorPressed = UIColorFromRGB(0x0067cf);
    UIColor *lightModePrimaryDark = UIColorFromRGB(0x292D3C);
    UIColor *lightModePrimaryBlue = UIColorFromRGB(0x4E77FB);

    CAGradientLayer *feedbackBackgroundLayer = [[CAGradientLayer alloc] init];
    feedbackBackgroundLayer.colors = @[lightModePrimaryBlue, lightModePrimaryBlue];
    feedbackBackgroundLayer.locations = @[@0, @1];
    feedbackBackgroundLayer.startPoint = CGPointMake(0, 0);
    feedbackBackgroundLayer.endPoint = CGPointMake(1, 0);
    
    // For Frame Corner Radius Customization
    int32_t frameCornerRadius = 20;

    FaceTecCancelButtonLocation cancelButtonLocation = FaceTecCancelButtonLocationTopLeft;

    // For image Customization
    FaceTecSecurityWatermarkImage securityWatermarkImage = FaceTecSecurityWatermarkImageFaceTecZoom;
    
    // Set a default customization
    FaceTecCustomization *defaultCustomization = [FaceTecCustomization new];

    // Set Frame Customization
    defaultCustomization.frameCustomization.cornerRadius = frameCornerRadius;
    defaultCustomization.frameCustomization.backgroundColor = frameColor;
    defaultCustomization.frameCustomization.borderColor = borderColor;

    // Set Overlay Customization
    
    UIImage *brandingImage = [UIImage imageNamed:logoName
                                        inBundle:[NSBundle bundleForClass:[self class]]
                   compatibleWithTraitCollection:nil];
    defaultCustomization.overlayCustomization.brandingImage = brandingImage;
    defaultCustomization.overlayCustomization.showBrandingImage = YES;
    defaultCustomization.overlayCustomization.backgroundColor = [UIColor whiteColor];

    // Set Guidance Customization
    UIImage *retryIdealImage = [UIImage imageNamed:@"retry-image-ideal"
                                        inBundle:[NSBundle bundleForClass:[self class]]
                   compatibleWithTraitCollection:nil];
    defaultCustomization.guidanceCustomization.retryScreenIdealImage = retryIdealImage;
    defaultCustomization.guidanceCustomization.backgroundColors = @[frameColor, frameColor];
    defaultCustomization.guidanceCustomization.foregroundColor = lightModePrimaryDark;
    defaultCustomization.guidanceCustomization.buttonBackgroundNormalColor = lightModePrimaryBlue;
    defaultCustomization.guidanceCustomization.buttonBackgroundDisabledColor = buttonColorPressed;
    defaultCustomization.guidanceCustomization.buttonBackgroundHighlightColor = buttonColorPressed;
    defaultCustomization.guidanceCustomization.buttonTextNormalColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.guidanceCustomization.buttonTextDisabledColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.guidanceCustomization.buttonTextHighlightColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.guidanceCustomization.retryScreenImageBorderColor = borderColor;
    defaultCustomization.guidanceCustomization.retryScreenOvalStrokeColor = borderColor;
    defaultCustomization.guidanceCustomization.retryScreenHeaderTextColor = lightModePrimaryDark;
    defaultCustomization.guidanceCustomization.retryScreenSubtextTextColor = lightModePrimaryDark;
    defaultCustomization.guidanceCustomization.readyScreenHeaderTextColor = lightModePrimaryDark;
    defaultCustomization.guidanceCustomization.readyScreenSubtextTextColor = lightModePrimaryDark;

    // Set vocal guidance customization

    defaultCustomization.vocalGuidanceCustomization.mode = FaceTecVocalGuidanceModeNoVocalGuidance;

    // Set Oval Customization
    defaultCustomization.ovalCustomization.strokeColor = lightModePrimaryBlue;
    defaultCustomization.ovalCustomization.progressColor1 = lightModePrimaryBlue;
    defaultCustomization.ovalCustomization.progressColor2 = lightModePrimaryBlue;

    // Set Feedback Customization
    defaultCustomization.feedbackCustomization.backgroundColor = feedbackBackgroundLayer;
    defaultCustomization.feedbackCustomization.textColor = buttonAndFeedbackBarTextColor;

    // Set Cancel Customization
//    defaultCustomization.cancelButtonCustomization.customImage = cancelImage;
    defaultCustomization.cancelButtonCustomization.location = cancelButtonLocation;

    // Set Result Screen Customization
    defaultCustomization.resultScreenCustomization.backgroundColors = @[frameColor, frameColor];
    defaultCustomization.resultScreenCustomization.foregroundColor = lightModePrimaryDark;
    defaultCustomization.resultScreenCustomization.activityIndicatorColor = lightModePrimaryBlue;
    defaultCustomization.resultScreenCustomization.resultAnimationBackgroundColor = lightModePrimaryBlue;
    defaultCustomization.resultScreenCustomization.resultAnimationForegroundColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.resultScreenCustomization.uploadProgressFillColor = lightModePrimaryBlue;
    
    // Set Security Watermark Customization
    defaultCustomization.securityWatermarkImage = securityWatermarkImage;

    return defaultCustomization;
}

- (FaceTecCustomization *)customLowLightCustomization {
    
    UIColor *lightModePrimaryDark = UIColorFromRGB(0x292D3C);
    
    FaceTecCustomization *baseCustomization = [self customCustomization];
    
    baseCustomization.guidanceCustomization.foregroundColor = lightModePrimaryDark;
    baseCustomization.feedbackCustomization.textColor = lightModePrimaryDark;
    baseCustomization.resultScreenCustomization.foregroundColor = lightModePrimaryDark;
    baseCustomization.resultScreenCustomization.activityIndicatorColor = lightModePrimaryDark;
    baseCustomization.resultScreenCustomization.uploadProgressTrackColor = lightModePrimaryDark;
    baseCustomization.resultScreenCustomization.uploadProgressFillColor = lightModePrimaryDark;
    baseCustomization.resultScreenCustomization.resultAnimationBackgroundColor = lightModePrimaryDark;
    
    return baseCustomization;
}

- (FaceTecCustomization *)customDynamicDimmingCustomization {
    
    UIColor *darkModePrimaryDark = UIColorFromRGB(0xF9F9F9);
    UIColor *darkModePrimaryBlue = UIColorFromRGB(0x94ADFC);
    
    CAGradientLayer *feedbackBackgroundLayer = [[CAGradientLayer alloc] init];
    feedbackBackgroundLayer.colors = @[darkModePrimaryBlue, darkModePrimaryBlue];
    feedbackBackgroundLayer.locations = @[@0, @1];
    feedbackBackgroundLayer.startPoint = CGPointMake(0, 0);
    feedbackBackgroundLayer.endPoint = CGPointMake(1, 0);
    
    FaceTecCustomization *baseCustomization = [self customCustomization];
    
    baseCustomization.guidanceCustomization.foregroundColor = darkModePrimaryDark;
    baseCustomization.guidanceCustomization.buttonBackgroundNormalColor = darkModePrimaryBlue;
    baseCustomization.guidanceCustomization.buttonBackgroundHighlightColor = darkModePrimaryBlue;
    baseCustomization.guidanceCustomization.readyScreenHeaderTextColor = darkModePrimaryDark;
    baseCustomization.guidanceCustomization.readyScreenSubtextTextColor = darkModePrimaryDark;
    baseCustomization.guidanceCustomization.retryScreenHeaderTextColor = darkModePrimaryDark;
    baseCustomization.guidanceCustomization.retryScreenSubtextTextColor = darkModePrimaryDark;
    baseCustomization.feedbackCustomization.backgroundColor = feedbackBackgroundLayer;
    baseCustomization.feedbackCustomization.textColor = darkModePrimaryDark;
    baseCustomization.ovalCustomization.strokeColor = darkModePrimaryBlue;
    baseCustomization.ovalCustomization.progressColor1 = darkModePrimaryBlue;
    baseCustomization.ovalCustomization.progressColor2 = darkModePrimaryBlue;
    baseCustomization.resultScreenCustomization.foregroundColor = darkModePrimaryDark;
    baseCustomization.resultScreenCustomization.activityIndicatorColor = darkModePrimaryDark;
    baseCustomization.resultScreenCustomization.uploadProgressTrackColor = darkModePrimaryDark;
    baseCustomization.resultScreenCustomization.uploadProgressFillColor = darkModePrimaryDark;
    baseCustomization.resultScreenCustomization.resultAnimationBackgroundColor = darkModePrimaryDark;
    baseCustomization.resultScreenCustomization.foregroundColor = darkModePrimaryDark;
    
    return baseCustomization;
}

@synthesize auditTrailCompressedBase64;

@synthesize faceScan;

@synthesize faceScanBase64;

@synthesize lowQualityAuditTrailCompressedBase64;

@synthesize sessionId;

@synthesize status;

@end
