//
//  SubviewTableViewCell.m
//	quince
//
//  Created by max on 3/12/10
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

#import "SubviewTableViewCell.h"
#import "StripLayerControlsArrayController.h"

@implementation SubviewTableViewCell

- (void) addSubview:(NSView *) view{
    subview = [view retain];
}

- (void) dealloc{
	[subview release];
    [super dealloc];
}

- (NSView *) view{
    return subview;
}

- (void) drawWithFrame:(NSRect) cellFrame inView:(NSView *) controlView{
    [super drawWithFrame: cellFrame inView: controlView];

    [[self view] setFrame: cellFrame];

    if ([[self view] superview] != controlView)
		[controlView addSubview: [self view]];
}

-(void)setPlaceholderString:(NSString *)s{
	NSLog(@"SubviewTableViewCell:setPlaceholderString: %@", s);
}
@end
