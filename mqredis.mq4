//+------------------------------------------------------------------+
//|                                                      mqredis.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

//typedef struct redisReply {
//    int type; /* REDIS_REPLY_* */
//    PORT_LONGLONG integer; /* The integer when type is REDIS_REPLY_INTEGER */
//    int len; /* Length of string */
//    char *str; /* Used for both REDIS_REPLY_ERROR and REDIS_REPLY_STRING */
//    size_t elements; /* number of elements, for REDIS_REPLY_ARRAY */
//    struct redisReply **element; /* elements vector for REDIS_REPLY_ARRAY */
//} redisReply;

#import "hiredis.dll"

int mqConnect(string &ip,int port);
//int mqConnectWithTimeout(string&ip,int port,long sec,long usec);

void mqFree(int connection);
string mqCommand(int connection,const string &command);
// mqAppendCommandArgv
// mqAppendFormattedCommand
// mqBufferRead
// mqBufferWrite
// mqCommandArgv
// mqConnect
// mqConnectBindNonBlock
// mqConnectFd
// mqConnectNonBlock
// mqConnectUnix
// mqConnectUnixNonBlock
// mqConnectUnixWithTimeout
// mqConnectWithTimeout
// mqEnableKeepAlive
// mqFormatCommandArgv
// mqFree
// mqFreeKeepFd
// mqFreeReplyObject
// mqGetReply
// mqGetReplyFromReader
// mqReaderCreate
// mqReaderFeed
// mqReaderFree
// mqReaderGetReply
// mqSetTimeout
// mqvAppendCommand
// mqvCommand
// mqvFormatCommand
// mqCommand
#import
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string ip="127.0.0.1";
   int connection=mqConnect(ip,6739);
//int connection=mqConnectWithTimeout(ip,6379,0,1);
   Print("mqConnect ",connection);

   string command="SET a hello";
   string result=mqCommand(connection,command);
   Print("SET a ",result);

   command="GET a";
   result=mqCommand(connection,command);
   Print("GET a ",result);

   //mqFree(connection);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
