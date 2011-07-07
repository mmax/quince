//
//  FunctionLoader.m
//  quince
//
//  Created by max on 4/24/10.
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

#import "FunctionLoader.h"
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceDocument.h>

@implementation FunctionLoader

-(FunctionLoader *)init{

	if((self = [super init])){
		dictionary = [[NSMutableDictionary alloc]init];
	}
	return self;
}

-(void)dealloc{

	[dictionary release];
	[super dealloc];
}

-(void)awake{
	
	Function * fun = [document getSingleSelectedFunction];

	[self awakeWithFunction:fun];
}


-(void)awakeWithFunction:(Function *)fun{
	
	if(![fun needsInput]){
		[fun reset];
		[fun perform];
		return;
	}

	[fun reset];
	[self setValue:[fun inputDescriptors] forKey:@"inputDescriptors"];
	//NSLog(@"functionLoader: awakeWithFunction: name: %@", [fun valueForKey:@"name"]);

	//NSLog(@"functionLoader: awakeWithFunction: self_inputDescriptors: %@", [self valueForKey:@"inputDescriptors"]);
	[self setValue:fun forKey:@"function"];
	[functionLoaderArrayController setContent:[self valueForKey:@"inputDescriptors"]];
	[self statusCheck];
#ifdef	MAC_OS_X_VERSION_10_6
	[panel setStyleMask:NSBorderlessWindowMask];
#endif
	[panel makeKeyAndOrderFront:nil];

}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
	[sheet orderOut:self];
}

-(void)setValue:(id)value forKey:(NSString *)key{
	[dictionary setValue:value forKey:key];
}

-(id)valueForKey:(NSString *)key{
//    NSLog(@"FunctionLoader valueForKey:%@",key);
	return [dictionary valueForKey:key];
}

-(IBAction) clear:(id)sender{
	//NSLog(@"FunctionLoader:clear:...");
	for(NSMutableDictionary * inputDict in [self valueForKey:@"inputDescriptors"])
		[inputDict removeObjectForKey:@"object"];
	[self statusCheck];
}

-(IBAction) load:(id)sender{
	QuinceObject * quince = [[document getSingleSelectedObjectController]content];
	NSMutableDictionary * objectDict =  [[functionLoaderArrayController selectedObjects]lastObject];
	if([quince isOfType:[objectDict valueForKey:@"type"]])
		[objectDict setValue:quince forKey:@"object"];
	else 
		[document presentAlertWithText:[NSString stringWithFormat:@"wrong type: %@ for slot", [quince valueForKey:@"type"]]];
	
	[self statusCheck];
}

-(IBAction) cancel:(id)sender{
	[panel orderOut:nil];
}

-(IBAction) action:(id)sender{
	Function * fun = [self valueForKey:@"function"];
	[panel orderOut:nil];
	[fun performActionWithInputDescriptors:[self valueForKey:@"inputDescriptors"]];
}

-(BOOL)readyForAction{

	for(NSDictionary * inputDict in [self valueForKey:@"inputDescriptors"]){	
		if (![inputDict valueForKey:@"object"])
			return NO;	// if any entry does not have a valid object, we're not ready
	}
	return YES;
}

-(void)statusCheck{

	[actionButton setEnabled:[self readyForAction]];
}

-(IBAction)functionPoolSelectionChanged:(id)sender{
    [document functionPoolSelectionChanged:sender];
}

@end