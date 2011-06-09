//  CocoaCEDICTAppDelegate.m
//  CocoaCEDICT
//
//  Created by Mark on 5/4/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.

#import "CocoaCEDICTAppDelegate.h"


@implementation CocoaCEDICTAppDelegate

- (id) init 
{
	self = [super init];
	if (self != nil) {
		[self setupUserDefaults];
		searchHistory = [[History alloc] init];
		lastSearchResults = [[NSArray alloc] init];
		[self setValue:[NSNumber numberWithBool:NO] forKey:@"historyCanGoBack"];
		[self setValue:[NSNumber numberWithBool:NO] forKey:@"historyCanGoForward"];
	}
	return self;
}

- (void) applicationWillTerminate:(NSNotification *)notif
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void) awakeFromNib
{
	[window setFrameUsingName:@"CocoaCEDICTMainWindow1"];
	[window setFrameAutosaveName:@"CocoaCEDICTMainWindow1"];

	[self registerAsObserver];

	[self setupTableView];
	[self setChinFont];
	[self setEngFont];
	[self setupSearchMenu];

	[backButton setType:ArrowButtonTypeLeft];
	[backButton setModifierMask:NSCommandKeyMask];
	[forwardButton setType:ArrowButtonTypeRight];
	[forwardButton setModifierMask:NSCommandKeyMask];

	[[NSApplication sharedApplication] setDelegate:self];
}

- (History *) history
{
	return searchHistory;
}

#pragma mark Color methods

// Convenience methods around the color... To prevent having to
// unarchive color objects repeatedly while displaying the table
- (NSColor *)color1
{
	if (color1 == nil) {
		color1 = [NSUnarchiver unarchiveObjectWithData:
			[[NSUserDefaults standardUserDefaults] objectForKey:@"rowColor1"]];
		[color1 retain];
	}
	return color1;
}
- (NSColor *)color2
{
	if (color2 == nil) {
		color2 = [NSUnarchiver unarchiveObjectWithData:
			[[NSUserDefaults standardUserDefaults] objectForKey:@"rowColor2"]];
		[color2 retain];
	}
	return color2;	
}
- (void) setColor1:(NSColor *)newColor1
{
	id old = color1;
	color1 = [newColor1 retain];
	[old release];
}
- (void) setColor2:(NSColor *)newColor2
{
	id old = color2;
	color2 = [newColor2 retain];
	[old release];
}


#pragma mark Apples Supplied Methods

// pre-defined method
- (NSManagedObjectModel *)managedObjectModel 
{
	if (managedObjectModel) return managedObjectModel;
	
	NSMutableSet *allBundles = [[NSMutableSet alloc] init];
	[allBundles addObject: [NSBundle mainBundle]];
	[allBundles addObjectsFromArray: [NSBundle allFrameworks]];

	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
	[allBundles release];

	return managedObjectModel;
}

// pre-defined method
- (NSString *)applicationSupportFolder 
{
	return [[NSBundle mainBundle] resourcePath];
}

// pre-defined method
- (NSManagedObjectContext *) managedObjectContext {
	NSError *error;
	NSString *applicationSupportFolder = nil;
	NSURL *url;
	NSFileManager *fileManager;
	NSPersistentStoreCoordinator *coordinator;
	
	if (managedObjectContext) {
		return managedObjectContext;
	}
	
	fileManager = [NSFileManager defaultManager];
	applicationSupportFolder = [self applicationSupportFolder];
	if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
		[fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
	}

	url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"CocoaCEDICT.cedictsql"]];
	coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	if ([coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	} else {
		[[NSApplication sharedApplication] presentError:error];
	}	
	[coordinator release];
	
	return managedObjectContext;
}

// pre-defined method
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
	return [[self managedObjectContext] undoManager];
}

// pre-defined method
- (IBAction) saveAction:(id)sender {
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) {
		[[NSApplication sharedApplication] presentError:error];
	}
}

