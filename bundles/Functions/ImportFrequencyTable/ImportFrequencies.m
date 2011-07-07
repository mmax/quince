//
//  ImportFrequencyTable.m
//  quince
//
//  Created by max on 6/16/10.
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

#import "ImportFrequencies.h"


@implementation ImportFrequencies


-(void)perform{

	DataFile * df = [document openNewDataFile];
	int format = [self getFormatOfFile:df];
	//NSLog(@"format: %d", format);
	switch (format) {
		case kDataFileFormatPraat:
			[self parsePraatFile:df];
			break;
		case kDataFileFormatSpear:
			[self parseSpearFile:df];
			break;
		default:
			[document presentAlertWithText:@"unknown file format"];
			return;
	}
	[document displayProgress:NO];
}

-(int)getFormatOfFile:(DataFile *)file{
	
	NSString * fileContents = [NSString stringWithContentsOfFile:[file filePath] encoding:NSASCIIStringEncoding error:nil];
	NSArray * lines = [fileContents componentsSeparatedByString:@"\n"];
	int format;
	if ([[lines objectAtIndex:0]isEqualToString:@"par-text-frame-format"])
		format = kDataFileFormatSpear;
	else if ([[lines objectAtIndex:0]isEqualToString:@"File type = \"ooTextFile\""])
		format = kDataFileFormatPraat;
	else 
		format = -1;
	return format;
	
}

-(BOOL)needsInput{return NO;} 

