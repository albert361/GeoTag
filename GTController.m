//
//  GTController.m
//  GeoTag
//
//  Created by Marco S Hyman on 6/14/09.
//

#import "GTController.h"
#import "ImageInfo.h"
#import "GTDefaultscontroller.h"

@interface GTController ()
- (BOOL) isDuplicatePath: (NSString *) path;
@end


@implementation GTController

#pragma mark -
#pragma mark Startup and teardown

- (id) init
{
    if ((self = [super init])) {
	images = [[NSMutableArray alloc] init];

	// force app defaults and preferences initialization
	[GTDefaultsController class];
    }
    return self;
}

- (void) awakeFromNib
{
    [tableView registerForDraggedTypes:
     [NSArray arrayWithObject: NSFilenamesPboardType]];
}

/*
 * This controller is set as the window deligate in IB so it will be
 * notified when the window is closing, letting it terminate the
 * app.
 */
- (void) windowWillClose: (NSNotification *) aNotification
{
    (void) aNotification;   
    [NSApp terminate: self];
}

#pragma mark -
#pragma mark IB Actions

/*
 * open the preference window
 */
- (IBAction) showPreferencePanel: (id) sender
{
    [[GTDefaultsController sharedPrefsWindowController] showWindow:nil];
    (void)sender;
}

/*
 * Let the user select images or directories of images from an
 * open dialog box.  Don't allow duplicate paths.
 */
- (IBAction) showOpenPanel: (id) sender
{
    BOOL reloadNeeded = NO;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection: YES];
    [panel setCanChooseFiles: YES];
    [panel setCanChooseDirectories: YES];
    NSInteger result = [panel runModalForDirectory: nil file: nil types: nil];
    if (result == NSOKButton) {
	NSArray *filenames = [panel filenames];
	for (NSString *path in filenames) {
	    if (! [self isDuplicatePath: path]) {
		[images addObject: [ImageInfo imageInfoWithPath: path]];
		reloadNeeded = YES;
	    }
	}
	if (reloadNeeded)
	    [tableView reloadData];
    }
    (void) sender;
}

#pragma mark -
#pragma mark tableView datasource functions

- (NSInteger) numberOfRowsInTableView: (NSTableView *) tv
{
    (void) tv;
    return [images count];
}

- (id) tableView: (NSTableView *) tv
objectValueForTableColumn: (NSTableColumn *) tableColumn
	     row: (NSInteger) row
{
    (void) tv;
    ImageInfo *imageInfo = [images objectAtIndex: row];
    SEL selector = NSSelectorFromString([tableColumn identifier]);
    return [imageInfo performSelector: selector];
}

// !!!: currently all drops happen at the end of the table.

- (NSDragOperation) tableView: (NSTableView *) aTableView
		 validateDrop: (id < NSDraggingInfo >) info
		  proposedRow: (NSInteger) row
	proposedDropOperation: (NSTableViewDropOperation) op
{
    BOOL dropValid = YES;

    NSPasteboard* pboard = [info draggingPasteboard];
    if ([[pboard types] containsObject: NSFilenamesPboardType]) {
	NSArray *pathArray = [pboard propertyListForType:NSFilenamesPboardType];
	for (NSString *path in pathArray)
	    if ([self isDuplicatePath: path])
		dropValid = NO;
    }
    if (dropValid)
	return NSDragOperationLink;

    return NSDragOperationNone;
    (void) aTableView;
    (void) row;
    (void) op;
}


- (BOOL) tableView: (NSTableView *) aTableView
	acceptDrop: (id <NSDraggingInfo>) info
	       row: (NSInteger) row
     dropOperation: (NSTableViewDropOperation) op 
{
    BOOL dropAccepted = NO;
    NSPasteboard* pboard = [info draggingPasteboard];
    if ([[pboard types] containsObject: NSFilenamesPboardType]) {
	NSArray *pathArray = [pboard propertyListForType:NSFilenamesPboardType];
	for (NSString *path in pathArray) {
	    if (! [self isDuplicatePath: path]) {
		[images addObject: [ImageInfo imageInfoWithPath: path]];
		dropAccepted = YES;
	    }
	}
    }
    if (dropAccepted)
	[tableView reloadData];

    return dropAccepted;

    (void) aTableView;
    (void) row;
    (void) op;
} 


#pragma mark -
#pragma mark tableView delegate functions

- (void) tableView: (NSTableView *) aTableView
   willDisplayCell: (id) aCell
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
    if ([aCell respondsToSelector:@selector(setTextColor:)]) {
	ImageInfo *anImage = [images objectAtIndex: rowIndex];
	NSColor *textColor;

	if ([anImage validImage]) {
	    if ([[anImage latitude] length] > 0)
		textColor = [NSColor greenColor];
	    else
		textColor = [NSColor blackColor];
	} else
	    textColor = [NSColor grayColor];
    
	[aCell setTextColor: textColor];
    }

    (void) aTableView;
    (void) aTableColumn;
}

- (BOOL) tableView: (NSTableView *) aTableView
   shouldSelectRow: (NSInteger) rowIndex
{
    return [[images objectAtIndex: rowIndex] validImage];
    (void) aTableView;
}

- (void) tableViewSelectionDidChange: (NSNotification *)notification
{
    (void) notification;
    NSInteger row = [tableView selectedRow];
    if (row == -1)
	return;
    NSLog(@"table view row %d selected", row);
    ;;;
}

#pragma mark -
#pragma mark helper methods

- (BOOL) isDuplicatePath: (NSString *) path
{
    for (ImageInfo *image in images) {
	if ([[image path] isEqualToString: path]) {
	    NSLog(@"duplicatePath: %@", path);
	    return YES;
	}
    }
    return NO;
}
@end
