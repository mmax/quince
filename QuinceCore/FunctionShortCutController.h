//
//  FunctionShortCutController.h
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


#import <Foundation/Foundation.h>

@interface FunctionShortCutController : NSObject {
    
    
    IBOutlet NSPanel * window;
    IBOutlet NSPopUpButton * q;
    IBOutlet NSPopUpButton * w;
    IBOutlet NSPopUpButton * e;
    IBOutlet NSPopUpButton * r;
    IBOutlet NSPopUpButton * t;
    IBOutlet NSPopUpButton * z;
    IBOutlet NSPopUpButton * u;
    IBOutlet NSPopUpButton * i;
    IBOutlet NSPopUpButton * o;
    IBOutlet NSPopUpButton * p;
    
    NSMutableDictionary * dict;
}



-(void)addFunctionWithName:(NSString *)name;
-(IBAction)done:(id)sender;
-(void)awake;
-(NSString *)functionNameForKey:(NSString *)s;
-(void)storeValues;
-(NSDictionary *)dictionary;
-(void)setConnectionsWithDict:(NSDictionary *)d;
@end
