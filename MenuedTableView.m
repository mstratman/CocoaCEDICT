#import "MenuedTableView.h"
#import "MenuTableColumn.h"

@implementation MenuedTableView

- (int) menuRow { return _menuRow; }
- (void) setMenuRow:(int)row { _menuRow = row; }
- (int) menuCol { return _menuCol; }
- (void) setMenuCol:(int)col { _menuCol = col; }

- (void) mouseDown:(NSEvent *)event
{
	[super mouseDown:event];
	if (!([event modifierFlags] & NSControlKeyMask)) {
		return;
	}
	NSPoint point = [event locationInWindow];
	point = [self convertPoint:point fromView:nil];

	MenuTableColumn *col;
	NSMenu *menu;
	[self setMenuRow:[self rowAtPoint:point]];
	[self setMenuCol:[self columnAtPoint:point]];
	col = [[self tableColumns] objectAtIndex:[self menuCol]];
	
	if ([col displayMenu] && ([self menuRow] != -1)) {
		menu = [col columnMenu] ? [col columnMenu] : [self menu];
		if (!menu) {
			[self setMenuRow:-1];
			[self setMenuCol:-1];
		}
		[NSMenu popUpContextMenu:menu withEvent:event forView:self];
	} else {
		[self setMenuRow:-1];
		[self setMenuCol:-1];
	}
}
- (NSMenu *) menuForEvent:(NSEvent *)event { return nil; }

@end
