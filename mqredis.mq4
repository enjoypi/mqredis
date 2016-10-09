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

#define REDIS_REPLY_STRING 1
#define REDIS_REPLY_ARRAY 2
#define REDIS_REPLY_INTEGER 3
#define REDIS_REPLY_NIL 4
#define REDIS_REPLY_STATUS 5
#define REDIS_REPLY_ERROR 6

void redisFree(int c);
int redisCommand(int c,uchar &command[]);

int redisCommand(int c,uchar &format[],int arg1);
int redisCommand(int c,uchar &format[],uchar &arg1[]);

int redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[]);

int redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[]);
int redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[],uchar &arg4[]);
void freeReplyObject(int reply);

int mqConnect(const string &ip,int port);
int mqReplyType(int reply);
int mqReplyStrLen(int reply);
bool mqReplyStr(int reply,uchar&vaule[]);

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
string GetResult(int reply)
  {
   int len= mqReplyStrLen(reply);
   if(len<=0)
     {
      return NULL;
     }

   uchar result[];
   ArrayResize(result,len);
   if(mqReplyStr(reply,result))
     {
      return CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
     }
   return NULL;
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

   int reply;
   uchar format[];
   uchar arg1[];
   uchar arg2[];

   StringToUtf8("SET i %d",format);
   reply=redisCommand(connection,format,999999999);
   Print("SET i ",GetResult(reply));
   freeReplyObject(reply);

   StringToUtf8("GET i",format);
   reply=redisCommand(connection,format);
   Print("GET i ",GetResult(reply));
   freeReplyObject(reply);

   StringToUtf8("SET %s %s",format);
   StringToUtf8("foo",arg1);
   StringToUtf8("hello world",arg2);
   reply=redisCommand(connection,format,arg1,arg2);
   Print("SET foo ",GetResult(reply));
   freeReplyObject(reply);

   StringToUtf8("GET foo",format);
   reply=redisCommand(connection,format);
   Print("GET foo ",GetResult(reply));
   freeReplyObject(reply);

   redisFree(connection);
  }
//+------------------------------------------------------------------+
