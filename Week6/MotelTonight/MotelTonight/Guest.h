//
//  Guest.h
//  MotelTonight
//
//  Created by Josh Kahl on 2/9/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Guest : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *reservation;
@end

@interface Guest (CoreDataGeneratedAccessors)

- (void)addReservationObject:(NSManagedObject *)value;
- (void)removeReservationObject:(NSManagedObject *)value;
- (void)addReservation:(NSSet *)values;
- (void)removeReservation:(NSSet *)values;

@end
