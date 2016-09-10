//
//  CopyValues.m
//  quince
//
//  Created by Maximilian Marcoll on 2/10/14.
//  Copyright (c) 2014 Maximilian Marcoll. All rights reserved.
//

#import "CopyValues.h"

@implementation CopyValues



-(CopyValues *)init{
	
	if(self = [super init]){
		
		//[NSBundle loadNibNamed:@"CopyValues" owner:self];
        [[[NSBundle alloc]init]loadNibNamed:@"CopyValues" owner:self topLevelObjects:nil];
	}
	return self;
}


-(BOOL)hasInterface{return YES;}

-(void)perform{
    
	QuinceObject * quince = [self objectForPurpose:@"source"];
	NSArray * keys = [quince allKeys];
	[sourcePopUp removeAllItems];
  	[targetPopUp removeAllItems];
	for(NSString * s in keys){
		[sourcePopUp addItemWithTitle:s];
        [targetPopUp addItemWithTitle:s];
    }
	[window makeKeyAndOrderFront:nil];
}

-(IBAction)go:(id)sender{

    NSString * sourceKey = [sourcePopUp titleOfSelectedItem];
    NSString * targetKey = [targetPopUp titleOfSelectedItem];
    
    
    for( QuinceObject * q in [[self objectForPurpose:@"source"]valueForKey:@"subObjects"])
        [q setValue:[[q valueForKey:sourceKey]copy] forKey:targetKey];
    
    [self cancel:self];
}

-(IBAction)cancel:(id)sender{

    [window orderOut:nil];
    [self done];
}

@end
