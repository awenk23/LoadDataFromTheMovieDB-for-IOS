//
//  ATProxy.m
//  AEMC
//
//  Created by i'Mac on 12/10/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATProxy.h"
//#import "ATAppFacade.h"

@implementation ATProxy

@synthesize entityName = _entityName;
@synthesize sectionKey = _sectionKey;
@synthesize predicateFormat = _predicateFormat;
@synthesize predicateArguments = _predicateArguments;
@synthesize sortDescriptors = _sortDescriptors;
@synthesize sortKeys = _sortKeys;
@synthesize sortOrders = _sortOrders;
@synthesize fetchedData = _fetchedData;
@synthesize jsonRequest = _jsonRequest;

- (void)dealloc {
    _fetchedData = nil;
    _jsonRequest = nil;
    _cacheName = nil;
    _entityName = nil;
    _sectionKey = nil;
    _predicateArguments = nil;
    _predicateFormat = nil;
    _sortDescriptors = nil;
    _sortKeys = nil;
    _sortOrders = nil;
}

#pragma mark - Public methods

- (id) fetchLocalDataWithContext:(NSManagedObjectContext*) managedObjectContext
                      entityName:(NSString*) entityName
                 sortDescriptors:(NSArray*)sortDescriptors
                       predicate:(NSPredicate*)predicate
                      sectionKey:(NSString*)sectionKey
                       cacheName:(NSString*)cacheName
{
    @try {
        // perform fetch
        
        //NSManagedObjectContext* managedObjectContext = [[IBCAppFacade getInstance] mainManagedObjectContext];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSAssert(_sortDescriptors, @"No sort descriptor is defined");
        
        // create descriptors
        [request setSortDescriptors:_sortDescriptors];
        [request setPredicate:predicate];
        
        NSFetchedResultsController* fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:sectionKey cacheName:cacheName];
        
        NSError* error;
        BOOL success = [fetchedResultController performFetch:&error];
        if (!success) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to fetch data!" userInfo:nil];
        }
        
        return fetchedResultController;
    }
    
    @catch (NSException *exception) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fetch Error" message:exception.reason.description delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        NSLog(@"%@", exception.reason);
        
    }
    
    return nil;
}

- (void) fetchLocalData
{        
    NSAssert(self.database, @"No database defined");
    
    // create descriptors
    if (_sortDescriptors == nil) {
        NSAssert(_sortKeys, @"No sort key is defined");
    }
    
    _sortDescriptors = ATCreateSortDescriptorsWithKeys(_sortKeys, _sortOrders);
    
    NSPredicate* predicate;
    
    if (_predicateFormat) {
        predicate = [NSPredicate predicateWithFormat:_predicateFormat argumentArray:_predicateArguments];
        //[request setPredicate:predicate];
    }
    
    self.fetchedData = [self fetchLocalDataWithContext:[self.database mainMOC]
                                            entityName:_entityName
                                       sortDescriptors:_sortDescriptors
                                             predicate:predicate
                                            sectionKey:_sectionKey
                                             cacheName:_cacheName];
    
    
}

- (void) mergeData:(NSArray*)serverData
       insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
          keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
   sortDescriptors:(NSArray*) sortDescriptors {
    
    [self mergeDataWithUpdate:serverData insertBlock:insertBlock updateBlock:nil keyBlock:keyBlock sortDescriptors:sortDescriptors];
    
}

- (void) mergeDataWithUpdate:(NSArray*)serverData
                 insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
                 updateBlock:(void (^)(NSManagedObject* object, NSDictionary* dictionary, NSManagedObjectContext* context))updateBlock
                    keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
   sortDescriptors:(NSArray*) sortDescriptors
{
    
    NSManagedObjectContext* tempContext = [self.database tempMOC];
    
    // Fetch local data from temporary MOC
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:tempContext];
    [request setEntity:entity];
    
    // Set sort descriptors
    [request setSortDescriptors:sortDescriptors];
    
    if (self.predicateFormat) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:self.predicateFormat argumentArray:self.predicateArguments];
        [request setPredicate:predicate];
    }
    
    NSFetchedResultsController* fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:tempContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError* error;
    BOOL success = [fetchedResultController performFetch:&error];
    if (!success) {
        // Handle the error.
    }
    
    // Sort new data
    NSArray* sortedServerData = [serverData sortedArrayUsingDescriptors:sortDescriptors];
    
    int i = 0, j = 0;
    NSInteger localDataCount = [fetchedResultController.fetchedObjects count];
    
    // Iterate through imported data
    while (i < sortedServerData.count) {
        NSDictionary* importedData = [sortedServerData objectAtIndex:i];
        
        NSString* serverKey = keyBlock(importedData);
        NSString* localKey = nil;
        
        // Parallel loop local data
        while (j < localDataCount) {
            NSManagedObject* localEntity = [fetchedResultController.fetchedObjects objectAtIndex:j];
            
            NSArray* keys = [[[localEntity entity] attributesByName] allKeys];
            
            localKey = keyBlock([localEntity dictionaryWithValuesForKeys:keys]);
            
            // Compare data array (imported data) with fetched data (local data)
            NSComparisonResult result = [serverKey compare:localKey options:NSNumericSearch];
            
            // INSERT case
            if (result == NSOrderedAscending) {
                // Flag for insert
                localKey = nil;
                
                // Break from local data loop
                break;
                
                // UPDATE CASE
            } else if (result == NSOrderedSame) {
                
                // Call update block
                [localEntity safeSetValuesForKeysWithDictionary:importedData];
                
                if (updateBlock) {
                    updateBlock(localEntity, importedData, tempContext);
                }
                
                // Get the next row in local data
                j++;
                
                // Break from local data loop
                break;
                
                // DELETE CASE
            } else if (result == NSOrderedDescending) {
                
                // Delete object
                [tempContext deleteObject:localEntity];
                
                // Get the next row in local data
                j++;
            }
            
            // if loop has finished and local data is not found
            if (j == localDataCount && result == NSOrderedDescending) {
                localKey = nil;
            }
            
        }
        
        // If row not found in local data
        if (localKey == nil) {
            
            // Get reference to new entity (call insert block)
            NSManagedObject* newEntity = insertBlock(tempContext);
            
            // Call update block
            [newEntity safeSetValuesForKeysWithDictionary:importedData];
            
            if (updateBlock) {
                updateBlock(newEntity, importedData, tempContext);
            }
            
        }
        
        i++;
    }
    
    // iterate through the rest of local data
    while (j < localDataCount) {
        
        NSManagedObject* entityToDelete = [fetchedResultController.fetchedObjects objectAtIndex:j];
        
        // Delete object
        [tempContext deleteObject:entityToDelete];
        
        j++;
    }
    
    // Save Data
    [self.database saveContextType:kATContextTypeTemp];
    
}

