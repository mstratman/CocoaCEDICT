//
//  History.h
//  CocoaCEDICT
//
//  Created by Mark on 5/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define HISTORY_DEFAULT_MAX_ITEMS 15

/*!
    @class History
    @abstract    Maintain a history of arbitrary objects
    @discussion  This class allows you to maintain a history of objects.
*/
@interface History : NSObject 
{
	NSMutableArray *historyArray;
	int currentItemIndex;
	int maxItemsLimit;
}

/*!
    @method     setMaxItems:
    @abstract
    @discussion Set the capacity for the history.
	@param newMaxItems The maximum number of items this history can hold.
*/
- (void) setMaxItems:(int)newMaxItems;

/*!
    @method     maxItems
    @abstract
    @discussion The maximum number of items this history can hold.
	@result The maximum number of items.
*/
- (int) maxItems;

/*!
    @method     allItems
    @abstract
    @discussion All of the items in the history.
	@result Returns an array of all items in history.
*/
- (NSArray *) allItems;

/*!
    @method canGoBack
    @abstract
	@discussion Check if the current item is at the start of the history.
    @result Returns YES if you can goBack, NO otherwise.
*/
- (BOOL) canGoBack;

/*!
	@method canGoForward
	@abstract
	@discussion Check if the current item is at the end of the history.
	@result Returns YES if you can goForward, NO otherwise.
*/
- (BOOL) canGoForward;

/*!
    @method     currentItem
    @abstract
	@discussion Get the current item.
    @result Returns the item at the current place in the history, or nil if there is nothing in the history.
*/
- (id) currentItem;

/*!
    @method     nextItem
    @abstract
	@discussion Get the next item.
    @result Returns the next item in the history, which will be the currentItem if you goForward.  Returns nil if there is nothing forward in the history.
*/
- (id) nextItem;

/*!
    @method     previousItem
    @abstract 
	@discussion Get the previous item.
	@result Returns the previous item in the history, which will be the currentItem if you goBack.  Returns nil if there is nothing back in the history.
*/
- (id) previousItem;

/*!
    @method indexOfCurrentItem
    @abstract
	@discussion Determine the current position within the history.
    @result Returns the index of the current item in history, or -1 if there is no history.
*/
- (int) indexOfCurrentItem;

/*!
    @method goForwardWithItem:
    @abstract 
    @discussion Insert new item after the current item in the history.  This method will delete any existing forward items from the history.  If adding a new item exceeds the maximum number of items as set by setMaxItems:, an item will be removed from the start of the history.
	@param item The new item to put at the end of the history.
*/
- (void) goForwardWithItem:(id)item;

/*!
    @method goForward    
    @abstract 
    @discussion Go forward in the history, if possible
	@result Returns the new currentItem in history, or nil if it was not able to go forward.
*/
- (id) goForward;

/*!
	@method goBack    
	@abstract 
	@discussion Go back in the history, if possible
	@result Returns the new currentItem in history, or nil if it was not able to go back.
*/
- (id) goBack;

/*!
	@method goToIndex:    
	@abstract 
	@discussion Go to a particular place in the history
	@param newIndex The index of the item in history to go to.
	@result Returns the new currentItem in history, or nil if it was not able to go there.
*/
- (id) goToIndex:(int)newIndex;

/*!
	@method canGoToIndex:    
	@abstract 
	@discussion Determine if you can go to a particular place in the history
	@param newIndex The index of the item in history to go to.
	@result Returns YES if it can go to that index, or NO otherwise.
*/
- (BOOL) canGoToIndex:(int)newIndex;

- (void) unshiftHistoryItem:(id)item;
- (id) shiftHistoryItem;
- (void) pushHistoryItem:(id)item;
- (id) popHistoryItem;

@end
