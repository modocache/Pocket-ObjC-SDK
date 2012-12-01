//
//  PocketAPIActivity.m
//  ThinkSocial
//
//  Created by David Beck on 12/1/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "PocketAPIActivity.h"

#import "PocketAPI.h"


@implementation PocketAPIActivity
{
	NSArray *_URLs;
}

- (NSString *)activityType
{
	return @"Pocket";
}

- (NSString *)activityTitle
{
	return NSLocalizedString(@"Send to Pocket", nil);
}

- (UIImage *)activityImage
{
	return [UIImage imageNamed:@"PocketActivity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			NSURL *pocketURL = [NSURL URLWithString:[[PocketAPI pocketAppURLScheme] stringByAppendingString:@":test"]];
			
			if ([[UIApplication sharedApplication] canOpenURL:pocketURL] || [PocketAPI sharedAPI].loggedIn) {
				return YES;
			}
		}
	}
	
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	NSMutableArray *URLs = [NSMutableArray array];
	
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			[URLs addObject:activityItem];
		}
	}
	
	[_URLs release];
	_URLs = [URLs copy];
}

- (void)performActivity
{
	__block NSUInteger URLsLeft = _URLs.count;
	__block BOOL URLFailed = NO;
	
	for (NSURL *URL in _URLs) {
		[[PocketAPI sharedAPI] saveURL:URL handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
			if (error != nil) {
				URLFailed = YES;
			}
			
			URLsLeft--;
			
			if (URLsLeft == 0) {
				[self activityDidFinish:!URLFailed];
			}
		}];
	}
}

- (void)dealloc
{
	[_URLs release];
	
	[super dealloc];
}

@end
