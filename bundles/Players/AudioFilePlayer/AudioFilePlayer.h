//
//  AudioFilePlayer.h
//  quince
//
//  Created by max on 5/11/10.
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

#import <Cocoa/Cocoa.h>
#import <QuinceApi/Player.h>
#import <QuinceApi/QuinceDocument.h>


OSStatus playbackCallback(void *inRefCon,
                          AudioUnitRenderActionFlags *ioActionFlags,
                          const AudioTimeStamp *inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList *ioData);

void sequenceUserCallback (
                           void                      *inClientData,
                           MusicSequence             inSequence,
                           MusicTrack                inTrack,
                           MusicTimeStamp            inEventTime,
                           const MusicEventUserData  *inEventData,
                           MusicTimeStamp            inStartSliceBeat,
                           MusicTimeStamp            inEndSliceBeat
                           );

@interface AudioFilePlayer : Player {
    

    
}

void DeriveBufferSize (
                       AudioStreamBasicDescription ASBDesc,                            // 1
                       UInt32                      maxPacketSize,                       // 2
                       Float64                     seconds,                             // 3
                       UInt32                      *outBufferSize,                      // 4
                       UInt32                      *outNumPacketsToRead                 // 5
);

void HandleOutputBuffer (
                         void                *aqData,
                         AudioQueueRef       inAQ,
                         AudioQueueBufferRef inBuffer
                         );

-(void)getSampleTimeBase;
-(OSStatus)createEventForQuince:(QuinceObject *)quince inTrack:(MusicTrack)track;
-(void)checkQuince:(QuinceObject *)quince;

@end
