//
//  Fraction.m
//  first_programe
//
//  Created by Chris Pan on 2020/5/28.
//  Copyright © 2020 Chris Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fraction.h"

@implementation Fraction
{
    int numerator;
    int denominator;
}

-(void) print{
    if(denominator==1){
        NSLog(@"%i",self.numerator);
    }else{
        NSLog(@"%i/%i",self.numerator,self.denominator);
    }
    
}	

-(void) setNumerator: (int) n {
    numerator = n;
}

-(void) setDominator: (int) d {
    denominator = d;
}

-(void) setNumerator: (int) n Dominator: (int) d {
    numerator = n;
    denominator = d;
    [self reduce];
}

-(void) setTo: (int) n over: (int) d {// setTo: over: 声明方式更加具有可读性
    numerator = n;
    denominator = d;
    [self reduce];
}

-(void) set: (int) n : (int) d {
    numerator = n;
    denominator = d;
    [self reduce];
}

-(int) numerator {
    return numerator;
}

-(int) denominator {
    return denominator;
}

-(void) add:(Fraction *)f {
    numerator = numerator * f.denominator + f.numerator * denominator;
    denominator = denominator * f.denominator;
    [self reduce];
}

-(void)reduce {//求最大公约数
    int u = numerator;
    int v = denominator;
    int temp;
    while (v>0) {
        temp = u % v;
        u = v;
        v = temp;
    }
    denominator/=u;
    numerator/=u;
}

@end
