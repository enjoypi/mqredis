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

bool mqConnect(string &ip,int port);
string mqCommand(const string &command);
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
   bool ret=mqConnect(ip,6379);
   Print("mqConnect ",ret);

   string command="SET a hello";
   string result=mqCommand(command);
   Print("SET a ",result);

   command="GET a";
   result=mqCommand(command);
   Print("GET a ",result);
  }
//+------------------------------------------------------------------+