// pre-defined method
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSError *error;
	NSManagedObjectContext *context;
	int reply = NSTerminateNow;
	
	context = [self managedObjectContext];
	if (context != nil) {
		if ([context commitEditing]) {
			if (![context save:&error]) {
				
				// This default error handling implementation should be changed to make sure the error presented includes application specific error recovery. For now, simply display 2 panels.
				BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
				if (errorResult == YES) { // Then the error was handled
					reply = NSTerminateCancel;
				} else {
					
					// Error handling wasn't implemented. Fall back to displaying a "quit anyway" panel.
					int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
					if (alertReturn == NSAlertAlternateReturn) {
						reply = NSTerminateCancel;
					}
				}
			}
		} else {
			reply = NSTerminateCancel;
		}
	}
	return reply;
}

#pragma mark IB Actions

- (void) searchAndGoForwardInHistory:(BOOL)goForward
{
	if (goForward) {
		[self search:searchField];
	} else {
		[self search:self];
	}
}

// If sender is searchField, it will create a new history item goForwardWithItem: in the history.
// Otherwise, it does nothing with the history
- (IBAction)search:(id)sender
{
	NSString *text = [[searchField cell] stringValue];
	if (text == nil || ![text length]) { return; }

	int type = [[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedMatchType"] intValue];
	int section = [[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedMatchSection"] intValue];
	
	[progressIndicator startAnimation:self];

	// defaultFetchRequest is defined for the "Entry" entity in the data model.
	NSFetchRequest *fetch = [[self managedObjectModel] fetchRequestTemplateForName:@"defaultFetchRequest"];
	NSPredicate *pred;
	NSString *condition;
	NSString *predString;
	NSString *searchSectionString; // for History
	
	// Setup fetch predicate (and section name for history)
	if (type == SEARCH_TYPE_ANY) {
		condition = @"CONTAINS";
	} else if (type == SEARCH_TYPE_ENDS) {
		condition = @"ENDSWITH";
	} else if (type == SEARCH_TYPE_EXACT) {
		condition = @"==";
	} else if (type == SEARCH_TYPE_STARTS) {
		condition = @"BEGINSWITH";
	}
	if (section == SEARCH_SECTION_ANY) {
		searchSectionString = @"Any";
		predString = @"(traditional %@ $TEXT) OR (simplified %@ $TEXT) OR (pinyinNoTone %@ $TEXT) OR (pinyin %@ $TEXT) OR (ANY english.definition %@ $TEXT)";
		predString = [NSString stringWithFormat:predString, condition, condition, condition, condition,condition];
	} else if (section == SEARCH_SECTION_ANY_CHIN) {
		searchSectionString = @"Chinese";
		predString = @"(traditional %@ $TEXT) OR (simplified %@ $TEXT)";
		predString = [NSString stringWithFormat:predString, condition, condition];
	} else if (section == SEARCH_SECTION_ENG) {
		searchSectionString = @"English";
		//TODO/FIXME: Why doesn't 'ANY english.definition CONTAINS $TEXT' work?
		if (type == SEARCH_TYPE_ANY) {
			condition = @"LIKE";
			text = [NSString stringWithFormat:@"*%@*", text];
		}
		predString = @"ANY english.definition %@ $TEXT";
		predString = [NSString stringWithFormat:predString, condition];
	} else if (section == SEARCH_SECTION_PY) {
		searchSectionString = @"Pinyin";
		predString = @"(pinyin %@ $TEXT) OR (pinyinNoTone %@ $TEXT)";
		predString = [NSString stringWithFormat:predString, condition, condition];
	} else if (section == SEARCH_SECTION_PY_TONE) {
		searchSectionString = @"Pinyin w/tone";
		predString = @"pinyin %@ $TEXT";
		predString = [NSString stringWithFormat:predString, condition];
	} else if (section == SEARCH_SECTION_SIMP) {
		searchSectionString = @"Simplified";
		predString = @"simplified %@ $TEXT";
		predString = [NSString stringWithFormat:predString, condition];
	} else if (section == SEARCH_SECTION_TRAD) {
		searchSectionString = @"Traditional";
		predString = @"traditional %@ $TEXT";
		predString = [NSString stringWithFormat:predString, condition];
	}
	pred = [[NSPredicate predicateWithFormat:predString] 
					predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:text forKey:@"TEXT"]];
	[fetch setPredicate:pred];

	// Finish setting up the fetch
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"pinyin" 
														 ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
	[fetch setSortDescriptors:sortDescriptors];
	[fetch setFetchLimit:0];

	// Perform the fetch
	NSError *error = nil;
	NSArray *results;
	results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];
	[sort release];
	if (results == nil) {
		NSLog(@"Error executing fetch request: '%@'", error);
	} else {
		[lastSearchResults release];
		lastSearchResults = [results retain];
	}
	
	// TODO - maybe: set message if nothing was returned
	
	[tableView reloadData];
	[progressIndicator stopAnimation:self];

	// create history item
	if (sender == searchField) {
		NSDictionary *historyItem = [NSDictionary dictionaryWithObjectsAndKeys:
			text, @"searchTerm",
			searchSectionString, @"section",
			[NSNumber numberWithInt:type], @"matchTypeIndex",
			[NSNumber numberWithInt:section], @"matchSectionIndex",
			nil];
		[searchHistory goForwardWithItem:historyItem];
		[self historyDidChange];
	}
}

- (IBAction)showCEDICTReadme:(id)sender
{
	NSString *cedictFile = [[NSBundle mainBundle] pathForResource:@"cedict_readme" 
														   ofType:@"txt"];
	[[NSWorkspace sharedWorkspace] openFile:cedictFile];
}

#pragma mark Clipboard IB Actions

- (id) entryAtSelectedRow
{
	int row = [tableView selectedRow];
	if (row == -1) { 
		return nil; 
	}
	if (![lastSearchResults count]) { 
		return nil; 
	}
	if (row >= [lastSearchResults count]) { 
		return nil; 
	}
	return [lastSearchResults objectAtIndex:row];	
}
- (void) putStringInPasteboard:(NSString *)str
{
	NSArray *pbtypes = [NSArray arrayWithObject:NSStringPboardType];
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:pbtypes owner:nil];
	[pb setString:str forType:NSStringPboardType];
}

- (IBAction)copyAll:(id)sender
{
	id entry = [self entryAtSelectedRow];
	if (entry == nil) { return; }
	NSMutableString *str = [NSMutableString stringWithCapacity:50];
	
	[str appendString:@"Traditional: "];
	NSString *trad = [entry valueForKey:@"traditional"];
	if (trad == nil) { trad = @""; }
	[str appendString:trad];
	
	[str appendString:@";  Simplified: "];
	NSString *simp = [entry valueForKey:@"simplified"];
	if (simp == nil) { simp = @""; }
	[str appendString:simp];
	
	[str appendString:@";  ["];
	NSString *py = [entry valueForKey:@"pinyin"];
	if (py == nil) { py = @""; }
	NSNumber *toneMarks = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"useToneMarks"];
	if ([toneMarks boolValue]) {
		Pinyin2Unicode *pyConverter = [Pinyin2Unicode converter];
		py = [pyConverter convert:py];
	}
	[str appendString:py];
	[str appendString:@"] /"];
	
	NSArray *engArray = [[entry mutableSetValueForKey:@"english"] allObjects];
	NSMutableString *engString = [NSMutableString stringWithCapacity:30];
	if (engArray != nil && [engArray count]) {
		int i, count = [engArray count];
		for (i = 0; i < count; i++) {
			NSString *def = (NSString *)[[engArray objectAtIndex:i] valueForKey:@"definition"];
			[engString appendString:def];
			if (i + 1 < count) {
				[engString appendString:@"; "];
			}
		}
		
	}
	[str appendString:engString];
	[str appendString:@"/"];
	
	[self putStringInPasteboard:str];
}
- (IBAction)copyEnglish:(id)sender
{
	id entry = [self entryAtSelectedRow];
	if (entry == nil) { return; }
	NSArray *engArray = [[entry mutableSetValueForKey:@"english"] allObjects];
	if (engArray == nil) { return; }
	NSMutableString *engString = [NSMutableString stringWithCapacity:30];
	int i, count = [engArray count];
	for (i = 0; i < count; i++) {
		NSString *def = (NSString *)[[engArray objectAtIndex:i] valueForKey:@"definition"];
		[engString appendString:def];
		if (i + 1 < count) {
			[engString appendString:@"; "];
		}
	}
	[self putStringInPasteboard:engString];
}
- (IBAction)copyPinyin:(id)sender
{
	id entry = [self entryAtSelectedRow];
	if (entry == nil) { return; }
	NSString *pyString;
	NSNumber *toneMarks = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:@"useToneMarks"];
	if ([toneMarks boolValue]) {
		Pinyin2Unicode *pyConverter = [Pinyin2Unicode converter];
		pyString = [pyConverter convert:[entry valueForKey:@"pinyin"]];
	} else {
		pyString = [entry valueForKey:@"pinyin"];
	}
	if (pyString == nil) { return; }

	[self putStringInPasteboard:pyString];
}
- (IBAction)copySimp:(id)sender
{
	id entry = [self entryAtSelectedRow];
	if (entry == nil) { return; }
	NSString *simp = [entry valueForKey:@"simplified"];
	if (simp == nil) { return; }
	[self putStringInPasteboard:simp];
}
- (IBAction)copyTrad:(id)sender
{
	id entry = [self entryAtSelectedRow];
	if (entry == nil) { return; }
	NSString *trad = [entry valueForKey:@"traditional"];
	if (trad == nil) { return; }
	[self putStringInPasteboard:trad];	
}

