//
//  main.m
//  first_programe
//
//  Created by Chris Pan on 2020/5/28.
//  Copyright © 2020 Chris Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fraction.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Fraction *f = [Fraction new];
        [f setTo: 2 over: 6];
        [f print];
        
        Fraction *q = [Fraction new];
        [q set: 8 : 3];
        [q print];
        
        [f add: q];
        [f print];
    }
    return 0;
}
