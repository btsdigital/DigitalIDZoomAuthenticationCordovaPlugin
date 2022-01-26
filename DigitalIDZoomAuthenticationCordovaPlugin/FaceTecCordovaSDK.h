
#import <Cordova/CDV.h>
#import <FaceTecSDK/FaceTecSDK.h>

@interface FaceTecCordovaSDK : CDVPlugin <FaceTecSessionResult, FaceTecFaceScanProcessorDelegate>

@property (nonatomic, strong) id<FaceTecFaceScanResultCallback> _Nonnull faceScanResultCallback;
@property (nonatomic, strong) CDVInvokedUrlCommand* _Nonnull pendingCommand;

- (void)initializeInDevelopmentMode:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)initializeInProductionMode:(CDVInvokedUrlCommand *_Nonnull)command;

- (void)createSession:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)onFaceMapResultSucceed:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)onFaceMapResultRetry:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)onFaceMapResultCancel:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)getSdkStatus:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)configureLocalization:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)setLanguageAndZoomHeader:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)setLanguage:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)setLogo:(CDVInvokedUrlCommand *_Nonnull)command;

@end