#pragma mark Font Related IB Actions

// NSFontManager delegate method
- (void)changeFont:(id)sender
{
	NSFontManager *fm = [NSFontManager sharedFontManager];
	NSFont *font = [fm selectedFont];
	if (font == nil) {
		NSLog(@"Got nil font");
		return;
	}
	NSFont *pfont = [fm convertFont:font];
	NSNumber *size = [NSNumber numberWithFloat:[pfont pointSize]];
	NSString *name = [pfont fontName];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if (lastFontPanel == CHIN_FONT_PANEL) {
		// TODO ... should we setValue through controller instead?
		[ud setObject:name forKey:@"chinFontName"];
		[ud setObject:size forKey:@"chinFontSize"];
		[self setChinFont];
	} else if (lastFontPanel == ENG_FONT_PANEL) {
		[ud setObject:name forKey:@"engFontName"];
		[ud setObject:size forKey:@"engFontSize"];
		[self setEngFont];
	}
}

- (IBAction)showChinFontPanel:(id)sender
{
	lastFontPanel = CHIN_FONT_PANEL; //used by changeFont
	NSNumber *size = [[NSUserDefaults standardUserDefaults] objectForKey:@"chinFontSize"];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"chinFontName"];
	NSFont *font = [NSFont fontWithName:name size:[size floatValue]];
	if (font == nil) {
		NSLog(@"Couldn't get Chinese font to show with panel.");
		return;
	}
	[[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
	[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
	[window makeFirstResponder:window]; // Why did i do this?
}
- (IBAction)showEngFontPanel:(id)sender
{
	lastFontPanel = ENG_FONT_PANEL; //used by changeFont
	NSNumber *size = [[NSUserDefaults standardUserDefaults] objectForKey:@"engFontSize"];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"engFontName"];
	NSFont *font = [NSFont fontWithName:name size:[size floatValue]];
	if (font == nil) {
		NSLog(@"Couldn't get English font to show with panel.");
		return;
	}
	[[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
	[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
	[window makeFirstResponder:window]; // Why did i do this?
}

#pragma mark History IB Actions

- (void) setControlsToHistoryItem:(NSDictionary *)item
{
	// We don't want to trigger a new search when we do this, so turn off observing
	[self removeAsObserver];
	[[NSUserDefaults standardUserDefaults] setObject:[item objectForKey:@"matchTypeIndex"]
											  forKey:@"selectedMatchType"];
	[[NSUserDefaults standardUserDefaults] setObject:[item objectForKey:@"matchSectionIndex"]
											  forKey:@"selectedMatchSection"];
	[[searchField cell] setStringValue:[item objectForKey:@"searchTerm"]];
	[self registerAsObserver];
}

- (IBAction)historyBack:(id)sender
{
	if ([searchHistory canGoBack]) {
		NSDictionary *item = [searchHistory goBack];
		[self setControlsToHistoryItem:item];
		[self searchAndGoForwardInHistory:NO];
		[self historyDidChange];
	}
}
- (IBAction)historyForward:(id)sender
{
	if ([searchHistory canGoForward]) {
		NSDictionary *item = [searchHistory goForward];
		[self setControlsToHistoryItem:item];
		[self searchAndGoForwardInHistory:NO];
		[self historyDidChange];
	}
}
- (IBAction) historyItemSelected:(id)sender
{
	if (![sender isMemberOfClass:[NSMenuItem class]]) {
		return;
	}
	NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
	NSMenuItem *hMenuItem = [mainMenu itemWithTag:HISTORY_MENU_TAG];
	if (hMenuItem == nil) {
		NSLog(@"Nil menu item for tag 111 (Should be History)");
		return;
	}
	NSMenu *hMenu = [hMenuItem submenu];
	
	int menuIndex = [hMenu indexOfItem:sender];
	if (menuIndex < INDEX_OF_FIRST_HISTORY_MENUITEM) {
		return; // should never happen
	}
	menuIndex -= INDEX_OF_FIRST_HISTORY_MENUITEM;
	// Now menuIndex is reversed.. since we reversed the items in the history menu (most recent at the top)
	// It will be 0 for the most recent history item, 1 for the next, etc

	NSArray *history = [searchHistory allItems];
	int indexOfLastHistoryItem = [history count] - 1;
	int arrayIndex = indexOfLastHistoryItem - menuIndex;

	if ([searchHistory canGoToIndex:arrayIndex]) {
		NSDictionary *item = [searchHistory goToIndex:arrayIndex];
		[self setControlsToHistoryItem:item];
		[self searchAndGoForwardInHistory:NO];
		[self historyDidChange];
	}
}

#pragma mark KVC Stuff

- (void) registerAsObserver
{
	// NOTE - we're only going to observe when the font size changes, as opposed to
	// when either the face or size changes...
	// This is because the font size can change on its own (when you use the
	// the slider), but the face always changes with the size (in changeFont)	
	NSUserDefaultsController *ud = [NSUserDefaultsController sharedUserDefaultsController];
	[ud addObserver:self forKeyPath:@"values.chinFontSize" options:NSKeyValueObservingOptionNew context:NULL];
	[ud addObserver:self forKeyPath:@"values.engFontSize" options:NSKeyValueObservingOptionNew context:NULL];
	[ud addObserver:self forKeyPath:@"values.useToneMarks" options:NSKeyValueObservingOptionNew context:NULL];
	[ud addObserver:self forKeyPath:@"values.selectedMatchType" options:NSKeyValueObservingOptionNew context:NULL];
	[ud addObserver:self forKeyPath:@"values.selectedMatchSection" options:NSKeyValueObservingOptionNew context:NULL];
	[ud addObserver:self forKeyPath:@"values.rowColor1" options:NSKeyValueObservingOptionNew context:NULL];
	[ud addObserver:self forKeyPath:@"values.rowColor2" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void) removeAsObserver
{
	NSUserDefaultsController *ud = [NSUserDefaultsController sharedUserDefaultsController];
	[ud removeObserver:self forKeyPath:@"values.chinFontSize"];
	[ud removeObserver:self forKeyPath:@"values.engFontSize"];
	[ud removeObserver:self forKeyPath:@"values.useToneMarks"];
	[ud removeObserver:self forKeyPath:@"values.selectedMatchType"];
	[ud removeObserver:self forKeyPath:@"values.selectedMatchSection"];
	[ud removeObserver:self forKeyPath:@"values.rowColor1"];
	[ud removeObserver:self forKeyPath:@"values.rowColor2"];
}

- (NSNumber *) isRowSelected
{
	if ([tableView selectedRow] != -1) {
		return [NSNumber numberWithBool:YES];
	}
	return [NSNumber numberWithBool:NO];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
						 change:(NSDictionary *)change context:(void *)context
{
	if (![object isMemberOfClass:[NSUserDefaultsController class]]) {
		return;
	}
	// NOTE - we're only going to reload when the font size changes, as opposed to
	// when either the face or size changes...
	// This is because the font size can change on its own (when you use the
	// the slider), but the face always changes with the size (in changeFont)
	if ([keyPath isEqualToString:@"values.chinFontSize"]) {
		[progressIndicator startAnimation:self];
		[self setChinFont];
		[tableView reloadData];
		[progressIndicator stopAnimation:self];
	} else if ([keyPath isEqualToString:@"values.engFontSize"]) {
		[progressIndicator startAnimation:self];
		[self setEngFont];
		[tableView reloadData];
		[progressIndicator stopAnimation:self];
	} else if ([keyPath isEqualToString:@"values.useToneMarks"]) {
		[progressIndicator startAnimation:self];
		[tableView reloadData];
		[progressIndicator stopAnimation:self];
	} else if ([keyPath isEqualToString:@"values.selectedMatchType"] || [keyPath isEqualToString:@"values.selectedMatchSection"]) {
		if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"searchOnParameterChange"] boolValue]) {
			NSString *text = [[searchField cell] stringValue];
			if (text != nil && [text length]) {
				[self searchAndGoForwardInHistory:YES];
			}
		}
	} else if ([keyPath isEqualToString:@"values.rowColor1"]) {
		[self setColor1:(NSColor *)[NSUnarchiver unarchiveObjectWithData:
			[[NSUserDefaults standardUserDefaults] objectForKey:@"rowColor1"]]];
		[progressIndicator startAnimation:self];
		[tableView reloadData];
		[progressIndicator stopAnimation:self];			
	} else if ([keyPath isEqualToString:@"values.rowColor2"]) {
		[self setColor2:(NSColor *)[NSUnarchiver unarchiveObjectWithData:
			[[NSUserDefaults standardUserDefaults] objectForKey:@"rowColor2"]]];
		[progressIndicator startAnimation:self];
		[tableView reloadData];
		[progressIndicator stopAnimation:self];
	}
}

#pragma mark Setup Stuff

- (void) setupUserDefaults
{
	NSArray *fonts = [self pickBestFonts];
	
	NSColor *defColor1 = [NSColor whiteColor];
	NSColor *defColor2 = [NSColor colorWithDeviceRed:0.88 green:0.88 blue:1.0 alpha:1.0];
	
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:16.0], @"chinFontSize",
		(NSString *)[fonts objectAtIndex:0], @"chinFontName",
		[NSNumber numberWithFloat:14.0], @"engFontSize",
		(NSString *)[fonts objectAtIndex:1], @"engFontName",
		[NSNumber numberWithBool:YES], @"useToneMarks",
		[NSNumber numberWithBool:YES], @"searchOnParameterChange",
		[NSNumber numberWithInt:0], @"selectedMatchSection",
		[NSNumber numberWithInt:0], @"selectedMatchType",
		[NSArchiver archivedDataWithRootObject:defColor1], @"rowColor1",
		[NSArchiver archivedDataWithRootObject:defColor2], @"rowColor2",
		nil];
	
	if ([[NSUserDefaults standardUserDefaults] 
		persistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]])
	{
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	} else {
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:defaults 
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setupTableView
{
	[tableView setDataSource:self];
	[tableView setDelegate:self];
	[tableView setIntercellSpacing:NSMakeSize(0.0, 2.0)];
	[tableView setAllowsColumnReordering:YES];
	[tableView setAllowsColumnResizing:YES];
	[tableView setAllowsMultipleSelection:NO];
	[tableView setAllowsEmptySelection:YES];
	[tableView setAutosaveName:@"CocoaCEDICT3"];
	[tableView setAutosaveTableColumns:YES];
	NSEnumerator *en = [[tableView tableColumns] objectEnumerator];
	id obj;
	while (obj = [en nextObject]) {
		[(MenuTableColumn *)obj setDisplayMenu:YES];
	}
}

- (void) setChinFont
{
	NSNumber *size = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"chinFontSize"];
	NSString *name = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"chinFontName"];
	if (chinFont != nil) {
		[chinFont release];
	}
	chinFont = [[NSFont fontWithName:name size:[size floatValue]] retain];
	if (chinFont != nil) {
		[chinFontDisplay setStringValue:[NSString stringWithFormat:@"%@ - %f", 
			[chinFont displayName], [chinFont pointSize]]];
	} else {
		NSLog(@"Chinese font is nil.... very bad news");
	}
}
- (void) setEngFont
{
	NSNumber *size = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"engFontSize"];
	NSString *name = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"engFontName"];
	if (engFont != nil) {
		[engFont release];
	}
	engFont = [[NSFont fontWithName:name size:[size floatValue]] retain];
	if (engFont != nil) {
		[engFontDisplay setStringValue:[NSString stringWithFormat:@"%@ - %f", 
			[engFont displayName], [engFont pointSize]]];
	} else {
		NSLog(@"English font is nil.... very bad news");
	}	
}

