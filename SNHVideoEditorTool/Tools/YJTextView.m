//
//  YJTextView.m
//  YJJSApp
//
//  Created by DT on 2018/3/28.
//  Copyright © 2018年 dt. All rights reserved.
//

#import "YJTextView.h"
@interface YJTextView()<UITextViewDelegate>
{
    UILabel *PlaceholderLabel;
      UIButton *btn;
}

@end
@implementation YJTextView

- (id) initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        [self awakeFromNib];
        //  self.placeholderFont=font;
        self.delegate=self;
         [self addFinishButton];
    }
    return self;
}


-(void)setPlaceholderFont:(UIFont *)placeholderFont{
    PlaceholderLabel.font=placeholderFont;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidChange:) name:UITextViewTextDidChangeNotification object:self];
    
    float left=5,top=2,hegiht=30;
    self.placeholderColor =RGB(151, 163, 173);
    PlaceholderLabel=[[UILabel alloc] initWithFrame:CGRectMake(left, top
                                                               , CGRectGetWidth(self.frame)-2*left, hegiht)];
    PlaceholderLabel.font=self.placeholderFont;
    PlaceholderLabel.textColor=self.placeholderColor;
    [self addSubview:PlaceholderLabel];
    PlaceholderLabel.text=self.placeholder;
    
    
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)setPlaceholder:(NSString *)placeholder{
    if (placeholder.length == 0 || [placeholder isEqualToString:@""]) {
        PlaceholderLabel.hidden=YES;
    }
    else{
        PlaceholderLabel.hidden=NO;
        PlaceholderLabel.text=placeholder;
    }
    
    _placeholder=placeholder;
    
    
}
//添加完成按钮
-(void)addFinishButton{
    UIView *v=[[UIView alloc] init];
    CGRect rect=v.frame;
    v.tag=1001;
    rect.size.height=41;
    [v setFrame:rect];
    v.backgroundColor=RGB(240, 240, 242);
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    lineView.backgroundColor=RGB(193, 195, 198);
    [v addSubview:lineView];
    btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:RGB(248, 103, 79) forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:13];
    btn.frame=CGRectMake(kScreenWidth-56, 0, 56, 41);
    [btn addTarget:self action:@selector(hideKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:btn];
    [self setInputAccessoryView:v];
}
-(void)hideKeyBoard:(id)sender{
    UIView *v=[self viewWithTag:1001];
    v.origin=CGPointMake(0, kScreenHeight);
    [self resignFirstResponder];
}
-(void)DidChange:(NSNotification*)noti{
    
    //    if (self.placeholder.length == 0 || [self.placeholder isEqualToString:@""]) {
    //        PlaceholderLabel.hidden=YES;
    //    }
    
    if (self.text.length > 0) {
        PlaceholderLabel.hidden=YES;
    }
    else{
        PlaceholderLabel.hidden=NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return YES;
    }
    if (text.length==0) {
        return YES;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < self.textLength) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = self.textLength - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
            self.text = [NSString stringWithFormat:@"%d",0];
        }
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > self.textLength)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:self.textLength];
        [textView setText:s];
        [textView.undoManager removeAllActions];
    }
    
    //不让显示负数 口口日
    self.text = [NSString stringWithFormat:@"%ld",MAX(0,self.textLength - existTextNum)];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [PlaceholderLabel removeFromSuperview];
    
    // [super dealloc];
    
}

@end
