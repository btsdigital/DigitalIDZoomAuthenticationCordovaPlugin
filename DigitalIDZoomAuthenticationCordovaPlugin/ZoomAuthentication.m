/********* ZoomAuthentication.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <DigitalIDZoomAuthenticationCordovaPlugin/ZoomAuthentication.h>
#import <ZoomAuthentication/ZoomPublicApi.h>

@implementation ZoomAuthentication

- (void)initialize:(CDVInvokedUrlCommand*)command {
    NSString* licenseKeyIdentifier = [command.arguments objectAtIndex:0];

    [[Zoom sdk] configureLocalizationWithTable:@"Zoom"
                                        bundle:[NSBundle bundleForClass:[self class]]];
    
    __weak ZoomAuthentication *weakSelf = self;
    [self.commandDelegate runInBackground:^{
        
        [[Zoom sdk] initialize:licenseKeyIdentifier completion: ^ void (BOOL validationResult) {
            CDVPluginResult* pluginResult;
            if (validationResult) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                NSString *status = [weakSelf getSdkStatusString];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
        [weakSelf setupCustomization];
    }];
}

- (void)initializeWithLicense:(CDVInvokedUrlCommand*)command {
    NSString* licenseText = [command.arguments objectAtIndex:0];
    NSString* licenseKeyIdentifier = [command.arguments objectAtIndex:1];

    [[Zoom sdk] configureLocalizationWithTable:@"Zoom"
                                        bundle:[NSBundle bundleForClass:[self class]]];
    
    __weak ZoomAuthentication *weakSelf = self;
    [self.commandDelegate runInBackground:^{
        [[Zoom sdk] initializeWithLicense:licenseText licenseKeyIdentifier:licenseKeyIdentifier completion: ^ void (BOOL validationResult) {
            CDVPluginResult* pluginResult;
            if (validationResult) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                NSString* status = [weakSelf getSdkStatusString];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
        [weakSelf setupCustomization];
    }];
}

- (void)setupCustomization {
    ZoomCustomization *customization = [[ZoomCustomization alloc] init];
    [[customization overlayCustomization] setShowBrandingImage:NO];
    [[Zoom sdk] setCustomization:customization];
}

- (void)createSession:(CDVInvokedUrlCommand*)command {
    self.command = command;
    UIViewController* vc = [[Zoom sdk] createSessionVCWithDelegate: self faceMapProcessorDelegate: self];
    [self.viewController presentViewController:vc animated:true completion:nil];
}

- (void)onZoomSessionComplete
{
//    ZoomSDKStatus sdkStatus = [[Zoom sdk] getStatus];
}

- (void)processZoomSessionResultWhileZoomWaits:(id<ZoomSessionResult> _Nonnull)zoomSessionResult
                     zoomFaceMapResultCallback:(id<ZoomFaceMapResultCallback> _Nonnull)zoomFaceMapResultCallback
{
    self.zoomFaceMapResultCallback = zoomFaceMapResultCallback;
    
    CDVPluginResult *pluginResult;
    if (zoomSessionResult.status == ZoomSessionStatusSessionCompletedSuccessfully) {
        NSArray* pluginMessage = @[
            @(zoomSessionResult.status),
            zoomSessionResult.sessionId,
            zoomSessionResult.faceMetrics.faceMapBase64,
            zoomSessionResult.faceMetrics.auditTrailCompressedBase64[0]
        ];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:pluginMessage];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [[self zoomFaceMapResultCallback] onFaceMapResultCancel];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

- (void)onFaceMapResultSucceed:(CDVInvokedUrlCommand*)command
{
    [[self zoomFaceMapResultCallback] onFaceMapResultSucceed];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onFaceMapResultRetry:(CDVInvokedUrlCommand*)command
{
    [[self zoomFaceMapResultCallback] onFaceMapResultRetry];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onFaceMapResultCancel:(CDVInvokedUrlCommand*)command
{
    [[self zoomFaceMapResultCallback] onFaceMapResultCancel];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getSdkStatus:(CDVInvokedUrlCommand*)command
{
    ZoomSDKStatus sdkStatus = [[Zoom sdk] getStatus];
    long sdkStatusValue = (int)sdkStatus;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt: sdkStatusValue];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureLocalization:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString*)getSdkStatusString {
    switch ([[Zoom sdk] getStatus]) {
        case ZoomSDKStatusNeverInitialized:
            return @"NeverInitialized";
        case ZoomSDKStatusInitialized:
            return @"Initialized";
        case ZoomSDKStatusNetworkIssues:
            return @"NetworkIssues";
        case ZoomSDKStatusInvalidDeviceLicenseKeyIdentifier:
            return @"InvalidDeviceLicenseKeyIdentifier";
        case ZoomSDKStatusVersionDeprecated:
            return @"StatusVersionDeprecated";
        case ZoomSDKStatusOfflineSessionsExceeded:
            return @"OfflineSessionsExceeded";
        case ZoomSDKStatusUnknownError:
            return @"UnknownError";
        case ZoomSDKStatusDeviceLockedOut:
            return @"DeviceLockedOut";
        case ZoomSDKStatusDeviceInLandscapeMode:
            return @"DeviceInLandscapeMode";
        case ZoomSDKStatusDeviceInReversePortraitMode:
            return @"DeviceInReversePortraitMode";
        case ZoomSDKStatusLicenseExpiredOrInvalid:
            return @"LicenseExpiredOrInvalid";
        case ZoomSDKStatusEncryptionKeyInvalid:
            return @"EncryptionKeyInvalid";
            break;
    }
    return nil;
}

@end