- (void) setupSearchMenu
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Search Menu"];
	[menu autorelease];
	
	NSMenuItem *mi1 = [[NSMenuItem alloc] initWithTitle:@"Recent Searches" action:nil keyEquivalent:@""];
	[mi1 autorelease];
	[mi1 setTag:NSSearchFieldRecentsTitleMenuItemTag];
	
	NSMenuItem *mi2 = [[NSMenuItem alloc] initWithTitle:@"Recents" action:nil keyEquivalent:@""];
	[mi2 autorelease];
	[mi2 setTag:NSSearchFieldRecentsMenuItemTag];
	
	NSMenuItem *mi3 = [[NSMenuItem alloc] initWithTitle:@"Clear Recent Searches" action:nil keyEquivalent:@""];
	[mi3 autorelease];
	[mi3 setTag:NSSearchFieldClearRecentsMenuItemTag];

	NSMenuItem *mi4 = [[NSMenuItem alloc] initWithTitle:@"No Recent Searches" action:nil keyEquivalent:@""];
	[mi4 autorelease];
	[mi4 setTag:NSSearchFieldNoRecentsMenuItemTag];
	
	[menu insertItem:mi1 atIndex:0];
	[menu insertItem:mi2 atIndex:1];
	[menu insertItem:mi3 atIndex:2];
	[menu insertItem:mi4 atIndex:3];
	[[searchField cell] setSearchMenuTemplate:menu];
}

