/********* ZoomAuthentication.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <DigitalIDZoomAuthenticationCordovaPlugin/ZoomAuthentication.h>
#import <ZoomAuthentication/ZoomPublicApi.h>

@implementation ZoomAuthentication

- (void)initialize:(CDVInvokedUrlCommand*)command
{
//    ZoomCustomization *zoomCustomization = [[ZoomCustomization alloc] init];

    NSString* licenseKeyIdentifier = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{

        [[Zoom sdk] initialize:licenseKeyIdentifier completion: ^ void (BOOL validationResult) {
            CDVPluginResult* pluginResult;
            if (validationResult) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else {
                NSString* status = [self getSdkStatusString];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)initializeWithLicense:(CDVInvokedUrlCommand*)command
{
    NSString* licenseText = [command.arguments objectAtIndex:0];
    NSString* licenseKeyIdentifier = [command.arguments objectAtIndex:1];

    [self.commandDelegate runInBackground:^{

        [[Zoom sdk] initializeWithLicense:licenseText licenseKeyIdentifier:licenseKeyIdentifier completion: ^ void (BOOL validationResult) {
            CDVPluginResult* pluginResult;
            if (validationResult) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else {
                NSString* status = [self getSdkStatusString];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)createSession:(CDVInvokedUrlCommand*)command
{
    self.command = command;
    UIViewController* vc = [[Zoom sdk] createSessionVCWithDelegate: self faceMapProcessorDelegate: self];
    [self.viewController presentViewController:vc animated:true completion:nil];
}

- (void)onZoomSessionComplete
{
//    ZoomSDKStatus sdkStatus = [[Zoom sdk] getStatus];
}

- (void)processZoomSessionResultWhileZoomWaits:(id<ZoomSessionResult> _Nonnull)zoomSessionResult zoomFaceMapResultCallback:(id<ZoomFaceMapResultCallback> _Nonnull)zoomFaceMapResultCallback
{
    self.zoomFaceMapResultCallback = zoomFaceMapResultCallback;

    NSArray* pluginMessage = @[
        @(zoomSessionResult.status),
        zoomSessionResult.sessionId,
        zoomSessionResult.faceMetrics.faceMapBase64,
        zoomSessionResult.faceMetrics.auditTrailCompressedBase64[0]
    ];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:pluginMessage];
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
//    NSString* table = nil;
//     NSBundle* bundle =
//     [Zoom sdk] configureLocalizationWithTable:table bundle:bundle;
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
