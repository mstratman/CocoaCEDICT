/* CocoaCEDICTAppDelegate */

#import <Cocoa/Cocoa.h>
#import "MenuedTableView.h"
#import "ArrowButton.h"
#import "History.h"
#import "Pinyin2Unicode.h"

/* NOTE: If you change the History menu, change this */
#define INDEX_OF_FIRST_HISTORY_MENUITEM 3

#define HISTORY_MENU_TAG 111

#define CHIN_FONT_PANEL 1
#define ENG_FONT_PANEL  2

#define SEARCH_SECTION_ANY      0
#define SEARCH_SECTION_ENG      1
#define SEARCH_SECTION_PY       2
#define SEARCH_SECTION_PY_TONE  3
#define SEARCH_SECTION_TRAD     4
#define SEARCH_SECTION_SIMP     5
#define SEARCH_SECTION_ANY_CHIN 6

#define SEARCH_TYPE_ANY    0
#define SEARCH_TYPE_EXACT  1
#define SEARCH_TYPE_STARTS 2
#define SEARCH_TYPE_ENDS   3

@interface CocoaCEDICTAppDelegate : NSObject
{
	IBOutlet NSTextField *chinFontDisplay;
	IBOutlet NSTextField *engFontDisplay;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSTableView *tableView;
	IBOutlet ArrowButton *backButton;
	IBOutlet ArrowButton *forwardButton;
	IBOutlet NSWindow *window;
	
	History *searchHistory;
	NSArray *lastSearchResults;

	NSColor *color1;
	NSColor *color2;
	NSFont *chinFont;
	NSFont *engFont;
	int lastFontPanel;
	
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	
	// KVO/KVC stuff
	NSNumber *historyCanGoBack;
	NSNumber *historyCanGoForward;
}

// Convenience methods around the color... To prevent having to
// unarchive color objects repeatedly while displaying the table
- (NSColor *)color1;
- (NSColor *)color2;
- (void) setColor1:(NSColor *)newColor1;
- (void) setColor2:(NSColor *)newColor2;

// Apple-provided stuff
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (IBAction)saveAction:(id)sender;

// Copy stuff
- (id) entryAtSelectedRow;
- (void) putStringInPasteboard:(NSString *)str;
- (IBAction)copyAll:(id)sender;
- (IBAction)copyEnglish:(id)sender;
- (IBAction)copyPinyin:(id)sender;
- (IBAction)copySimp:(id)sender;
- (IBAction)copyTrad:(id)sender;

// Search stuff
- (void) searchAndGoForwardInHistory:(BOOL)goForward;
- (IBAction)search:(id)sender;

// Font stuff
- (IBAction)showChinFontPanel:(id)sender;
- (IBAction)showEngFontPanel:(id)sender;

- (IBAction)showCEDICTReadme:(id)sender;

// History-related stuff
- (void) setControlsToHistoryItem:(NSDictionary *)item;
- (IBAction)historyBack:(id)sender;
- (IBAction)historyForward:(id)sender;
- (IBAction)historyItemSelected:(id)sender;
- (void) historyDidChange; // Call this anytime you modify the history.

// Setup stuff
- (void) setupUserDefaults;
- (void) setupTableView;
- (void) setChinFont;
- (void) setEngFont;
- (void) setupSearchMenu;
- (NSArray *) pickBestFonts;

- (void) populateHistoryMenu;

/* Methods used in bindings */
- (void) registerAsObserver;
- (void) removeAsObserver;
- (NSNumber *) isRowSelected;
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
