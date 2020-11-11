/********* FaceTecSDK.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <DigitalIDZoomAuthenticationCordovaPlugin/FaceTecSDK.h>
#import <FaceTecSDK/FaceTecSDK.h>

@implementation FaceTecSDK

- (void)initializeInDevelopmentMode:(CDVInvokedUrlCommand*)command {
    NSString *deviceKeyIdentifier = command.arguments[0];
    NSString *publicEncryptionKey = command.arguments[1];
    
    [[FaceTec sdk] configureLocalizationWithTable:@"FaceTec"
                                        bundle:[NSBundle bundleForClass:[self class]]];
    
    __weak FaceTecSDK *weakSelf = self;
    
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
    
    [[FaceTec sdk] configureLocalizationWithTable:@"FaceTec" bundle:[NSBundle bundleForClass:[self class]]];
    
    __weak FaceTecSDK *weakSelf = self;

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
    FaceTecCustomization *customization = [[FaceTecCustomization alloc] init];
    [[customization overlayCustomization] setShowBrandingImage:NO];
    [[FaceTec sdk] setCustomization:customization];
}

- (void)createSession:(CDVInvokedUrlCommand*)command {
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

- (void)configureLocalization:(CDVInvokedUrlCommand*)command
{
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

@end
