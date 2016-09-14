/*
 接收异常类 
 在出现异常时 可自定义操作
 配合LOG类使用 出现异常自动保存；
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject{
	BOOL dismissed;
}

@end
void HandleException(NSException *exception);  // 异常截获处理方法
void SignalHandler(int signal);  // 系统信号截获处理方法


void InstallUncaughtExceptionHandler(void);  // 注册崩溃拦截