//+------------------------------------------------------------------+
//|                                                      mqredis.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

#import "hiredis.dll"

//int redisConnect(char &ip[],int port);
void redisFree(int c);
int redisCommand(int c,uchar &command[]);
int redisCommand1(int c,uchar &format[],uchar &arg1[]);
int redisCommand2(int c,uchar &format[],uchar &arg1[],uchar &arg2[]);
int redisCommand3(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[]);
int redisCommand4(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[],uchar &arg4[]);
void freeReplyObject(int reply);

int mqConnect(const string &ip,int port);
string mqCommand(int c,const string &format);

#import
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

int StringToUtf8(string  text_string,
                 uchar  &array[])
  {
   return StringToCharArray(text_string,array,0,WHOLE_ARRAY,CP_UTF8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string ip="127.0.0.1";
   int connection=mqConnect(ip,6379);
   Print("mqConnect ",connection);

   uchar format[];
   uchar arg1[];
   uchar arg2[];
   StringToUtf8("SET %s %s",format);
   StringToUtf8("foo",arg1);
   StringToUtf8("hello world",arg2);

   int r=redisCommand2(connection,format,arg1,arg2);
   Print("SET foo ",r);
   freeReplyObject(r);

   StringToUtf8("GET foo",format);
   r=redisCommand(connection,format);
   Print("GET foo ",r);
   freeReplyObject(r);

   redisFree(connection);
  }
//+------------------------------------------------------------------+