- (void) appendData:(NSArray*)serverData
        insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
           keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
    sortDescriptors:(NSArray*) sortDescriptors
{
    
    [self appendDataWithUpdate:serverData insertBlock:insertBlock updateBlock:nil keyBlock:keyBlock sortDescriptors:sortDescriptors];
    
}

- (void) appendDataWithUpdate:(NSArray*)serverData
        insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
        updateBlock:(void (^)(NSManagedObject* object, NSDictionary* dictionary, NSManagedObjectContext* context))updateBlock
           keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
    sortDescriptors:(NSArray*) sortDescriptors
{
    
    NSManagedObjectContext* tempContext = [self.database tempMOC];
    
    // Fetch local data from temporary MOC
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:tempContext];
    [request setEntity:entity];
    
    // Set sort descriptors
    [request setSortDescriptors:sortDescriptors];
    
    if (self.predicateFormat) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:self.predicateFormat argumentArray:self.predicateArguments];
        [request setPredicate:predicate];
    }
    
    NSFetchedResultsController* fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:tempContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError* error;
    BOOL success = [fetchedResultController performFetch:&error];
    if (!success) {
        // Handle the error.
    }
    
    // Sort new data
    NSArray* sortedServerData = [serverData sortedArrayUsingDescriptors:sortDescriptors];
    
    int i = 0, j = 0;
    NSInteger localDataCount = [fetchedResultController.fetchedObjects count];
    
    // Iterate through imported data
    while (i < sortedServerData.count) {
        NSDictionary* importedData = [sortedServerData objectAtIndex:i];
        
        NSString* serverKey = keyBlock(importedData);
        NSString* localKey = nil;
        
        // Parallel loop local data
        while (j < localDataCount) {
            NSManagedObject* localEntity = [fetchedResultController.fetchedObjects objectAtIndex:j];
            
            NSArray* keys = [[[localEntity entity] attributesByName] allKeys];
            
            localKey = keyBlock([localEntity dictionaryWithValuesForKeys:keys]);
            
            // Compare data array (imported data) with fetched data (local data)
            NSComparisonResult result = [serverKey compare:localKey options:NSNumericSearch];
            
            // INSERT case
            if (result == NSOrderedAscending) {
                // Flag for insert
                localKey = nil;
                
                // Break from local data loop
                break;
                
                // UPDATE CASE
            } else if (result == NSOrderedSame) {
                
                // Call update block
                [localEntity safeSetValuesForKeysWithDictionary:importedData];
                
                if (updateBlock) {
                    updateBlock(localEntity, importedData, tempContext);
                }

                // Get the next row in local data
                j++;
                
                // Break from local data loop
                break;
                
            } else {
                
                j++;
            }
            
            // if loop has finished and local data is not found
            if (j == localDataCount && result == NSOrderedDescending) {
                localKey = nil;
            }
            
        }
        
        // If row not found in local data
        if (localKey == nil) {
            
            // Get reference to new entity (call insert block)
            NSManagedObject* newEntity = insertBlock(tempContext);
            
            // Call update block
            [newEntity safeSetValuesForKeysWithDictionary:importedData];
            
            if (updateBlock) {
                updateBlock(newEntity, importedData, tempContext);
            }

        }
        
        i++;
    }
    
    // Save Data
    [self.database saveContextType:kATContextTypeTemp];
    
}

-(void) clearData {
    
    NSManagedObjectContext* tempContext = [self.database tempMOC];
    
    // Fetch local data from temporary MOC
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:tempContext];
    [request setEntity:entity];
    
    // Set sort descriptors
    [request setSortDescriptors:self.sortDescriptors];
    
    NSFetchedResultsController* fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:tempContext sectionNameKeyPath:nil cacheName:nil];
    
    [fetchedResultController.fetchedObjects enumerateObjectsUsingBlock:^(NSManagedObject* entityToDelete, NSUInteger idx, BOOL *stop) {
        [tempContext deleteObject:entityToDelete];
    }];
    
    // Save Data
    [self.database saveContextType:kATContextTypeTemp];
    
}

@end
