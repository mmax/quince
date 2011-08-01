//
//  ExtractFrequencyVertexes.h
//  quince
//
//  Created by max on 8/1/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.
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
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/QuinceObjectController.h>
#import <QuinceApi/QuinceDocument.h>

@interface ExtractFrequencyVertexes : Function {
@private
    
}
-(BOOL)checkObjects;
-(BOOL)glissandoInQuince:(QuinceObject *)q;
-(void)addVertex:(QuinceObject *)q toResult:(QuinceObject *)r;
-(int)getDirectionForQuince:(QuinceObject *)a and:(QuinceObject *)b;
@end
