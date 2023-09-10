#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "RealmPlugin.h"
#import "realm_plugin.h"

FOUNDATION_EXPORT double realmVersionNumber;
FOUNDATION_EXPORT const unsigned char realmVersionString[];

