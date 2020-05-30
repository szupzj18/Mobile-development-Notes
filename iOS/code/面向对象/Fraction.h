//
//  Fraction.h
//  first_programe
//
//  Created by Chris Pan on 2020/5/28.
//  Copyright © 2020 Chris Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fraction : NSObject

-(void)print;
-(void)setNumerator:(int) n;
-(void)setDominator:(int) d;
-(void)setNumerator:(int) n Dominator:(int) d;  //带有参数名称 setNumerator:Dominator
-(void)setTo: (int)n over: (int)d;              //带有参数名称 setTo:over:
-(void)set: (int) n :(int) d;                   //不带有参数名称的setter
-(int)numerator;
-(int)denominator;
-(void)add: (Fraction *) f;
-(void)reduce;

@end
