//
//  ExportSubObjects.m
//  quince
//
//  Created by Maximilian Marcoll on 1/6/16.
//  Copyright (c) 2016 Maximilian Marcoll. All rights reserved.
//

#import "ExportSubObjects.h"

@implementation ExportSubObjects

-(void)perform{
    
    QuinceObject * mum = [self objectForPurpose:@"source"];
    NSString *t, *n;
    NSOpenPanel * sp = [NSOpenPanel openPanel];
    [sp setCanChooseDirectories:YES];
    [sp setCanCreateDirectories:YES];
	[sp setTitle:@"Save SubObjects"];
    long status = [sp runModal];
    long i=1;
    
	if(status==NSFileHandlingPanelOKButton){
        
        for(QuinceObject * q in [mum valueForKey:@"subObjects"]){
            if([[q valueForKey:@"name"]isEqualToString:@"untitled"])
                n = [NSString stringWithFormat:@"%ld_%@.xml", i, [mum valueForKey:@"name"]];
            else
                n = [NSString stringWithFormat:@"%ld_%@.xml", i, [q valueForKey:@"name"]];
            t = [NSString stringWithFormat:@"%@/%@", [[sp URL]path], n]; 
            
            if(![[q xmlDictionary] writeToFile:t  atomically:YES]){
                
                [document presentAlertWithText:[NSString stringWithFormat:@"ExportSubObjects: could not write file: %@", t]];
                break;
            }
            i++;
        }
	}
    
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}
@end
