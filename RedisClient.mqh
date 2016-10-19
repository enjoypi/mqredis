//+------------------------------------------------------------------+
//|                                                        Redis.mqh |
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
int   mqConnect(const string &ip,int port);
void  redisFree(int c);
int   redisCommand(int c,uchar &command[]);
int   redisCommand(int c,uchar &format[],int arg1);
int   redisCommand(int c,uchar &format[],uchar &arg1[]);
int   redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[]);
int   redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[]);
int   redisCommand(int c,uchar &format[],uchar &arg1[],uchar &arg2[],uchar &arg3[],uchar &arg4[]);
int   mqReplyType(int reply);
int   mqReplyStrLen(int reply);
bool  mqReplyStr(int reply,uchar&vaule[]);
void  freeReplyObject(int reply);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRedisClient
  {
private:
   int   m_connection;
   
            int      StringToUtf8(string  text_string,uchar  &array[]);
            string   GetReplyString(int reply);
public:
                     CRedisClient(string host,int port);
                    ~CRedisClient();
                    
            bool     Auth(string password,string &reply_string);
            bool     Select(uint index,string &reply_string);
            bool     Set(string key,string value,string &reply_string);
            bool     Get(string key,string &reply_string);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CRedisClient::CRedisClient(string   host,
                           int      port)
  {
   m_connection=mqConnect(host,port);
   if(m_connection!=NULL)
     {
      PrintFormat("Redis CONNECTED %d",m_connection);
     }
   else
     {
      Alert(StringFormat("%s(%d) %s: redis(%s:%d) connect FAIL",AccountName(),AccountNumber(),__FUNCTION__,host,port));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CRedisClient::~CRedisClient()
  {
   uchar format[];
   int reply;
   string reply_string;

   if(m_connection!=NULL)
     {
      StringToUtf8("QUIT",format);
      reply=redisCommand(m_connection,format);
      reply_string=GetReplyString(reply);
      freeReplyObject(reply);
      if(StringCompare(reply_string,"OK")==0)
        {
         PrintFormat("Redis QUIT %s",reply_string);
        }
      else
        {
         Alert(StringFormat("%s(%d) %s: redis QUIT FAIL %s",AccountName(),AccountNumber(),__FUNCTION__,reply_string));
        }
      
      redisFree(m_connection);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CRedisClient::StringToUtf8(string text_string,
                               uchar  &array[])
  {
   return StringToCharArray(text_string,array,0,WHOLE_ARRAY,CP_UTF8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CRedisClient::GetReplyString(int reply)
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
bool CRedisClient::Auth(string password,
                        string &reply_string)
  {
   if(m_connection!=NULL)
     {
      uchar format[];
      uchar arg1[];
      int reply;
   
      StringToUtf8("AUTH %s",format);
      StringToUtf8(password,arg1);
      reply=redisCommand(m_connection,format,arg1);
      int reply_type=mqReplyType(reply);
      reply_string=GetReplyString(reply);
      freeReplyObject(reply);
      if(reply_type==REDIS_REPLY_STATUS&&StringCompare(reply_string,"OK")==0)
        {
         PrintFormat("Redis AUTHORIZED %s.",reply_string);
         return(true);
        }
      else
        {
         Alert(StringFormat("%s(%d) %s: redis AUTHORIZE FAIL %s",AccountName(),AccountNumber(),__FUNCTION__,reply_string));
        }
     }
   else
     {
      Alert(StringFormat("%s(%d) %s: Redis no connection",AccountName(),AccountNumber(),__FUNCTION__));
     }
     
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CRedisClient::Set(string key,
                       string value,
                       string &reply_string)
  {
   if(m_connection!=NULL)
     {
      int reply;
      uchar format[];
      uchar arg1[];
      uchar arg2[];
      
      StringToUtf8("SET %s %s",format);
      StringToUtf8(key,arg1);
      if(value==NULL)
        {
         value="";
        }
      StringToUtf8(value,arg2);
      reply=redisCommand(m_connection,format,arg1,arg2);
      int reply_type=mqReplyType(reply);
      reply_string=GetReplyString(reply);
      freeReplyObject(reply);
      if(reply_type==REDIS_REPLY_STATUS&&StringCompare("OK",reply_string)==0)
        {
         PrintFormat("Redis SET \"%s\" \"%s\" %s",key,value,reply_string);
         return(true);
        }
      else
        {
         Alert(StringFormat("%s(%d) %s: SET \"%s\" \"%s\" %s",AccountName(),AccountNumber(),__FUNCTION__,key,value,reply_string));
        }
     }
   else
     {
      Alert(StringFormat("%s(%d) %s: Redis no connection",AccountName(),AccountNumber(),__FUNCTION__));
     }
     
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CRedisClient::Get(string key,
                       string &reply_string)
  {
   if(m_connection!=NULL)
     {
      int reply;
      uchar format[];
      uchar arg1[];
      
      StringToUtf8("GET %s",format);
      StringToUtf8(key,arg1);
      reply=redisCommand(m_connection,format,arg1);
      int reply_type=mqReplyType(reply);
      reply_string=GetReplyString(reply);
      freeReplyObject(reply);
      if(reply_type==REDIS_REPLY_STRING||reply_type==REDIS_REPLY_NIL)
        {
         //PrintFormat("Redis GET \"%s\" reply \"%s\"",key,reply_string);
         return(true);
        }
      else
        {
         Alert(StringFormat("%d(%s) %s: GET \"%s\" %s",AccountNumber(),AccountName(),__FUNCTION__,key,reply_string));
        }
     }
   else
     {
      Alert(StringFormat("%d(%s) %s: Redis no connection",AccountNumber(),AccountName(),__FUNCTION__));
     }
     
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CRedisClient::Select(uint index,
                          string &reply_string)
  {
   if(m_connection!=NULL)
     {
      int reply;
      uchar format[];
      
      StringToUtf8("SELECT %d",format);
      reply=redisCommand(m_connection,format,index);
      int reply_type=mqReplyType(reply);
      reply_string=GetReplyString(reply);
      freeReplyObject(reply);
      if(reply_type==REDIS_REPLY_STATUS&&StringCompare("OK",reply_string)==0)
        {
         PrintFormat("Redis SELECT %d %s",index,reply_string);
         return(true);
        }
     }
   else
     {
      Alert(StringFormat("%s(%d) %s: Redis no connection",AccountName(),AccountNumber(),__FUNCTION__));
     }
     
   return(false);
  }