unit SID;

//********************************************************
//      "Modul SID" by SUPERBOT                         //
//      Https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses Windows, SUModule, Dialogs ,Error;

function SidToStr(SID: PSID): String;
function GetSidByUserName(UserName: string): PSID;
function GetUserNameBySid(SID: PSID): String;
function GetProcessSid(ProcessId: DWORD): PSID;

implementation

{------------------------------ UserNameGetSid --------------------------------}
function GetSidByUserName(UserName: string): PSID;
var
 Sid: PSID;
 lpDomain : PChar;
 cbDomain,cbSid : Cardinal;
 peUse : Cardinal;
begin
 cbSid    :=128; // Размер буфера под SID (должно хватить)
 cbDomain :=15; // Кол-во символов в имени домена

 // Выделяем память
 GetMem(Sid,cbSid);
 GetMem(lpDomain,cbDomain); // Я в примерах использую Unicode-строки
try
 // Пытаемся получить SID и имя домена
 if (Not LookupAccountNameA(nil,PChar(UserName),Sid,cbSid,lpDomain,cbDomain,peUse))
    //and (GetLastError = ERROR_INSUFFICIENT_BUFFER)
   then begin

    ShowMessage('cbSid = '+IntToString(cbSid)+#13+'cbDomain = '+IntToString(cbDomain));

    ReAllocMem(Sid,cbSid);
    ReAllocMem(lpDomain,cbDomain);

    if not LookupAccountNameA(nil,PChar(UserName),Sid,cbSid,lpDomain,cbDomain,peUse) then begin
      MessageBox(0,PChar(GetSysErrorMessage(GetLastError)),'Error',MB_OK);
      exit;
    end;
    Result:=Sid;
 end else  ShowMessage(GetSysErrorMessage(GetLastError));

finally
  Freemem(lpDomain);
end;

end;


// Получаем имя пользователя по SID
//(комментировать не буду - все аналогично предыдущему примеру)
{---------------------------- GetUserNameBySid --------------------------------}
function GetUserNameBySid(SID: PSID): String;
var
 lpName,lpDomain : PChar;
 cbName,cbDomain : Cardinal;
 peUse : Cardinal;
begin
 cbName:=64;
 cbDomain:=64;
 try
   GetMem(lpName,cbName);
   GetMem(lpDomain,cbDomain);

   if not LookupAccountSidA(nil,SID,lpName,cbName,lpDomain,cbDomain,peUse)
     and (GetLastError=122) then begin

     ReAllocMem(lpName,cbName);
     ReAllocMem(lpDomain,cbDomain);

     if not LookupAccountSid(nil,SID,lpName,cbName,lpDomain,cbDomain,peUse)
       then begin
         MessageBoxA(0,PChar(GetSysErrorMessage(GetLastError)),'Error',MB_OK);
         Exit;
       end;
     end;

     ShowMessage(lpName);

     Result:=lpName;

  finally
    FreeMem(lpName);
    Freemem(lpDomain);
  end;

end;

function SidToStr(Sid : PSID):String;
var
 SIA : PSidIdentifierAuthority;
 dwCount : Cardinal;
 I : Integer;
begin
 // S-R-I-S-S...
 Result:='';
 // Проверяем SID
 if not isValidSid(Sid) then begin
   Writeln('isValidSid = false');
   Exit;
 end;

 Result:='S-'; // Префикс

 // Получаем номер версии SID
 // Хотя работать на прямую с SID, как я уже говорил, не рекомендуется
 Result:=Result+IntToString(Byte(Sid^))+'-';

 // Получаем орган, выдавший SID
 // Пока все находится в последнем байте
 sia:=GetSidIdentifierAuthority(Sid);
 Result:=Result+IntToString(sia.Value[5]); //S-R-I-

 // кол-во RID
 dwCount:= GetSidSubAuthorityCount(Sid)^;
 // и теперь перебираем их
 for i:=0 to dwCount-1 do
  Result:=Result+'-'+IntToString(GetSidSubAuthority(Sid,i)^);

end;

function GetProcessSid(ProcessId: DWORD): PSID;
type
  PTOKEN_USER = ^_TOKEN_USER;
  _TOKEN_USER = record
  User : TSidAndAttributes;
end;
 TOKEN_USER = _TOKEN_USER;

var
  hToken: THandle;
  cbBuf: DWORD;
  ptiUser: PTOKEN_USER;
  szUser, szDomain: array [0..50] of Char;
  chDomain: DWORD;
  chUser: DWORD;
  snu: DWORD;

begin
  Result   := nil;
  chDomain := 50;
  chUser   := 50;
  
  // our thread havn't special token; lets get token from entire process
  if not OpenProcessToken(ProcessId, TOKEN_QUERY, hToken) then begin
    ShowMessage('OpenProcessToken error: ' + GetSysErrorMessage(GetLastError));
    exit;
  end;

  // calc buffer size
  if not GetTokenInformation(hToken, TokenUser, nil, 0, cbBuf) then
    if GetLastError() <> ERROR_INSUFFICIENT_BUFFER then begin
      CloseHandle(hToken);
      exit;
    end;//if
  
  // apply buffer size
  if cbBuf = 0 then exit;
  
  GetMem(ptiUser, cbBuf);
  // get TOKEN_USER record in ptiUser
  if GetTokenInformation(hToken, TokenUser, ptiUser, cbBuf, cbBuf) then begin
  // get user name and domain by SID
  //if LookupAccountSid(nil, ptiUser.User.Sid, szUser, chUser, szDomain, chDomain, snu) then
  Result := ptiUser.User.Sid;
  end;//if
  // Free resources
  CloseHandle(hToken);
  FreeMem(ptiUser);
end;

end.