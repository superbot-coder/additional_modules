Unit AntiReversMod;

//*********************************************************************//
//            Modul by SUPERBOT                                        //
//           https://GitHub.com/Superbot-coder                         //
//*********************************************************************//

Interface

USES
  Windows, SysUtils;

Var
  LAST_ERROR: Integer;


function CheckVirtuals(ExitProc: boolean): Bool;
function CheckAllDebuggers(ExitProc: boolean): boolean;

// IsDebuggerPresent Replacement
function CheckDebugger00: Boolean;
// Check IsDebuggerPresent Hook
function CheckDebugger01: Boolean;
// IsDebuggerPresent Call
function CheckDebugger02: Boolean;
// OllyDbg Window Class
function CheckDebugger03: Boolean;
// NtGlobalFlag
function CheckDebugger04: Boolean;
// RDTSC
function CheckDebugger05: Boolean;
// INT3
function CheckDebugger06: Boolean;
// SingleStep Detection
function CheckDebugger07: Boolean;


// **** Debugger Detection WINAPI ****
function IsDebuggerPresent: BOOL; stdcall; external 'kernel32.dll';

Implementation

Function CheckVirtuals(ExitProc: boolean): Bool;
Const
  sArrVM: Array [0 .. 3] Of String = ('VIRTUAL', 'VMWARE', 'VBOX', 'QEMU');
Var
  hlKey:      HKEY;
  sBuffer:    String;
  sPathName:  String;
  I:          Integer;
  iRegType:  Integer;
  iDataSize:  Integer;
Begin
  Result := False;
  iRegType := 1;
  sPathName := 'SYSTEM\ControlSet001\Services\Disk\Enum';
  try
  If RegOpenKeyEx($80000002, PChar(sPathName), 0, $20019, hlKey) = 0 Then
    If RegQueryValueEx(hlKey, '0', 0, @iRegType, Nil, @iDataSize) = 0 Then
    Begin
      SetLength(sBuffer, iDataSize);
      RegQueryValueEx(hlKey, '0', 0, @iRegType,
                      PByte(PChar(sBuffer)), @iDataSize);
      For I := 0 To 3 Do
        If AnsiPos(UpperCase(sArrVM[I]), UpperCase(Trim(sBuffer))) > 0 Then
        begin
          Result := True;
          if ExitProc then ExitProcess(0)
          else Exit;
        end;
    End;
  finally
    RegCloseKey(hlKey);
  end;
End;


// IsDebuggerPresent Replacement
function CheckDebugger00: Boolean;
asm
  MOV EAX, DWORD PTR FS:[30h]
 MOVZX EAX, BYTE PTR DS:[EAX+2h]
end;

// Check IsDebuggerPresent Hook
function CheckDebugger01: Boolean;
var
  OldFlag: Byte;
asm
  MOV EAX,DWORD PTR FS:[30h]
 LEA EAX,BYTE PTR DS:[EAX+2h]
  MOV BL, BYTE PTR[EAX]
  MOV [OldFlag], BL
 MOV BYTE PTR[EAX],90h
 CALL IsDebuggerPresent
 PUSH EAX
  MOV EAX,DWORD PTR FS:[30h]
  LEA EAX,BYTE PTR DS:[EAX+2h]
  MOV BL, [OldFlag]
  MOV BYTE PTR[EAX],BL
  POP EAX
  CMP EAX, 90h
  MOV EAX, 0
 JE @@ExitProc
  MOV EAX, 1
  @@ExitProc:
end;

// IsDebuggerPresent Call
function CheckDebugger02: Boolean;
asm
  CALL IsDebuggerPresent
end;

// OllyDbg Window Class
function CheckDebugger03: Boolean;
const
  szWindowClass: PChar = 'OLLYDBG';
asm
  PUSH 0
 PUSH szWindowClass
 CALL FindWindow
end;

// NtGlobalFlag
function CheckDebugger04: Boolean;
asm
  MOV EAX,DWORD PTR FS:[30h]
 ADD EAX,68h
 MOV EAX,DWORD PTR DS:[EAX]
 CMP EAX,70h
  MOV EAX, 0
 JNE @@ExitProc
  MOV EAX, 1
  @@ExitProc:
end;

// RDTSC
function CheckDebugger05: Boolean;
asm
  RDTSC
 XOR ECX,ECX
 ADD ECX,EAX
 RDTSC
 SUB EAX,ECX
 CMP EAX,0FFFh
  MOV EAX, 0
 JB @@ExitProc
  MOV EAX, 1
  @@ExitProc:
end;

// INT3
function CheckDebugger06: Boolean;
begin
  try
    asm
      INT 3h
    end;
    Result := true;
  except
    Result := false;
  end;
end;

// SingleStep Detection
function CheckDebugger07: Boolean;
begin
  try
    asm
      PUSHFD
     XOR DWORD PTR[ESP],154h
     POPFD
    end;
    Result := true;
  except
    Result := false;
  end;
end;

{-------------------------- CheckAllDebuggers ---------------------------------}
function CheckAllDebuggers(ExitProc: Boolean): boolean;
begin
 Result := false;
 try
   if IsDebuggerPresent then
   begin
    Result := true;
    if ExitProc then ExitProcess(0)
    else Exit;
   end;
 Except
   LAST_ERROR := GetLastError;
 end;

 // IsDebuggerPresent Replacement
 try
   if CheckDebugger00 then
   begin
     Result := True;
     if ExitProc then ExitProcess(0)
     else exit;
   end;
 except
   LAST_ERROR := GetLastError;
 end;

{
// Check IsDebuggerPresent Hook
 try
  if CheckDebugger01 then
  begin
    Result := true;
    if ExitProc then ExitProcess(0)
    else exit;
  end;
 except
   LAST_ERROR := GetLastError;
 end;   }

  // IsDebuggerPresent Call
 try
   if CheckDebugger02 then
   begin
     Result := true;
     if ExitProc then ExitProcess(0)
     else Exit;
   end;
 except
   LAST_ERROR := GetLastError;
 end;

 // OllyDbg Window Class
 try
   if CheckDebugger03 then
   begin
     Result := True;
     if ExitProc then ExitProcess(0)
     else Exit;
   end;
 except
   LAST_ERROR := GetLastError;
 end;

 // NtGlobalFlag
 try
   if CheckDebugger04 then
   begin
     Result := true;
     if ExitProc then ExitProcess(0)
     else Exit;
   end;
 except
   LAST_ERROR := GetLastError;
 end;

 // RDTSC
 try
  if CheckDebugger05 then
  begin
    Result := True;
    if ExitProc then ExitProcess(0)
    else Exit;
  end;
 except
   LAST_ERROR := GetLastError;
 end;

 // INT3
 try
   if CheckDebugger06 then
   begin
     Result := true;
     if ExitProc then ExitProcess(0)
     else Exit;
   end;
 except
   LAST_ERROR := GetLastError;
 end;

 // SingleStep Detection
 try
  if CheckDebugger07 then
  begin
    Result := true;
     if ExitProc then ExitProcess(0)
     else Exit;
  end;
 except
   LAST_ERROR := GetLastError;
 end;

end;

end.