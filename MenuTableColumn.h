#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MenuTableColumn : NSTableColumn
{
	IBOutlet NSMenu *colMenu;
	BOOL _displayMenu;
}

- (NSMenu *) columnMenu;

- (BOOL) displayMenu;
- (void) setDisplayMenu:(BOOL)shouldDisplayMenu;

@end
