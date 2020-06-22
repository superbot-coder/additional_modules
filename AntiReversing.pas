unit AntiReversing;
 
interface
 
////////////////////////////////////////////////////////////////////////////////
/// UNIT SocketHelper //////////////////////////////////////////////////////////
///                                                                          ///
///                        Copyright © 2009 by Zacherl                       ///
/// [Link nur fur registrierte und freigeschaltete Mitglieder sichtbar. ]    ///
///                                                                          ///
///        Dieses Copyright darf nicht entfernt oder geandert werden!        ///
///   Uber eine Benennung in den Credits wurde ich micht freuen, jedoch ist  ///
///                     dies nicht zwingend erforderlich.                    ///
///                                                                          ///
///   Fals Veranderungen an der Unit vorgenommen werden, so sind Diese per   ///
///                         E-Mail an mich zu senden.                        ///
///   Modifed By SUPERB                                                   ///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
 
uses
  Windows, TlHelp32;
 
type
  TVMFingerprint = (
    vmUnknown                 = $0000,
    vmNative                  = $0001,
    vmWINE                    = $0002,
    vmVirtualPC               = $0003,
    vmVirtualBox              = $0004,
    vmVMWareESXServer         = $0005,
    vmVMWareWorkstation       = $0006,
    vmParallelsWorkstation    = $0007
  );
 
type
  TSBoxFingerprint = (
    sbUnknown                 = $0000,
    sbSandboxie               = $0001,
    sbThreatExpert            = $0002
  );
 
type
  TxDTEntry = packed record
    GDTBase: DWord;
    IDTBase: DWord;
    LDTRBase: DWord;
    GDTLimit: Word;
    IDTLimit: Word;
  end;
 
type
  TxDTArray = array of TxDTEntry;
  TFingerprintArray = array of TVMFingerprint;
 
// Virtual Machine Detection
function IsVirtualMachine(const DetectWINE: Boolean = true): Boolean;
function GetVMFingerprint(xDTEntry: TxDTEntry): TVMFingerPrint; overload;
function GetVMFingerprint(CPU: Cardinal): TVMFingerPrint; overload;
function GetxDTEntry(CPU: Cardinal): TxDTEntry;
function GetxDTArray(out Output: TxDTArray): Cardinal;
function VMFingerprintToStr(FP: TVMFingerprint): String;
// Sandbox Detection
function IsSandbox: Boolean;
function GetSandboxFingerprint: TSBoxFingerprint;
function SBoxFingerprintToStr(SB: TSBoxFingerprint): String;

// **** Debugger Detection WINAPI ****
function IsDebuggerPresent: BOOL; stdcall; external 'kernel32.dll';

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

// Debugger Detection
function IsDebuggerDetected: Boolean;

{--------------------------- ALL ---------------------------------------}
//function CheckDebugersAll: boolean;

 
implementation


 
////////////////////////////////////////////////////////////////////////////////
// PRIVATE FUNCTIONS                                                          //
////////////////////////////////////////////////////////////////////////////////
type
  TxDT = record
    Limit,
    BaseLow,
    BaseHigh: Word;
  end;
 
function Win9xMe: Boolean;
var
  OSVInfo: TOsVersionInfo;
begin
  FillChar(OSVInfo, SizeOf(OSVInfo), 0);
  OSVInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(OSVInfo);
  Result := OSVInfo.dwPlatformId <> 2;
end;
 
function GetIDTBase: DWord;
var
  IDT: TxDT;
begin
  asm
    SIDT IDT
  end;
  Result := (IDT.BaseHigh shl 16) or IDT.BaseLow;
end;
 
function GetIDTLimit: DWord;
var
  IDT: TxDT;
begin
  asm
    SIDT IDT
  end;
  Result := IDT.Limit;
end;
 
function GetGDTBase: DWord;
var
  GDT: TxDT;
begin
  asm
    SGDT GDT
  end;
  Result := (GDT.BaseHigh shl 16) or GDT.BaseLow;
