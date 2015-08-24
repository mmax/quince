//
//  ExportParameterListing.m
//  quince
//
//  Created by Maximilian Marcoll on 6/27/14.
//  Copyright (c) 2014 Maximilian Marcoll. All rights reserved.
//

#import "ExportParameterListing.h"

@implementation ExportParameterListing

-(ExportParameterListing *)init{
	
	if((self = [super init])){
		[NSBundle loadNibNamed:@"EPL_Win" owner:self];
	}
	return self;
}


-(void)perform{
    
    if(!window){
        NSLog(@"No Window! :o(");
    }
	[pop removeAllItems];
	QuinceObject * source = [self objectForPurpose:@"source"];
	NSArray * keys = [source allKeysRecursively];
	for(NSString * s in keys)
		[pop addItemWithTitle:s];
	
	[window makeKeyAndOrderFront:nil];
}


-(NSString *)generateListing{
    
	QuinceObject * quince = [self objectForPurpose:@"source"];
    NSString * pam = [pop titleOfSelectedItem];
	NSArray * subs = [quince valueForKey:@"subObjects"];
	
    
	NSMutableString * list = [[NSMutableString alloc]init];
    NSString * s;
	for(QuinceObject * q in subs){
        s = [self getStringValueOf:[q valueForKey:pam]];
		[list appendFormat:@"%@\n", s];
	}

	return [list autorelease];
	
}

-(NSString *)getStringValueOf:(id)value{
    
	if([value isKindOfClass:NSClassFromString(@"NSString")]) return value;
	if ([value isKindOfClass:NSClassFromString(@"NSNumber")]) return [value stringValue]; 
    //	NSLog(@"hier? : %@", [value description]);
	return [value description];
}

-(IBAction)exportParameter:(id)sender{
	
    NSSavePanel * sp = [NSSavePanel savePanel];
    NSArray * types = [NSArray arrayWithObject:@"txt"];
    [sp setAllowedFileTypes:types];
	[sp setTitle:@"Save Parameter Listing"];
    #ifdef MAC_OS_X_VERSION_10_6
        [sp setNameFieldStringValue:@"filenamedoesntmatter.txt"];
    #endif
    
	
	int status = [sp runModal];
	NSError * error;
    
	if(status==NSFileHandlingPanelOKButton){
		//NSString * path = [[sp URL]path];
        
		NSString * list = [self generateListing];
		if(![list writeToURL:[sp URL] atomically:NO encoding:NSASCIIStringEncoding error:&error])
			[document presentAlertWithText:[NSString stringWithFormat:@"ExportDescriptionListing: save operation failed"]];
    }
    [self cancel:nil];
}

-(IBAction) cancel:(id)sender{
	
	[window orderOut:nil];
    [self done];
}

-(BOOL)hasInterface{return YES;}


@end