-(void)parsePraatFile:(DataFile *)file{	//VERY OLD CODE FROM MTC
	//NSLog(@" parse praat...");
	QuinceObject * mother = [self outputObjectOfType:@"QuinceObject"];

	NSString * fileContents = [NSString stringWithContentsOfFile:[file filePath] encoding:NSASCIIStringEncoding error:nil];
	//NSArray * lines = [fileContents componentsSeparatedByString:@"\n"];
	int i, f, nFormants;
	double praatFormantsDeltaX, praatFormantsOffsetX, intensity, freq;
	int praatFormantsMaxFormants;
	//NSString * fileContents = [NSString stringWithContentsOfFile:[file filePath] encoding:NSASCIIStringEncoding error:nil];

		
	NSMutableArray * frames = [[NSMutableArray alloc] init];
   [frames addObjectsFromArray:[fileContents componentsSeparatedByString:@"frame"]];
							   
	NSString * temp = [frames objectAtIndex:0];
	NSScanner * scanner = [NSScanner scannerWithString: fileContents];
	//NSMutableArray * tempFrame;	
	//NSMutableArray * praatFormants = [[[NSMutableArray alloc]init]autorelease];
	[scanner scanUpToString:@"dx = " intoString:nil];
	[scanner scanString:@"dx = " intoString:nil];
	if(![scanner scanDouble:&praatFormantsDeltaX]) {
		NSLog(@"scannig for deltaX not successfull...\n");
		[document displayProgress:NO];
		[document presentError:[NSError errorWithDomain:@" Reading File:\nWrong File Format\nexpecting praat formant file" code:0 userInfo:nil]];
		return;
	}
	
	[scanner scanUpToString:@"x1 = " intoString:nil];
	[scanner scanString:@"x1 = " intoString:nil];
	if(![scanner scanDouble:&praatFormantsOffsetX]) {
		NSLog(@"scannig for offsetX not successfull...\n");
		return;
	}
	
	[scanner scanUpToString:@"maxnFormants = " intoString:&temp];
	[scanner scanString:@"maxnFormants = " intoString:nil];
	
	if(![scanner scanInt:&praatFormantsMaxFormants]) {
		NSLog(@"scanning for maxFormants not successfull...\n");
		return;
	}
	for(i=0;i<praatFormantsMaxFormants;i++){
		
		QuinceObject * s = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
		NSString * name = [NSString stringWithFormat:@"formant_%d", i+1];
		[s setValue:name forKey:@"name"];
		[[mother controller]addSubObjectWithController:[s controller] withUpdate:NO];
	}
	[[mother controller]update];
	
	[frames removeObjectAtIndex:0];
	[frames removeObjectAtIndex:0];// first two elements don't contain formant frames...
	//[controller displayProgress:NO];
	
	[document setProgressTask:@"Reading Praat Formant Data..."];
	[document displayProgress:YES];
	
	for(i=0;i<[frames count];i++) {
		
		temp = [frames objectAtIndex:i];
		[scanner initWithString: temp];
		[scanner scanUpToString:@"intensity = " intoString:nil];
		[scanner scanString:@"intensity = " intoString:nil];
		if(![scanner scanDouble:&intensity]){
			//printf("scanning for nFormants in formant frame  %d not successfull...\n", i);
			return;
		}
		
		[scanner scanUpToString:@"nFormants = " intoString:nil];
		[scanner scanString:@"nFormants = " intoString:nil];
		if(![scanner scanInt:&nFormants]) {
			//printf("scanning for nFormants in formant frame  %d not successfull...\n", i);
			return;
		}
		
		if(nFormants == 0) intensity = 0;
		
		//[praatFormantIntensities addObject:[NSNumber numberWithDouble:intensity]];
		
		//tempFrame = [[[NSMutableArray alloc] init]autorelease];	
		//NSMutableArray * frameIntensity= [[[NSMutableArray alloc] init]autorelease];	
		for(f=0;f<nFormants;f++) {
			[scanner scanUpToString:@"frequency = " intoString:nil];
			[scanner scanString:@"frequency = " intoString:nil];
			if(![scanner scanDouble:&freq]) {
				//printf("scanning for frequency of formant %d in frame %d not successfull...\n", f,i);
				return;
			}
			
			double start = praatFormantsOffsetX + (praatFormantsDeltaX * i);
			//NSLog(@"adding object");
			QuinceObject * m = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
			[m setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
			[m setValue:[NSNumber numberWithDouble:praatFormantsDeltaX] forKey:@"duration"];
			[m setValue:[NSNumber numberWithDouble:freq] forKey:@"frequency"];
			if(intensity==0)
				[m setValue:[NSNumber numberWithDouble:-150] forKey:@"volume"];
			else
				[m setValue:[NSNumber numberWithDouble:20.0*log10(intensity)] forKey:@"volume"];
			
			QuinceObject * group = [[mother valueForKey:@"subObjects"]objectAtIndex:f];
			[[group controller]addSubObjectWithController:[m controller] withUpdate:NO];
			
			//[tempFrame addObject:[NSNumber numberWithDouble:freq]];
			//[frameIntensity addObject:[NSNumber numberWithDouble:intensity]];
		}
		//[praatFormants addObject:tempFrame];
		//[praatFormantIntensities addObject:frameIntensity];
		[document setProgress:100/(float)[frames count]*i];
	}
	
	for(QuinceObject * m in [mother valueForKey:@"subObjects"])
		[[m controller]update];
	
	NSString * mn = [[NSString alloc]initWithFormat:@"%@_Seq", [[file filePath]lastPathComponent]];
	[mother setValue:mn forKey:@"name"];
	
	//NSLog(@"%@",praatFormants);
	//NSLog(@"intensities: %@", praatFormantIntensities);
}

-(void)parseSpearFile:(DataFile *)file{
	
	//NSLog(@" parse spear...");
	NSString * fileContents = [NSString stringWithContentsOfFile:[file filePath] encoding:NSASCIIStringEncoding error:nil];
	NSArray * lines = [fileContents componentsSeparatedByString:@"\n"];
	int i, bin, binCount=0, maxBinCount = -1, index;
	double spearFramesOffsetX, spearFramesDeltaX, freq, amp, start;
	QuinceObject * mother = [self outputObjectOfType:@"QuinceObject"];
	NSScanner * scanner = [NSScanner scannerWithString:[lines objectAtIndex:5]];
	
	if(![scanner scanDouble:&spearFramesOffsetX]) {
		NSLog(@"%@: scanning: ERROR - BAD!", [self className]);
		return;
	}
	[document setProgressTask:@"parsing spear text file..."];
	[document displayProgress:YES];

	scanner = [NSScanner scannerWithString:[lines objectAtIndex:6]];
	[scanner scanDouble: &spearFramesDeltaX];
	spearFramesDeltaX -= spearFramesOffsetX;
	
	//NSLog(@"parseSpearFile: lines: %d", [lines count]);

	for(i=5;i<[lines count]-1;i++){//-1 weil sonst der letzte frame doppelt ist (???)
		
		[document setProgress:(100.0/[lines count])*i];
		scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];
	
		
		if(![scanner scanDouble:&freq]){
			NSLog(@"parseSpearFile: ERROR: parsing time (first number in line), line# %d", i+1);
		}	
		
		if(![scanner scanInt:&binCount]){
			NSLog(@"parseSpearFile: ERROR: no binCount, line# %d", i+1);
		}
		
		if(binCount>maxBinCount)maxBinCount=binCount;
		
		for(bin=0;bin<binCount;bin++){
			
			if(![scanner scanInt:&index])
				NSLog(@"parseSpearFile: ERROR: parsing index, line# %d", i+1);
			if(![scanner scanDouble:&freq])
				NSLog(@"parseSpearFile: ERROR: parsing freq, line# %d", i+1);
			if(![scanner scanDouble:&amp])
				NSLog(@"parseSpearFile: ERROR: parsing amp, line# %d", i+1);
	
			// add new object
			start = spearFramesOffsetX + ((i-5)*spearFramesDeltaX);
			//NSLog(@"adding object: line #: %d for index: %d : start: %f", i+1, index, start);
			QuinceObject * m = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
			[m setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
			[m setValue:[NSNumber numberWithDouble:spearFramesDeltaX] forKey:@"duration"];
			[m setValue:[NSNumber numberWithDouble:freq] forKey:@"frequency"];
			if(amp==0)
				[m setValue:[NSNumber numberWithDouble:-150] forKey:@"volume"];
			else
				[m setValue:[NSNumber numberWithDouble:20.0*log10(amp)] forKey:@"volume"];
			[[mother controller]addSubObjectWithController:[m controller] withUpdate:NO];
			
		}		
	}
	[[mother controller]update];
	[self done];
}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"purpose"];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"type"];
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}

@end
