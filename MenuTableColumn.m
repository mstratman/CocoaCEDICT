#import "MenuTableColumn.h"

@implementation MenuTableColumn

- (NSMenu *) columnMenu
{
	return colMenu;
}

- (BOOL) displayMenu
{
	return _displayMenu;
}
- (void) setDisplayMenu:(BOOL)shouldDisplayMenu
{
	_displayMenu = shouldDisplayMenu;
}

@end
