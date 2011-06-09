#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MenuTableColumn.h"
#import "RowResizableTableView.h"

@interface MenuedTableView : RowResizableTableView
{
	int _menuCol;
	int _menuRow;
}

- (int) menuRow;
- (void) setMenuRow:(int)row;
- (int) menuCol;
- (void) setMenuCol:(int)col;

@end
