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
    NSString *t;
    NSOpenPanel * sp = [NSOpenPanel openPanel];
    [sp setCanChooseDirectories:YES];
    [sp setCanCreateDirectories:YES];
	[sp setTitle:@"Save SubObjects"];
    int i=0, status = [sp runModal];
    
	if(status==NSFileHandlingPanelOKButton){
        
        for(QuinceObject * q in [mum valueForKey:@"subObjects"]){
            
            t = [NSString stringWithFormat:@"%@/%@_%d.xml", [[sp URL]path], [mum valueForKey:@"name"], ++i]; 
            
            if(![[q xmlDictionary] writeToFile:t  atomically:YES]){
                
                [document presentAlertWithText:[NSString stringWithFormat:@"ExportSubObjects: could not write file: %@", t]];
                break;
            }
        }
	}
    
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}
@end
