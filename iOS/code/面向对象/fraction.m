#import <Foundation/Foundation.h>、
/*
OC面向对象
经典分数实例
*/

//----------- interface部分 -------------

@interface Fraction: NSObject

-(void) print;
-(void) setNumerator:(int) n;
-(void) setDenominator:(int) n;
-(int) numerator;
-(int) denominator;

@end

//---------- implementation部分 ---------

@implementation Fraction
{
    int numerator;
    int denominator;
}
-(void)print
{
    NSLog(@"%i/%i",numerator,denominator);
}
-(void)setNumerator:(int) n
{
    numerator = n;
}
-(void)setDenominator:(int) n
{
    denominator = n;
}
-(int)numerator
{
    return numerator;
}
-(int)denominator
{
    return denominator;
}
@end

//----------program部分---------------

int main(int argc, const char *argv[]){
    @autoreleasepool{
        Fraction *mFraction;

        //创建实例
        mFraction = [Fraction alloc];
        mFraction = [Fraction init];

        //设置分子分母
        [mFraction setNumerator:1];
        [mFraction setDenominator:3];

        NSLog(@"The value of mFraction is ")
        [mFraction print];

        //NSLog(@"hello world!");
    }
    return 0;
}