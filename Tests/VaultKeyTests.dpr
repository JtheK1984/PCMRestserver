program VaultKeyTests;
{$APPTYPE CONSOLE}
uses System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Def,
 FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.SQLite,
 FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat,
 PCMService.VaultKeys in '..\Helper\PCMService.VaultKeys.pas';
const H = '0123456789abcdef0123456789abcdef';
var C: TFDConnection; A, B, Again: TBytes; ID: Integer; KID, OtherID: string;
procedure Check(Value: Boolean; const Name: string);
begin if not Value then raise Exception.Create('FAIL: ' + Name); Writeln('PASS: ' + Name); end;
procedure RejectRead(const UserName, Hash: string; AccessDenied: Boolean);
var Key: TBytes; UID: Integer; KeyID: string; Rejected: Boolean;
begin
 Rejected := False;
 try
  Key := ReadAuthenticatedVaultKey(C, UserName, Hash, UID, KeyID);
 except
  on E: EVaultKeyError do begin
   Rejected := True;
   if AccessDenied then Check(E is EVaultAccessDenied, 'denial before key access');
   Check((UID = 0) and (KeyID = ''), 'no identity returned on failure');
  end;
 end;
 ClearVaultKey(Key);
 Check(Rejected, 'reject ' + UserName);
end;
var Rejected: Boolean;
begin
 try
 C := TFDConnection.Create(nil);
 try
  C.Params.Add('DriverID=SQLite'); C.Params.Add('Database=:memory:');
  C.LoginPrompt := False; C.Connected := True;
  C.ExecSQL('CREATE TABLE Benutzer (ID INTEGER PRIMARY KEY, Benutzer TEXT, Passwort TEXT, RestAPI BOOLEAN)');
  C.ExecSQL('CREATE TABLE manager_vault_keys (ID_Benutzer INTEGER PRIMARY KEY, KeyID VARCHAR(38), ProtectedKey VARCHAR(4096))');
  C.ExecSQL('INSERT INTO Benutzer VALUES (1, ''one'', ?, 1)', [H]);
  C.ExecSQL('INSERT INTO Benutzer VALUES (2, ''two'', ?, 1)', [H]);
  C.ExecSQL('INSERT INTO Benutzer VALUES (3, ''disabled'', ?, 0)', [H]);
  RejectRead('one', H, False);
  Check(C.ExecSQLScalar('SELECT COUNT(*) FROM manager_vault_keys') = 0, 'missing key never auto-created');
  ProvisionVaultKey(C, 1); ProvisionVaultKey(C, 2);
  A := ReadAuthenticatedVaultKey(C, 'one', H, ID, KID);
  Check((ID = 1) and (Length(A) = 32), '256-bit key and authenticated identity');
  Again := ReadAuthenticatedVaultKey(C, 'one', H, ID, OtherID);
  Check((OtherID = KID) and CompareMem(@A[0], @Again[0], 32), 'stable key after reload');
  B := ReadAuthenticatedVaultKey(C, 'two', H, ID, OtherID);
  Check((ID = 2) and (OtherID <> KID) and not CompareMem(@A[0], @B[0], 32), 'independent user keys');
  Rejected := False;
  try ProvisionVaultKey(C, 1); except on E: EVaultKeyError do Rejected := True; end;
  Check(Rejected, 'provisioning does not replace existing key');
  RejectRead('one', StringOfChar('f',32), True);
  RejectRead('disabled', H, True);
  RejectRead('unknown', H, True);
  RejectRead(''' OR 1=1 --', H, True);
  RejectRead('', H, True);
  C.ExecSQL('UPDATE manager_vault_keys SET ProtectedKey = (SELECT ProtectedKey FROM manager_vault_keys WHERE ID_Benutzer=2) WHERE ID_Benutzer=1');
  RejectRead('one', H, False);
  Check(C.ExecSQLScalar('SELECT COUNT(*) FROM manager_vault_keys') = 2, 'failed unprotect never regenerates key');
  C.ExecSQL('UPDATE manager_vault_keys SET ProtectedKey = ''AAAA'' WHERE ID_Benutzer=2');
  RejectRead('two', H, False);
  ClearVaultKey(A); ClearVaultKey(B); ClearVaultKey(Again);
  Check((Length(A)=0) and (Length(B)=0) and (Length(Again)=0), 'key buffers released');
 finally C.Free; end;
 except on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); Halt(1); end; end;
end.
