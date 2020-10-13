/********* ZoomAuthentication.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <ZoomAuthentication/ZoomAuthentication.h>

@interface ZoomAuthentication : CDVPlugin <ZoomSessionDelegate, ZoomFaceMapProcessorDelegate> {
    CDVInvokedUrlCommand* pendingCommand;
}

@property (nonatomic, strong) id<ZoomFaceMapResultCallback> _Nonnull zoomFaceMapResultCallback;
@property (nonatomic, strong) CDVInvokedUrlCommand* _Nonnull command;

- (void)initialize:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)initializeWithLicense:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)createSession:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)onFaceMapResultSucceed:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)onFaceMapResultRetry:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)onFaceMapResultCancel:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)getSdkStatus:(CDVInvokedUrlCommand *_Nonnull)command;
- (void)configureLocalization:(CDVInvokedUrlCommand *_Nonnull)command;

@end
