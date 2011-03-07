//
//  MintViewTest.h
//  QuinceApi
//
//  Created by max on 3/14/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class ContainerView, QuinceObject, QuinceObjectController;

@interface ContainerViewTest : SenTestCase {
	ContainerView * view;
	QuinceObject * quince;
}


-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool;
@end
