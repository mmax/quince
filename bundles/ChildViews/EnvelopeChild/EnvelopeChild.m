//
//  EnvelopeChild.m
//  quince
//
//  Created by max on 3/8/10.
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

#import "EnvelopeChild.h"


@implementation EnvelopeChild

-(int)minimumItemHeight{
	return 1;
}

-(int)minimumItemWidth{
	return 1;
}


-(NSRect)	redrawRect{
	NSRect r = [self rect];
	NSRect ar = NSMakeRect(r.origin.x-1, 0, r.size.width+2, r.origin.y+1);
	return ar;	

}

-(void)		draw{

	NSRect r = [self rect];
	[[NSColor greenColor]set];
	NSRect ar = NSMakeRect(r.origin.x, 1, r.size.width, r.origin.y-1);
	[NSBezierPath strokeRect:ar];
	[NSBezierPath fillRect:ar];
}

-(BOOL)selected{return NO;}

@end
