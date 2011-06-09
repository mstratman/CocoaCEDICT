//  build_dbAppDelegate.h
//  build_db
//
//  Created by Mark Stratman on 5/24/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

@interface build_dbAppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
	IBOutlet NSProgressIndicator *progress;
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (BOOL) parseFile:(NSString *)file;

- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction) doParse:sender;

@end
