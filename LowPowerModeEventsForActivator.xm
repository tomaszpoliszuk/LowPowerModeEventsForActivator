#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

#include <dispatch/dispatch.h>
#include <objc/runtime.h>

#define LASendEventWithName(eventName) \
	[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

@interface _CDBatterySaver : NSObject
- (long long)getPowerMode;
@end

static long long previous_state = 0;

static NSString *LowPowerModeChanged = @"Low Power Mode changed";
static NSString *LowPowerModeEnabled = @"Low Power Mode enabled";
static NSString *LowPowerModeDisabled = @"Low Power Mode disabled";

@interface LowPowerModeDataSource : NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end

@implementation LowPowerModeDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
+ (void)load {
	[self sharedInstance];
}
- (id)init {
	if (self = [super init]) {
		[LASharedActivator registerEventDataSource:self forEventName:LowPowerModeChanged];
		[LASharedActivator registerEventDataSource:self forEventName:LowPowerModeEnabled];
		[LASharedActivator registerEventDataSource:self forEventName:LowPowerModeDisabled];
	}
	return self;
}
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:LowPowerModeChanged]) {
		return @"Changed";
	} else if ([eventName isEqualToString:LowPowerModeEnabled]) {
		return @"Enabled";
	} else if ([eventName isEqualToString:LowPowerModeDisabled]) {
		return @"Disabled";
	}
	return @" ";
}
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Low Power Mode";
}
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:LowPowerModeChanged]) {
		return @"Triggered when Low Power Mode changed";
	} else if ([eventName isEqualToString:LowPowerModeEnabled]) {
		return @"Triggered when Low Power Mode is enabled";
	} else if ([eventName isEqualToString:LowPowerModeDisabled]) {
		return @"Triggered when Low Power Mode is disabled";
	}
	return @" ";
}
- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:LowPowerModeChanged];
	[LASharedActivator unregisterEventDataSourceWithEventName:LowPowerModeEnabled];
	[LASharedActivator unregisterEventDataSourceWithEventName:LowPowerModeDisabled];
	[super dealloc];
}
@end

%hook _CDBatterySaver
- (long long)getPowerMode {
	long long origValue = %orig;
	if ( previous_state != origValue ) {
		previous_state = origValue;
		LASendEventWithName(LowPowerModeChanged);
		if (origValue == 1) {
			LASendEventWithName(LowPowerModeEnabled);
		} else {
			LASendEventWithName(LowPowerModeDisabled);
		}
	}
	return origValue;
}
%end
