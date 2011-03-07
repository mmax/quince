//
//  StripLayerControlerArrayController.m
//  quince
//
//  Created by max on 6/9/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//
//
//	If you have any questions contact quince@maximilianmarcoll.de
//
//	This file is part of quince.
//
//	quince is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	quince is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with quince.  If not, see <http://www.gnu.org/licenses/>.
//



#import "StripLayerControlsArrayController.h"
#import "StripController.h"




NSString * MovedRowsType = @"quince_MOVED_ROWS_TYPE";

@implementation StripLayerControlsArrayController

- (id) initWithViewColumn:(NSTableColumn *) vCol{
    if ((self = [super init]) != nil){
        subviewTableColumn = vCol;
        subviewTableView = [subviewTableColumn tableView];
		
		[subviewTableView registerForDraggedTypes: [NSArray arrayWithObjects:MovedRowsType, NSURLPboardType, nil]];
		[subviewTableColumn setDataCell: [[[SubviewTableViewCell alloc] init] autorelease]];
		[subviewTableView setAllowsMultipleSelection:NO];
		
        [subviewTableView setDataSource: self];
        [subviewTableView setDelegate: self];
    }
    return self;
}

- (void) dealloc{
    subviewTableView = nil;
    subviewTableColumn = nil;
    delegate = nil;
    [super dealloc];
}

+ (id) controllerWithViewColumn:(NSTableColumn *) vCol{
    return [[[self alloc] initWithViewColumn: vCol] autorelease];
}

- (void) setDelegate:(id) obj{
    // Check that the object passed to this method supports the required methods
   // NSParameterAssert([obj conformsToProtocol: @protocol(SubviewTableViewControllerDataSourceProtocol)]);
    
    // Weak reference
    delegate = obj;
}

- (StripController *) delegate{
    return delegate;
}

- (void) reloadTableView{
     while ([[subviewTableView subviews] count] > 0)
	   	   [[[subviewTableView subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    
    [subviewTableView reloadData];
}

- (BOOL) isValidDelegateForSelector:(SEL) command{
    return (([self delegate] != nil) && [[self delegate] respondsToSelector: command]);
}

- (void) tableView:(NSTableView *) tableView didClickTableColumn:(NSTableColumn *) tableColumn{
    if ([self isValidDelegateForSelector: _cmd])
		[[self delegate] performSelector: _cmd withObject: tableView withObject: tableColumn];
}

- (void) tableView:(NSTableView *) tableView didDragTableColumn:(NSTableColumn *) tableColumn{
    if ([self isValidDelegateForSelector: _cmd])
		[[self delegate] performSelector: _cmd withObject: tableView withObject: tableColumn];
}

- (void) tableView:(NSTableView *) tableView willDisplayCell:(id) cell forTableColumn:(NSTableColumn *) tableColumn row:(int) row{
	if (tableColumn == subviewTableColumn){
		if ([self isValidDelegateForSelector: @selector(tableView:viewForRow:)])
			[(SubviewTableViewCell *)cell addSubview: [[self delegate] tableView: tableView viewForRow: row]];
	}
	else{
		if ([self isValidDelegateForSelector: _cmd]){
				//[[self delegate] tableView: tableView willDisplayCell: cell forTableColumn: tableColumn row: row];
				NSLog(@"StripLayerControlsArrayControler:tableView:(NSTableView *) tableView willDisplayCell:(id) cell forTableColumn:(NSTableColumn *) tableColumn row:(int) row : ;o(");
			}
	} 
}
 
- (void) tableViewColumnDidMove:(NSNotification *) notification{
    if ([self isValidDelegateForSelector: _cmd])
		[[self delegate] performSelector: _cmd withObject: notification];
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification{

    if ([self isValidDelegateForSelector: _cmd])
		[[self delegate] performSelector: _cmd withObject: notification];
}

- (void) tableViewSelectionIsChanging:(NSNotification *) notification{
    if ([self isValidDelegateForSelector: _cmd])
		[[self delegate] performSelector: _cmd withObject: notification];
}

 - (int) numberOfRowsInTableView:(NSTableView *) tableView{
	int count = 0;
	if ([self isValidDelegateForSelector: _cmd])
		count = [delegate numberOfRowsInTableView: tableView];
	
	return count;
} 

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation{

	if (row < 0)
		row = 0;
	
	// if drag source is self, it's a move unless the Option key is pressed
	if ([info draggingSource] == subviewTableView) {
		NSData *rowsData = [[info draggingPasteboard] dataForType:MovedRowsType];
		NSIndexSet *indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
		NSIndexSet *destinationIndexes = [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
		// set selected rows to those that were just moved
		[self setSelectionIndexes:destinationIndexes];		
		return YES;
	}
    return NO;
}

 - (id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(NSInteger) row{

	 id obj = nil;
	if ((tableColumn != subviewTableColumn) && [self isValidDelegateForSelector: _cmd])
		obj = [[self delegate] tableView: tableView objectValueForTableColumn: tableColumn row: row];	
	return obj;
}

- (void) tableView:(NSTableView *) tableView setObjectValue:(id) obj forTableColumn:(NSTableColumn *) tableColumn row:(int) row{
	if ((tableColumn != subviewTableColumn) && [self isValidDelegateForSelector: _cmd])
		NSLog(@"tableView:(NSTableView *) tableView setObjectValue:(id) obj forTableColumn:(NSTableColumn *) tableColumn row:(int) row");//[delegate tableView: tableView setObjectValue: obj forTableColumn: tableColumn row: row];
} 

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation{

    NSDragOperation dragOp = NSDragOperationNone;
    
	// if drag source is self, it's a move unless the Option key is pressed
	if ([info draggingSource] == subviewTableView)
		dragOp =  NSDragOperationMove;
	
	// we want to put the object at, not over,
	// the current row (contrast NSTableViewDropOn) 
	[tv setDropRow:row dropOperation:NSTableViewDropAbove]; 	
    return dragOp;
}


- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:MovedRowsType] owner:self];
    [pboard setData:data forType:MovedRowsType];
    return YES;
}

-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet toIndex:(unsigned int)insertIndex {	
	// If any of the removed objects come before the insertion index,
	// we need to decrement the index appropriately
	
	unsigned int adjustedInsertIndex =
	insertIndex - [fromIndexSet countOfIndexesInRange:(NSRange){0, insertIndex}];
	NSRange destinationRange = NSMakeRange(adjustedInsertIndex, [fromIndexSet count]);
	NSIndexSet *destinationIndexes = [NSIndexSet indexSetWithIndexesInRange:destinationRange];
	NSArray *objectsToMove = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
	[self removeObjectsAtArrangedObjectIndexes:fromIndexSet];	
	[self insertObjects:objectsToMove atArrangedObjectIndexes:destinationIndexes];
	return destinationIndexes;
}

@end



/*
 Implementation of NSIndexSet utility category
 */
/* @implementation NSIndexSet (CountOfIndexesInRange)

-(unsigned int)countOfIndexesInRange:(NSRange)range
{
	unsigned int start, end, count;
	
	if ((start == 0) && (range.length == 0))
	{
		return 0;	
	}
	
	start	= range.location;
	end		= start + range.length;
	count	= 0;
	
	unsigned int currentIndex = [self indexGreaterThanOrEqualToIndex:start];
	
	while ((currentIndex != NSNotFound) && (currentIndex < end))
	{
		count++;
		currentIndex = [self indexGreaterThanIndex:currentIndex];
	}
	
	return count;
}
@end



 
 */