/********* FaceTecSDK.m Cordova Plugin Implementation *******/

#import <DigitalIDZoomAuthenticationCordovaPlugin/FaceTecCordovaSDK.h>
#import <FaceTecSDK/FaceTecSDK.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

@implementation FaceTecCordovaSDK

- (void)initializeInDevelopmentMode:(CDVInvokedUrlCommand*)command {
    NSString *deviceKeyIdentifier = command.arguments[0];
    NSString *publicEncryptionKey = command.arguments[1];
   
    [self setupLocalization];
    
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
    
    [self setupLocalization];
    
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
    [[FaceTec sdk] setCustomization:customization];
}

- (void)createSession:(CDVInvokedUrlCommand*)command {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self setupLocalization];
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
            sessionResult.auditTrailCompressedBase64[0]
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

- (void)setupLocalization {
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"did-language"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"did-userName"];
    NSString *welcome = @"С возвращением, ";
    if (language != nil) {
        [[FaceTec sdk] setLanguage:language];
        if ([language isEqualToString:@"kk"]) {
            welcome = @"Қайта оралуыңызбен, ";
        } else if ([language isEqualToString:@"en"]) {
            welcome = @"Welcome back, ";
        }
    }
    
    [[FaceTec sdk] configureLocalizationWithTable:@"FaceTec" bundle:[NSBundle bundleForClass:[self class]]];
    
    if (userName != nil) {
        NSString *welcomeBack = [welcome stringByAppendingString:userName];
        NSDictionary *userNameDictionary = @{ @"FaceTec_instructions_header_ready_1": welcomeBack };
        [[FaceTec sdk] setDynamicStrings:userNameDictionary];
    }
}

- (FaceTecCustomization *)customCustomization {
    
    // For Color Customization
    UIColor *frameColor = UIColorFromRGB(0xffffff);
    UIColor *borderColor = UIColorFromRGB(0xffffff);
    UIColor *ovalColor = UIColorFromRGB(0x0075eb);
    UIColor *dualSpinnerColor = UIColorFromRGB(0x0075eb);
    UIColor *textColor = UIColorFromRGB(0x29323c);
    UIColor *buttonAndFeedbackBarColor =  UIColorFromRGB(0x0075eb);
    UIColor *buttonAndFeedbackBarTextColor = UIColorFromRGB(0xffffff);
    UIColor *buttonColorPressed = UIColorFromRGB(0x0067cf);

    CAGradientLayer *feedbackBackgroundLayer = [[CAGradientLayer alloc] init];
    feedbackBackgroundLayer.colors = @[buttonAndFeedbackBarColor, buttonAndFeedbackBarColor];
    feedbackBackgroundLayer.locations = @[@0, @1];
    feedbackBackgroundLayer.startPoint = CGPointMake(0, 0);
    feedbackBackgroundLayer.endPoint = CGPointMake(1, 0);
    
    // For Frame Corner Radius Customization
    int32_t frameCornerRadius = 20;

//    UIImage *cancelImage = [UIImage imageNamed:@"FaceTec_cancel"];
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
    
    UIImage *brandingImage = [UIImage imageNamed:@"did-logo"
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
    defaultCustomization.guidanceCustomization.foregroundColor = textColor;
    defaultCustomization.guidanceCustomization.buttonBackgroundNormalColor = buttonAndFeedbackBarColor;
    defaultCustomization.guidanceCustomization.buttonBackgroundDisabledColor = buttonColorPressed;
    defaultCustomization.guidanceCustomization.buttonBackgroundHighlightColor = buttonColorPressed;
    defaultCustomization.guidanceCustomization.buttonTextNormalColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.guidanceCustomization.buttonTextDisabledColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.guidanceCustomization.buttonTextHighlightColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.guidanceCustomization.retryScreenImageBorderColor = borderColor;
    defaultCustomization.guidanceCustomization.retryScreenOvalStrokeColor = borderColor;
    
    // Set vocal guidance customization
    
    defaultCustomization.vocalGuidanceCustomization.mode = FaceTecVocalGuidanceModeNoVocalGuidance;

    // Set Oval Customization
    defaultCustomization.ovalCustomization.strokeColor = ovalColor;
    defaultCustomization.ovalCustomization.progressColor1 = dualSpinnerColor;
    defaultCustomization.ovalCustomization.progressColor2 = dualSpinnerColor;

    // Set Feedback Customization
    defaultCustomization.feedbackCustomization.backgroundColor = feedbackBackgroundLayer;
    defaultCustomization.feedbackCustomization.textColor = buttonAndFeedbackBarTextColor;

    // Set Cancel Customization
//    defaultCustomization.cancelButtonCustomization.customImage = cancelImage;
    defaultCustomization.cancelButtonCustomization.location = cancelButtonLocation;

    // Set Result Screen Customization
    defaultCustomization.resultScreenCustomization.backgroundColors = @[frameColor, frameColor];
    defaultCustomization.resultScreenCustomization.foregroundColor = textColor;
    defaultCustomization.resultScreenCustomization.activityIndicatorColor = buttonAndFeedbackBarColor;
    defaultCustomization.resultScreenCustomization.resultAnimationBackgroundColor = buttonAndFeedbackBarColor;
    defaultCustomization.resultScreenCustomization.resultAnimationForegroundColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.resultScreenCustomization.uploadProgressFillColor = buttonAndFeedbackBarColor;
    
    // Set Security Watermark Customization
    defaultCustomization.securityWatermarkImage = securityWatermarkImage;

    // Set ID Scan Customization
    defaultCustomization.idScanCustomization.selectionScreenBackgroundColors = @[frameColor, frameColor];
    defaultCustomization.idScanCustomization.selectionScreenForegroundColor = textColor;
    defaultCustomization.idScanCustomization.reviewScreenBackgroundColors = @[frameColor, frameColor];
    defaultCustomization.idScanCustomization.reviewScreenForegroundColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.idScanCustomization.reviewScreenTextBackgroundColor = buttonAndFeedbackBarColor;
    defaultCustomization.idScanCustomization.captureScreenForegroundColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.idScanCustomization.captureScreenTextBackgroundColor = buttonAndFeedbackBarColor;
    defaultCustomization.idScanCustomization.buttonBackgroundNormalColor = buttonAndFeedbackBarColor;
    defaultCustomization.idScanCustomization.buttonBackgroundDisabledColor = buttonColorPressed;
    defaultCustomization.idScanCustomization.buttonBackgroundHighlightColor = buttonColorPressed;
    defaultCustomization.idScanCustomization.buttonTextNormalColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.idScanCustomization.buttonTextDisabledColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.idScanCustomization.buttonTextHighlightColor = buttonAndFeedbackBarTextColor;
    defaultCustomization.idScanCustomization.captureScreenBackgroundColor = frameColor;
    defaultCustomization.idScanCustomization.captureFrameStrokeColor = borderColor;

    return defaultCustomization;
}

@end
