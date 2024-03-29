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

#import

#import "msvcrt.dll"

int _wfopen(string filename,string mode);
int fclose(int file);
int fflush(int file);

int fwprintf(int file,string format,int arg1);
int fwprintf(int file,string format,string arg1);

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
   int logfile=_wfopen("D:\\onstart.log","w");

   int connection=mqConnect("127.0.0.1",6379);
   fwprintf(logfile,"mqConnect %p\n",connection);
   fflush(logfile);

   int reply;
   uchar format[];
   uchar arg1[];
   uchar arg2[];

   StringToUtf8("SET i %d",format);
   reply=redisCommand(connection,format,999999999);
   fwprintf(logfile,"SET i %s\n",GetResult(reply));
   freeReplyObject(reply);

   StringToUtf8("GET i",format);
   reply=redisCommand(connection,format);
   fwprintf(logfile,"GET i %s\n",GetResult(reply));
   freeReplyObject(reply);

   StringToUtf8("SET %s %s",format);
   StringToUtf8("foo",arg1);
   StringToUtf8("hello world",arg2);
   reply=redisCommand(connection,format,arg1,arg2);
   fwprintf(logfile,"SET foo %s\n",GetResult(reply));
   freeReplyObject(reply);

   StringToUtf8("GET foo",format);
   reply=redisCommand(connection,format);
   fwprintf(logfile,"GET foo %s\n",GetResult(reply));
   freeReplyObject(reply);

   redisFree(connection);
   fclose(logfile);
  }
//+------------------------------------------------------------------+
int loop;
int subscribeReply;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   uchar ip[];
   StringToUtf8("127.0.0.1",ip);
   int ac=redisAsyncConnect(ip,6379);
//   if(c->err)
//     {
///* Let *c leak for now... */
//      printf("Error: %s\n",c->errstr);
//      return 1;
//     }

   loop=aeCreateEventLoop(1024);
   redisAeAttach(loop,ac);

   uchar channel[];
   StringToUtf8("testtopic",channel);

   Print("mqSubscribe ",mqSubscribe(ac,channel,subscribeReply));

//aeMain(loop);
//aeProcessEvents(loop, AE_ALL_EVENTS);
   EventSetMillisecondTimer(10);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   Print("OnTimer");
   aeProcessEvents(loop,AE_ALL_EVENTS);
   Print("subscribeReply ",subscribeReply);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