end;
 
function GetGDTLimit: DWord;
var
  GDT: TxDT;
begin
  asm
    SGDT GDT
  end;
  Result := GDT.Limit;
end;
 
function GetLDTRBase: DWord;
var
  Base: Word;
begin
  asm
    SLDT Base;
  end;
  Result := $DEAD0000 or Base;
end;
 
function AnsiUpperCase(const S: String): String;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then
  begin
    CharUpperBuff(PChar(Result), Len);
  end;
end;

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
 
////////////////////////////////////////////////////////////////////////////////
// PUBLIC FUNCTIONS                                                           //
////////////////////////////////////////////////////////////////////////////////
function GetxDTArray(out Output: TxDTArray): Cardinal;
var
  I: integer;
  Info: TSystemInfo;
begin
  GetSystemInfo(Info);
  SetLength(Output, Info.dwNumberOfProcessors);
  for I := 1 to Info.dwNumberOfProcessors do
  begin
    Output[I -1] := GetxDTEntry(I);
  end;
  Result := Length(Output);
end;
 
function GetxDTEntry(CPU: Cardinal): TxDTEntry;
var
  Info: TSystemInfo;
begin
  GetSystemInfo(Info);
  if Info.dwNumberOfProcessors >= CPU then
  begin
    SetThreadAffinityMask(GetCurrentThread, CPU);
    Result.GDTBase  := GetGDTBase;
    Result.IDTBase  := GetIDTBase;
    Result.LDTRBase := GetLDTRBase;
    Result.GDTLimit := GetGDTLimit;
    Result.IDTLimit := GetIDTLimit;
  end
    else
  begin
    FillChar(Result, SizeOf(Result), 0);
  end;
end;
 
function GetVMFingerprint(xDTEntry: TxDTEntry): TVMFingerprint;
begin
  Result := vmUnknown;;
  if (xDTEntry.LDTRBase = $DEAD4060) and (xDTEntry.GDTLimit = 16687) and
    (xDTEntry.IDTBase = $FFC18000) then
  begin
    if (xDTEntry.GDTBase = $FFC07000) then
    begin
      Result := vmVMWareWorkstation;
    end;
    if (xDTEntry.GDTBase = $FFC07400) then
    begin
      Result := vmVMWareESXServer;
    end;
  end
    else
  begin
    if (xDTEntry.GDTLimit = 65535) and (xDTEntry.IDTLimit <= 2047) then
    begin
      if (xDTEntry.LDTRBase = $DEADFFA8) then
      begin
        Result := vmVirtualPC;
      end
        else
      begin
        if (xDTEntry.LDTRBase = $DEADFF5B) then
        begin
          Result := vmParallelsWorkstation;
        end
          else
        begin
          if ((Win9xMe) and (xDTEntry.LDTRBase = $DEAD00B8)) or ((not Win9xMe)
            and (xDTEntry.LDTRBase = $DEAD0000)) then
          begin
            Result := vmVirtualBox;
          end;
        end;
      end;
    end
      else
    begin
      if ((not Win9xME) and (xDTEntry.GDTLimit <= 1023) and
        (xDTEntry.IDTLimit <= 4095)) or ((Win9xME) and
        (xDTEntry.GDTLimit <= 4095) and (xDTEntry.IDTLimit = 767)) then
      begin
        if (Win9xME) and (xDTEntry.LDTRBase = $DEAD00B8) or
          (not Win9xME) and (xDTEntry.LDTRBase = $DEAD0000) then
        begin
          Result := vmNative;
        end
          else
        begin
          if (xDTEntry.GDTLimit = 255) and (xDTEntry.LDTRBase = $DEAD0088) and
            (xDTEntry.IDTLimit = 2047) then
          begin
            Result := vmWINE;
          end;
        end;
      end;
    end;
  end;
end;
 
function GetVMFingerprint(CPU: Cardinal): TVMFingerprint;
var
  xDTEntry: TxDTEntry;