// Returns { chinFontName, engFontName }
- (NSArray *) pickBestFonts
{
	NSArray *preferredChin = [NSArray arrayWithObjects:@"STKaiti", @"STFangsong",
		@"HiraKakuPro-W3", @"STSong", @"Helvetica", nil];
	NSArray *preferredEng = [NSArray arrayWithObjects:@"Helvetica", nil];
	NSFontManager *fm = [NSFontManager sharedFontManager];
	NSArray *af = [fm availableFonts];
	NSString *chinFontName;
	NSString *engFontName;
	unsigned int i, count = [preferredChin count];
	for (i = 0; i < count; i++) {
		if ([af containsObject:[preferredChin objectAtIndex:i]]) {
			chinFontName = (NSString *)[preferredChin objectAtIndex:i];
			break;
		}
	}
	count = [preferredEng count];
	for (i = 0; i < count; i++) {
		if ([af containsObject:[preferredEng objectAtIndex:i]]) {
			engFontName = (NSString *)[preferredEng objectAtIndex:i];
			break;
		}
	}
	if (chinFontName == nil) {
		chinFontName = @"Helvetica";
	}
	if (engFontName == nil) {
		engFontName = @"Helvetica";
	}
	return [NSArray arrayWithObjects:chinFontName, engFontName, nil];
}

