//
//  History.m
//  CocoaCEDICT
//
//  Created by Mark on 5/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "History.h"

@implementation History

- (id) init 
{
	self = [super init];
	if (self != nil) {
		maxItemsLimit = HISTORY_DEFAULT_MAX_ITEMS;
		historyArray = [[NSMutableArray alloc] initWithCapacity:HISTORY_DEFAULT_MAX_ITEMS];
		currentItemIndex = -1;
	}
	return self;
}
- (void) dealloc
{
	[historyArray release];
	[super dealloc];
}


- (BOOL) canGoBack
{
	if ([self indexOfCurrentItem] > 0) {
		return YES;
	}
	return NO;
}
- (BOOL) canGoForward
{
	if ([self indexOfCurrentItem] < [historyArray count] - 1) {
		return YES;
	}
	return NO;
}

- (id) currentItem
{
	if ([self indexOfCurrentItem] != -1) {
		return [historyArray objectAtIndex:[self indexOfCurrentItem]];
	}
	return nil;
}

- (id) nextItem
{
	if ([self canGoForward]) {
		return [historyArray objectAtIndex:[self indexOfCurrentItem] + 1];
	}
	return nil;
}
- (id) previousItem
{
	if ([self canGoBack]) {
		return [historyArray objectAtIndex:[self indexOfCurrentItem] - 1];
	}
	return nil;
}

- (int) indexOfCurrentItem
{
	return currentItemIndex;
}

- (void) goForwardWithItem:(id)item
{
	if ([self canGoForward]) {
		int removeStart = [self indexOfCurrentItem] + 1;
		int removeLength = [historyArray count] - removeStart;
		[historyArray removeObjectsInRange:NSMakeRange(removeStart,removeLength)];
	}
	[self pushHistoryItem:item];
	currentItemIndex = [historyArray count] - 1;
}

- (id) goForward
{
	if ([self canGoForward]) {
		currentItemIndex += 1;
		return [self currentItem];
	}
	return nil;
}
- (id) goBack
{
	if ([self canGoBack]) {
		currentItemIndex -= 1;
		return [self currentItem];
	}
	return nil;
}
- (id) goToIndex:(int)newIndex
{
	if ([self canGoToIndex:newIndex]) {
		currentItemIndex = newIndex;
		return [self currentItem];
	}
	return nil;
}
- (BOOL) canGoToIndex:(int)newIndex
{
	if ([historyArray count] > 0 && newIndex >= 0 && newIndex < [historyArray count]) {
		return YES;
	}
	return NO;
}

- (void) setMaxItems:(int)newMaxItems
{
	if (newMaxItems > 0) {
		maxItemsLimit = newMaxItems;
	}
}
- (int) maxItems
{
	return maxItemsLimit;
}

- (NSArray *) allItems
{
	return [NSArray arrayWithArray:historyArray];
}

- (void) unshiftHistoryItem:(id)item
{
	[historyArray insertObject:item atIndex:0];
	if ([historyArray count] > [self maxItems]) {
		[historyArray removeLastObject];
	}
}
- (id) shiftHistoryItem
{
	id rv = nil;
	if ([historyArray count]) {
		rv = [historyArray objectAtIndex:0];
		[historyArray removeObjectAtIndex:0];
	}
	return rv;
}

- (void) pushHistoryItem:(id)item
{
	[historyArray addObject:item];
	if ([historyArray count] > [self maxItems]) {
		[historyArray removeObjectAtIndex:0];
	}
}
- (id) popHistoryItem
{
	id rv = nil;
	if ([historyArray count]) {
		rv = [historyArray lastObject];
		[historyArray removeLastObject];
	}
	return rv;
}

@end
