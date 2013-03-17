//
//  FunctionShortCutController.m
//  quince
//
//  Created by Maximilian Marcoll on 3/17/13.
//  Copyright (c) 2013 Maximilian Marcoll. All rights reserved.
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


#import "FunctionShortCutController.h"

@implementation FunctionShortCutController


-(FunctionShortCutController *)init{
    
    if (self = [super init]) {
        
        dict = [[NSMutableDictionary alloc ]init];
    }
    return self;
}

-(void)dealloc{
    
    [dict removeAllObjects];
    [dict release];
    [super dealloc];
}

-(void)addFunctionWithName:(NSString *)name{
    
    if(!name)return;
    
    [q addItemWithTitle:name];
    [w addItemWithTitle:name];
    [e addItemWithTitle:name];
    [r addItemWithTitle:name];
    [t addItemWithTitle:name];
    [z addItemWithTitle:name];
    [u addItemWithTitle:name];
    [i addItemWithTitle:name];
    [o addItemWithTitle:name];
    [p addItemWithTitle:name];
    
}

-(IBAction)done:(id)sender{
    [self storeValues];
    [window orderOut:nil];
}

-(void)storeValues{
    
    [dict setValue: [q titleOfSelectedItem] forKey:@"q"];
    [dict setValue: [w titleOfSelectedItem] forKey:@"w"];
    [dict setValue: [e titleOfSelectedItem] forKey:@"e"];
    [dict setValue: [r titleOfSelectedItem] forKey:@"r"];
    [dict setValue: [t titleOfSelectedItem] forKey:@"t"];
    [dict setValue: [z titleOfSelectedItem] forKey:@"z"];
    [dict setValue: [u titleOfSelectedItem] forKey:@"u"];
    [dict setValue: [i titleOfSelectedItem] forKey:@"i"];
    [dict setValue: [o titleOfSelectedItem] forKey:@"o"];
    [dict setValue: [p titleOfSelectedItem] forKey:@"p"];
}

-(void)awake{
    [window makeKeyAndOrderFront:nil];
}

-(void)setConnectionsWithDict:(NSDictionary *)d{
    if(!d)return;
    
    [q selectItemWithTitle:[d valueForKey:@"q"]];
    [w selectItemWithTitle:[d valueForKey:@"w"]];
    [e selectItemWithTitle:[d valueForKey:@"e"]];
    [r selectItemWithTitle:[d valueForKey:@"r"]];
    [t selectItemWithTitle:[d valueForKey:@"t"]];
    [z selectItemWithTitle:[d valueForKey:@"z"]];
    [u selectItemWithTitle:[d valueForKey:@"u"]];
    [i selectItemWithTitle:[d valueForKey:@"i"]];
    [o selectItemWithTitle:[d valueForKey:@"o"]];
    [p selectItemWithTitle:[d valueForKey:@"p"]];
    [self storeValues];
}

-(NSString *)functionNameForKey:(NSString *)s{

    return [dict valueForKey:s];
}

-(NSDictionary *)dictionary{
    return dict;
}

@end
