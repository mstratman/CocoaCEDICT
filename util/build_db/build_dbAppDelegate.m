//  build_dbAppDelegate.m
//  build_db
//
//  Created by Mark Stratman on 5/24/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.

#import "build_dbAppDelegate.h"

@implementation build_dbAppDelegate

- (IBAction) doParse:(id)sender
{
	[progress startAnimation:self];
	if (![self parseFile:[[NSBundle mainBundle] pathForResource:@"cedict_ts" ofType:@"u8"]]) {
		NSLog(@"Parsing file failed");
	}	
	[progress stopAnimation:self];
}
- (BOOL) parseFile:(NSString *)file
{
	NSManagedObjectContext *context = [self managedObjectContext];
	NSError *error = nil;
	NSString *contents = [NSString stringWithContentsOfFile:file 
												   encoding:NSUTF8StringEncoding 
													  error:&error];
	if (contents == nil) {
		NSLog(@"stringWithContent... failed: %@", error);
		return NO;
	}
	
	NSArray *lines = [contents componentsSeparatedByString:@"\r\n"];
	unsigned int i, count = [lines count];
	
	// Format of a line:
	// <traditional><space><simplified><space>[<pinyin>]<space>/<english divided by /'s>/
	for (i = 0; i < count; i++) {
		NSString *trad, *simp, *py;
		NSMutableString *py_stripped;
		NSMutableArray *eng = [NSMutableArray arrayWithCapacity:5];
		NSString *line = (NSString *)[lines objectAtIndex:i];
		NSScanner *scan = [NSScanner scannerWithString:line];
		
		// Ignore lines starting with #
		if ([line hasPrefix:@"#"]) {
			continue;
		}

		//Skip initial whitespace
		[scan scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
		
		// Get traditional
		NSString *trad_tmp;
		if (![scan scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] 
							 intoString:&trad_tmp])
		{
			NSLog(@"Can't get traditional in '%@'", line);
			continue;
		}
		trad = [trad_tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// skip whitespace
		[scan scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];

		// Get simplified
		NSString *simp_tmp;
		if (![scan scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] 
								  intoString:&simp_tmp])
		{
			NSLog(@"Can't get simplified in '%@'", line);
			continue;
		}
		simp = [simp_tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		// skip whitespace
		[scan scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
		// skip [
		[scan scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"["] 
																			intoString:nil];
		
		// Get pinyin
		NSString *py_tmp;
		if (![scan scanUpToString:@"]" intoString:&py_tmp])
		{
			NSLog(@"Can't get pinyin in '%@'", line);
			continue;
		}
		py = [py_tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// Get stripped pinyin out of pinyin
		py_stripped = [NSMutableString stringWithCapacity:12];
		NSString *buffer;
		NSScanner *scan_py = [NSScanner scannerWithString:py];
		[scan_py setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
		while ([scan_py scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet]
									   intoString:&buffer])
		{
			[py_stripped appendString:buffer];
			[scan_py scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] 
								intoString:nil];
			buffer = nil;
		}
		
		// skip ]
		[scan scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"]"] 
						 intoString:nil];
		// skip whitespace
		[scan scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
		// skip first /
		[scan scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"] 
						 intoString:nil];


		// Setup the entry obj.
		NSManagedObject *entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" 
															   inManagedObjectContext:context];
		[entry setValue:trad forKey:@"traditional"];
		[entry setValue:simp forKey:@"simplified"];
		[entry setValue:py forKey:@"pinyin"];
		[entry setValue:[NSString stringWithString:py_stripped] forKey:@"pinyinNoTone"];

		
		// Get english
		NSString *tmpEng;
		while ([scan scanUpToString:@"/" intoString:&tmpEng]) {
			NSManagedObject *engObj = [NSEntityDescription insertNewObjectForEntityForName:@"EnglishDefinition" 
																	inManagedObjectContext:context];
			[engObj setValue:[tmpEng stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
					  forKey:@"definition"];
			[engObj setValue:entry forKey:@"entry"];
			
			tmpEng = nil;

			// skip /
			[scan scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"] 
							 intoString:nil];

		}

		// Add the english to the entry
		[[entry mutableSetValueForKey:@"english"] addObjectsFromArray:eng];
	}
	NSLog(@"ok1");
	NSError *saveError = nil;
	if (![context save:&saveError]) {
		NSLog(@"Error saving: '%@'", saveError);
		return NO;
	}
	NSLog(@"ok2");
	return YES;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel) return managedObjectModel;
	
	NSMutableSet *allBundles = [[NSMutableSet alloc] init];
	[allBundles addObject: [NSBundle mainBundle]];
	[allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return managedObjectModel;
}

/* Change this path/code to point to your App's data store. */
- (NSString *)applicationSupportFolder {
	return [[NSBundle mainBundle] resourcePath];
	
    NSString *applicationSupportFolder = nil;
    FSRef foundRef;
    OSErr err = FSFindFolder(kUserDomain, kApplicationSupportFolderType, kDontCreateFolder, &foundRef);
    if (err != noErr) {
        NSRunAlertPanel(@"Alert", @"Can't find application support folder", @"Quit", nil, nil);
        [[NSApplication sharedApplication] terminate:self];
    } else {
        unsigned char path[1024];
        FSRefMakePath(&foundRef, path, sizeof(path));
        applicationSupportFolder = [NSString stringWithUTF8String:(char *)path];
        applicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"CocoaCEDICT"];
    }
    return applicationSupportFolder;
}

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
	//if ([coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    } else {
        [[NSApplication sharedApplication] presentError:error];
    }    
    [coordinator release];
    
    return managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

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

@end
