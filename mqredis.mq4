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
//void redisFree(int c);
//int redisCommand(int c,char &format[],char &arg[]);
//void freeReplyObject(int reply);

int mqConnect(const string &ip,int port);
int mqConnect2(char &ip[],int len,int port);
//int mqConnectWithTimeout(const string &ip,int port,long sec,long usec);

int mqConnectWithTimeout(string ip,int port,long sec,long usec);

void mqFree(int c);
string mqCommand(int c,const string &format);

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
   int connection;

   uchar sip[];
   StringToCharArray("127.0.0.1",sip,0,WHOLE_ARRAY,CP_UTF8);
//StringToCharArray("127.0.0.1",sip);
//connection=mqConnect2(sip,StringLen(ip), 6739);
//mqFree(connection);

   connection=mqConnect(ip,6379);
//connection=mqConnectWithTimeout(ip, 6379, 1, 0);
   Print("mqConnect ",connection);

   string command="SET a 'hello world'";
   string result=mqCommand(connection,command);
   Print("SET a ",result);

   command="GET a";
   result=mqCommand(connection,command);
   Print("GET a ",result);

   mqFree(connection);
  }
//+------------------------------------------------------------------+