begin
  xDTEntry := GetxDTEntry(CPU);
  Result := GetVMFingerprint(xDTEntry);
end;

function VMFingerprintToStr(FP: TVMFingerprint): String;
begin
  case FP of
    vmUnknown:              Result := 'Unknown';
    vmVMWareWorkstation:    Result := 'VMWare Workstation';
    vmVMWareESXServer:      Result := 'VMWare ESX Server';
    vmVirtualPC:            Result := 'VirtualPC';
    vmVirtualBox:           Result := 'VirtualBox';
    vmParallelsWorkstation: Result := 'Parallels Workstation';
    vmWINE:                 Result := 'WINE';
    vmNative:               Result := 'Native';
  end;
end;
 
function IsVirtualMachine(const DetectWINE: Boolean = true): Boolean;
var
  i: Integer;
  Info: TSystemInfo;
begin
  Result := true;
  GetSystemInfo(Info);
  for i := 1 to Info.dwNumberOfProcessors do
  begin
    if ((DetectWINE) and (GetVMFingerprint(i) = vmNative))
      or ((not DetectWINE) and ((GetVMFingerprint(i) = vmNative)
      or (GetVMFingerprint(i) = vmWINE))) then
    begin
      Result := false;
      Break;
    end;
  end;
end;
 
function GetSandboxFingerprint: TSBoxFingerprint;
var
  hSnapshot: Cardinal;
  ME32: TModuleEntry32;
begin
  Result := sbUnknown;
  // SANDBOXIE & THREATEXPERT
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,
    GetCurrentProcessID);
  if (hSnapshot <> 0) and (hSnapshot <> INVALID_HANDLE_VALUE) then
  begin
    try
      ME32.dwSize := SizeOf(TModuleEntry32);
      if Module32First(hSnapshot, ME32) then
      begin
        while Module32Next(hSnapshot, ME32) do
        begin
          if (AnsiUpperCase(ME32.szModule) = 'SBIEDLL.DLL') then
          begin
            Result := sbSandboxie;
            Break;
          end;
          if (AnsiUpperCase(ME32.szModule) = 'DBGHELP.DLL') then
          begin
            Result := sbThreatExpert;
            Break;
          end;
        end;
      end;
    finally
      CloseHandle(hSnapshot);
    end;
  end;
end;
 
function SBoxFingerprintToStr(SB: TSBoxFingerprint): String;
begin
  case SB of
    sbUnknown:              Result := 'Unknown';
    sbSandboxie:            Result := 'Sandboxie';
    sbThreatExpert:         Result := 'Threat Expert';
  end;
end;
 
function IsSandbox: Boolean;
begin
  Result := GetSandboxFingerprint <> sbUnknown;
end;
 
function IsDebuggerDetected: Boolean;
begin
  if ((not Win9xMe) and CheckDebugger00) or
    //((not Win9xMe) and CheckDebugger01) or
    ((not Win9xMe) and CheckDebugger02) or (CheckDebugger03) or
    ((not Win9xMe) and CheckDebugger04) or (CheckDebugger05) or
    (CheckDebugger06) or (CheckDebugger07) then
  begin
    Result := true;
  end
    else
  begin
    Result := false;
  end;
end;

{----------------------- ALL ---------------------------------
function CheckDebugersAll: boolean;
begin
 //Result := IsDebuggerPresent;
  // IsDebuggerPresent Replacement
 //Result := CheckDebugger00;
 // Check IsDebuggerPresent Hook
 // Result := CheckDebugger01;
 // IsDebuggerPresent Call
 Result := CheckDebugger02;
 // OllyDbg Window Class
 //Result := CheckDebugger03;
 // NtGlobalFlag
 //Result := CheckDebugger04;
 // RDTSC
 //Result := CheckDebugger05;
 // INT3
 //Result := CheckDebugger06;
 // SingleStep Detection
 //Result := CheckDebugger07;

end;  }
end.