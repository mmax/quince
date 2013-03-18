//
//  MapDynamicExpr.m
//  quince
//
//  Created by max on 9/2/10.
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

#import "MapDynamicExpr.h"


@implementation MapDynamicExpr


-(MapDynamicExpr *)init{

	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"MapDynamicExprWindow" owner:self];
	}
	return self;

}

-(void)perform{
	
	[window makeKeyAndOrderFront:nil];
}


-(IBAction)map:(id)sender{
	QuinceObject* mom = [self objectForPurpose:@"source"];
	NSArray * subs = [mom valueForKey:@"subObjects"];
	
	activeFields = [[[NSMutableArray alloc]init]autorelease];
	activeBoxes = [[[NSMutableArray alloc]init]autorelease];
	NSArray * fields = [NSArray arrayWithObjects:ffffField, fffField, ffField, fField, mfField, mpField, pField, ppField, pppField, ppppField, nil];
	NSArray * boxes = [NSArray arrayWithObjects:ffffCheckBox, fffCheckBox, ffCheckBox, fCheckBox, mfCheckBox, mpCheckBox, pCheckBox, ppCheckBox, pppCheckBox, ppppCheckBox, nil];

	for(int i = 0;i< [boxes count];i++){
		NSButton * b = [boxes objectAtIndex:i];
		if([b state]==NSOnState){
			[activeFields addObject:[fields objectAtIndex:i]];
			[activeBoxes addObject:[boxes objectAtIndex:i]];
		}
	}
	
	for(QuinceObject * q in subs)
		[self mapQuince:q];

	[window orderOut:nil];
	[self done];

}

-(void)mapQuince:(QuinceObject *)q{

	double vol = [[q valueForKey:@"volume"]doubleValue];
	
	for(int i=0;i<[activeFields count];i++){
	
		if (vol > [[activeFields objectAtIndex:i]floatValue]) {
			
			NSString * s = [[activeBoxes objectAtIndex:i]title];
			[q setValue:[NSString stringWithString:s] forKey:@"dynExpr"];
			return;
		}
	}
	if([pppppCheckBox state] == NSOnState)
		[q setValue:@"ppppp" forKey:@"dynExpr"];
}

-(IBAction)cancel:(id)sender{
	[window orderOut:nil];
	[self done];
}

-(IBAction)all:(id)sender{

	[ffffCheckBox setState:NSOnState];
	[fffCheckBox setState:NSOnState];
	[ffCheckBox setState:NSOnState];
	[fCheckBox setState:NSOnState];
	[mfCheckBox setState:NSOnState];
	[mpCheckBox setState:NSOnState];
	[pCheckBox setState:NSOnState];
	[ppCheckBox setState:NSOnState];
	[pppCheckBox setState:NSOnState];
	[ppppCheckBox setState:NSOnState];
	[pppppCheckBox setState:NSOnState];
}

-(IBAction)none:(id)sender{
	
	[ffffCheckBox setState:NSOffState];
	[fffCheckBox setState:NSOffState];
	[ffCheckBox setState:NSOffState];
	[fCheckBox setState:NSOffState];
	[mfCheckBox setState:NSOffState];
	[mpCheckBox setState:NSOffState];
	[pCheckBox setState:NSOffState];
	[ppCheckBox setState:NSOffState];
	[pppCheckBox setState:NSOffState];
	[ppppCheckBox setState:NSOffState];
	[pppppCheckBox setState:NSOffState];
	
}

-(IBAction)changeDistribution:(id)sender{
	
	NSArray * fields = [NSArray arrayWithObjects:ffffField, fffField, ffField, fField, mfField, mpField, pField, ppField, pppField, ppppField, nil];
	
	float delta = [slider floatValue], offset = [offsetSlider floatValue];
	for(int i = 0; i<[fields count];i++){
		NSTextField * f = [fields objectAtIndex:i];
		[f setFloatValue:0-(delta*(i+1))+offset];
	}
}

-(BOOL)hasInterface{return YES;}

@end
