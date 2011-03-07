//
//  StripLayerControlerArrayController.h
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


//#import <QuinceApi/QuinceDocument.h>
#import "SubviewTableViewCell.h"
#import "StripController.h"

@class StripController;

@interface StripLayerControlsArrayController : NSArrayController{ //<NSTableViewDataSource, NSTableViewDelegate>{
	
	NSTableView * subviewTableView;
	NSTableColumn *subviewTableColumn;
	StripController* delegate;
}

// Convenience factory method
+ (id) controllerWithViewColumn:(NSTableColumn *) vCol;

// The delegate is required to conform to the SubviewTableViewControllerDataSourceProtocol
- (void) setDelegate:(id) obj;
- (StripController*) delegate;

// The method to call instead of the standard "reloadData" method of NSTableView.
// You need to call this method at any time that you would have called reloadData
// on a table view.
- (void) reloadTableView;
- (BOOL) isValidDelegateForSelector:(SEL) command;
- (void) tableView:(NSTableView *) tableView didClickTableColumn:(NSTableColumn *) tableColumn;
- (void) tableView:(NSTableView *) tableView didDragTableColumn:(NSTableColumn *) tableColumn;
- (void) tableView:(NSTableView *) tableView willDisplayCell:(id) cell forTableColumn:(NSTableColumn *) tableColumn row:(int) row;
- (void) tableViewColumnDidMove:(NSNotification *) notification;
- (void) tableViewSelectionDidChange:(NSNotification *) notification;
- (void) tableViewSelectionIsChanging:(NSNotification *) notification;
- (int) numberOfRowsInTableView:(NSTableView *) tableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void) tableView:(NSTableView *) tableView setObjectValue:(id) obj forTableColumn:(NSTableColumn *) tableColumn row:(int) row;
-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet toIndex:(unsigned int)insertIndex;
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation;
- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;

@end






