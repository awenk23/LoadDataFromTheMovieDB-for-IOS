//
//  exp1Tests.m
//  exp1Tests
//
//  Created by imac on 07/06/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NowPlayingList.h"
#import "DetailSimiliarUI.h"

@interface exp1Tests : XCTestCase
@property NowPlayingList *npList;
@property DetailSimiliarUI *dSimiliar;

@end

@implementation exp1Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
