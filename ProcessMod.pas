unit ProcessMod;

interface

uses
  Windows, Vcl.Forms, SysUtils, PSAPI, TLHelp32, NTNative;

function AddDebugPrivilege: boolean;
function ProcessFileName(PID: DWORD; FullPath: Boolean): string;
function FindProcessByExeName(ExeName: String; fullPath: Boolean): Integer;
function KillProcess(PID: DWORD): Boolean;
function KillProcessWait(PID: DWORD): Boolean;
function GetProcessCmdLine(PID:DWORD):string;

implementation

{----------------------------- SetDebugPrivilege ------------------------------}
function AddDebugPrivilege: boolean;
var hToken : THandle;
   TokenPriv, PrevTokenPriv : TOKEN_PRIVILEGES;
   Tmp : DWORD;
begin
 Result := false;
 if Not OpenProcessToken(GetCurrentProcess,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then Exit;
 try
   if Not LookupPrivilegeValue(nil, 'SeDebugPrivilege', TokenPriv.Privileges[0].Luid) then Exit;
   TokenPriv.PrivilegeCount := 1;
   TokenPriv.Privileges[0].Attributes := 0;
   TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
   Tmp := 0;
   PrevTokenPriv := TokenPriv;
   Result:=AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv), PrevTokenPriv, Tmp);
 finally
   CloseHandle(hToken);
 end;
end;

{----------------------------- ProcessFileName --------------------------------}
function ProcessFileName(PID: DWORD; FullPath: Boolean): string;
var
  Handle: THandle;
begin
  Result := '';
  Handle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID);
  if Handle <> 0 then
   try
     SetLength(Result, MAX_PATH);
     ZeroMemory(@Result[1], (SizeOf(Result[1]) * MAX_PATH));

     if FullPath then
      begin
        if GetModuleFileNameEx(Handle, 0, @Result[1], MAX_PATH) > 0 then
          Result:= PChar(Result)
        else
          Result := '';
      end
      else
      begin
        if GetModuleBaseName(Handle, 0, @Result[1], MAX_PATH) > 0 then
          Result:= PChar(Result)
        else
          Result := '';
      end;
  finally
    CloseHandle(Handle);
  end;
end;

{----------------------------- FindProcessByExeName ---------------------------}
function FindProcessByExeName(ExeName: String; fullPath: Boolean): Integer;
var
  aSH: THandle;
  aPE32: TProcessEntry32;
  Next: BOOL;
  st: String;
begin
   Result := 0;
   aSH := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
   aPE32.dwSize := SizeOf(aPE32);
   Next := Process32First(aSH, aPE32);
   while Integer(Next) <> 0 do begin
     st := ProcessFileName(aPE32.th32ProcessID, fullPath);
     if CompareString(LOCALE_SYSTEM_DEFAULT,
                    NORM_IGNORECASE,
                    PChar(ExeName), Length(ExeName),
                    PChar(st), Length(st)) = CSTR_EQUAL then begin
       Result := aPE32.th32ProcessID;
       Break;
     end;
     Next := Process32Next(aSH, aPE32);
   end;
   CloseHandle(aSH);
end;

{------------------------------ KillProcess -----------------------------------}
function KillProcess(PID: DWORD): Boolean;
var
  hProcess: THandle;
begin
  Result := false;
  try
    hProcess := OpenProcess(PROCESS_TERMINATE, False, PID);
    if hProcess = 0 then begin
      exit;
    end;
    Result := TerminateProcess(hProcess, 0);
  finally
    CloseHandle(hProcess);
  end;
end;

{---------------------------- KillProcessWait ---------------------------------}
function KillProcessWait(PID: DWORD): Boolean;
var
  hProcess: THandle;
begin
  Result := false;
  try
    hProcess := OpenProcess(PROCESS_TERMINATE, False, PID);
    if hProcess = 0 then begin
      exit;
    end;
    Result := TerminateProcess(hProcess, 0);
    while WaitForSingleObject(hProcess, 0) = WAIT_TIMEOUT do
    begin
      Application.ProcessMessages;
      Sleep(50);
    end;
  finally
    CloseHandle(hProcess);
  end;
end;

 {
  ###### Пример применения
  PID := FindProcessByExeName('taskmgr.exe',true);
  if PID <> 0 then begin

  // Поднятие привелегии
  if AddDebugPrivilege then ShowMessage('AddDebugPrivilege = true')
  else ShowMessage('AddDebugPrivilege = false');

  // ---- Завершение процесса
  if KillProcess(PID) then // Process завершен
  }

{----------------------------- GetProcessCmdLine ------------------------------}
function GetProcessCmdLine(PID:DWORD):string;
var
 hProcess: THandle;
 pProcBasicInfo: PROCESS_BASIC_INFORMATION;
 ReturnLength: DWORD;
 prb: PEB;
 ProcessParameters: PROCESS_PARAMETERS;
 cb: SIZE_T;
 ws: WideString;
begin
 result:='';
 if pid=0 then exit;
 hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, PID);
 if (hProcess <> 0) then
 try
  if (NtQueryInformationProcess(hProcess,ProcessBasicInformation,
                               @pProcBasicInfo,
                               sizeof(PROCESS_BASIC_INFORMATION),@ReturnLength) = STATUS_SUCCESS) then
  begin
   if ReadProcessMemory(hProcess, pProcBasicInfo.PebBaseAddress, @prb, sizeof(PEB), cb) then
     if ReadProcessMemory(hProcess, prb.ProcessParameters, @ProcessParameters, sizeof(PROCESS_PARAMETERS),cb) then
     begin
       SetLength(ws,(ProcessParameters.CommandLine.Length div 2));
       if ReadProcessMemory(hProcess,ProcessParameters.CommandLine.Buffer,
                            PWideChar(ws),ProcessParameters.CommandLine.Length,cb) then
       result:=string(ws)
     end
  end
 finally
  closehandle(hProcess)
 end
end;

end.


