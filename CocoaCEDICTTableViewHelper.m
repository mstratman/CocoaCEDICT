#import "CocoaCEDICTTableViewHelper.h"

/* 
	Category to handle the tableview's data source and delegate
	methods.
 */

@implementation CocoaCEDICTAppDelegate (CocoaCEDICTTableViewHelper)

#pragma mark DataSourceMethods

/* numberOfRowsInTableView: is called very frequently, 
   so it must be efficient. 
*/
- (int) numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [lastSearchResults count];
}

/* tableView:objectValueForTableColumn:row: is called each time the 
   table cell needs to be redisplayed, so it must be efficient. */
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			 row:(int)rowIndex
{
	NSString *colid = (NSString *)[aTableColumn identifier];
	if (lastSearchResults == nil) { return @"Error: Badddd error"; }
	if ([lastSearchResults count] <= rowIndex) {
		return @"Error: Bad index";
	}
	id entry = [lastSearchResults objectAtIndex:rowIndex];
	if (entry == nil) {
		return @"Error: No Entry";
	}
	if ([colid isEqualToString:@"traditional"]) {
		NSString *trad = (NSString *)[entry valueForKey:@"traditional"];
		if (trad == nil) {
			return @"Error";
		} else {
			return trad;
		}
	} else if ([colid isEqualToString:@"simplified"]) {
		NSString *simp = (NSString *)[entry valueForKey:@"simplified"];
		if (simp == nil) {
			return @"Error";
		} else {
			return simp;
		}
	} else if ([colid isEqualToString:@"pinyin"]) {
		NSString *py = (NSString *)[entry valueForKey:@"pinyin"];
		if (py == nil) { return @"Error"; }
		NSNumber *toneMarks = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"useToneMarks"];
		if ([toneMarks boolValue]) {
			Pinyin2Unicode *pyConverter = [Pinyin2Unicode converter];
			return [pyConverter convert:py];
		} else {
			return py;
		}
	} else if ([colid isEqualToString:@"english"]) {
		NSMutableString *eng = [NSMutableString stringWithCapacity:30];
		NSSet *engSet = [entry mutableSetValueForKey:@"english"];
		if (engSet == nil) { return @"Error: No set"; }
		NSArray *engArray = [engSet allObjects];
		if (engArray == nil) { return @"Error"; }
		unsigned int i, count = [engArray count];
		for (i = 0; i < count; i++) {
			id engEntry = [engArray objectAtIndex:i];
			if (engEntry == nil) { return @"Error: No English entry"; }
			NSString *def = (NSString *)[engEntry valueForKey:@"definition"];
			if (def != nil) {
				[eng appendString:def];
				if (i + 1 != count) {
					[eng appendString:@",\n"];
				}
			}
		}
		return eng;
	}
	return @"Error";
}

- (void) tableView:(NSTableView *)aTableView setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn *)aTableColumn 
			   row:(int)rowIndex
{
	return;
}

#pragma mark DelegateMethods

- (void) tableView:(NSTableView *)aTableView willDisplayCell:(id)cell 
	forTableColumn:(NSTableColumn *)aTableColumn 
			   row:(int)rowIndex
{
	NSString *col = (NSString *)[aTableColumn identifier];
	
	[cell setDrawsBackground:YES];
	if (rowIndex % 2) {
		[cell setBackgroundColor:[self color1]];
	} else {
		[cell setBackgroundColor:[self color2]];
	}
	
	if ([col isEqualToString:@"traditional"]
		|| [col isEqualToString:@"simplified"])
	{
		if (chinFont != nil) {
			[cell setFont:chinFont];
		}
	} else {
		if (chinFont != nil) {
			[cell setFont:engFont];
		}
	}
}

@end