// History items begin as the 4th item (back, forward, separator, then the history items)
- (void) populateHistoryMenu
{
	NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
	NSMenuItem *historyMenuItem = [mainMenu itemWithTag:HISTORY_MENU_TAG];
	if (historyMenuItem == nil) {
		NSLog(@"Nil menu item for tag 111 (Should be History)");
		return;
	}
	NSMenu *historyMenu = [historyMenuItem submenu];
	
	// Delete the existing history items
	NSArray *oldItems = [NSArray arrayWithArray:[historyMenu itemArray]];
	int i, oldItemsCount = [oldItems count];
	for (i = INDEX_OF_FIRST_HISTORY_MENUITEM; i < oldItemsCount; i++) {
		id oldItem = [oldItems objectAtIndex:i];
		[historyMenu removeItem:oldItem];
	}

	// Add the new ones (these are set in the search method)
	// These are added backwards.. newest first (at the top)
	NSArray *historyArray = [searchHistory allItems];
	for (i = 0; i < [historyArray count]; i++) {
		NSDictionary *item = (NSDictionary *)[historyArray objectAtIndex:i];
		NSString *title;
		if (i == [searchHistory indexOfCurrentItem]) {
			if ([[item objectForKey:@"matchSectionIndex"] intValue] != 0) {
				title = [NSString stringWithFormat:@"%@ %@ (%@)",
					[NSString stringWithCString:"➥" encoding:NSUTF8StringEncoding],
					[item objectForKey:@"searchTerm"], 
					[item objectForKey:@"section"]];
			} else {
				title = [NSString stringWithFormat:@"%@ %@",
					[NSString stringWithCString:"➥" encoding:NSUTF8StringEncoding],
					[item objectForKey:@"searchTerm"]];
			}
		} else {
			if ([[item objectForKey:@"matchSectionIndex"] intValue] != 0) {
				title = [NSString stringWithFormat:@"%@ (%@)", 
					[item objectForKey:@"searchTerm"], 
					[item objectForKey:@"section"]];
			} else {
				title = [item objectForKey:@"searchTerm"];
			}
		}
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(historyItemSelected:) keyEquivalent:@""];
		[historyMenu insertItem:menuItem atIndex:INDEX_OF_FIRST_HISTORY_MENUITEM];
		[menuItem release];
	}
}

- (void) historyDidChange
{
	[self setValue:[NSNumber numberWithBool:[searchHistory canGoBack]] 
									 forKey:@"historyCanGoBack"];
	[self setValue:[NSNumber numberWithBool:[searchHistory canGoForward]] 
									 forKey:@"historyCanGoForward"];
	[self populateHistoryMenu];
}

@end
