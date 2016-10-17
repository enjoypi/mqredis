//+------------------------------------------------------------------+
//|                                                      earedis.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "hiredis.dll"

#define REDIS_REPLY_STRING 1
#define REDIS_REPLY_ARRAY 2
#define REDIS_REPLY_INTEGER 3
#define REDIS_REPLY_NIL 4
#define REDIS_REPLY_STATUS 5
#define REDIS_REPLY_ERROR 6

#define AE_FILE_EVENTS 1
#define AE_TIME_EVENTS 2
#define AE_ALL_EVENTS (AE_FILE_EVENTS|AE_TIME_EVENTS)
#define AE_DONT_WAIT 4


void redisFree(int c);
int redisCommand(int c,uchar &command[]);

int redisCommand(int c,uchar &format[],int arg1);
int redisCommand(int c,uchar &format[],uchar &arg1[]);

int redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[]);

int redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[]);
int redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[],uchar &arg4[]);
void freeReplyObject(int reply);

// int redisAeAttach(aeEventLoop *loop,redisAsyncContext *ac);
int redisAeAttach(int loop,int ac);
// redisAsyncContext *redisAsyncConnect(const char *ip,int port);
int redisAsyncConnect(const uchar &ip[],int port);
// void redisAsyncFree(redisAsyncContext *ac);
void redisAsyncFree(int ac);
// int redisAsyncCommand(redisAsyncContext *ac, redisCallbackFn *fn, void *privdata, const char *format, ...);
int redisAsyncCommand(int ac,int fn,int privdata,const uchar &command[]);
int redisAsyncCommand(int ac,int fn,int privdata,const uchar &format[],const uchar &arg1[]);
// aeEventLoop *aeCreateEventLoop(int setsize);
int aeCreateEventLoop(int setsize);
// int aeProcessEvents(aeEventLoop *eventLoop, int flags);
int aeProcessEvents(int eventLoop,int flags);
// void aeMain(aeEventLoop *eventLoop);
void aeMain(int eventLoop);

int mqConnect(string ip,int port);
int mqReplyType(int reply);
int mqReplyStrLen(int reply);
bool mqReplyStr(int reply,uchar&vaule[]);

// int mqSubscribe(redisAsyncContext *c, const char* channel, void* privdata) 
int mqSubscribe(int ac,const uchar &channel[],int &reply);
// void mqProcessEvents(aeEventLoop *eventLoop){
void mqProcessEvents(int eventLoop);

#import

int loop;
int subscribeReply=0;
int ac;
uchar channel[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   uchar ip[];
   StringToUtf8("127.0.0.1",ip);
   ac=redisAsyncConnect(ip,6379);
//   if(c->err)
//     {
///* Let *c leak for now... */
//      printf("Error: %s\n",c->errstr);
//      return 1;
//     }

   loop=aeCreateEventLoop(1024);
   redisAeAttach(loop,ac);

   StringToUtf8("1",channel);

   Print("mqSubscribe ",mqSubscribe(ac,channel,subscribeReply));

//--- create timer
   EventSetMillisecondTimer(1000);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//Print("OnTimer");
   mqProcessEvents(loop);
//Print("subscribeReply ",subscribeReply);

   if(subscribeReply!=NULL)
     {
      Print("subscribeReply ",GetResult(subscribeReply));
     }

  }
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
