program AuthenticationTests;
{$APPTYPE CONSOLE}
uses System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Def,
 FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.SQLite,
 FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLiteWrapper.Stat,
 PCMService.Authentication in '..\Helper\PCMService.Authentication.pas';
const H = '0123456789abcdef0123456789abcdef';
var C: TFDConnection; Count: Integer;
procedure Check(const Name, UserName, Hash: string; Expected: Boolean);
begin
 if AuthenticateAPIUser(C, UserName, Hash) <> Expected then
   raise Exception.Create('FAIL: ' + Name);
 Inc(Count);
 Writeln('PASS: ' + Name);
end;
procedure CheckTime(const Name, UserName, Hash, ExpectedReason: string; Expected: Boolean);
var UserID: Integer; Reason: string; Allowed: Boolean;
begin
 Allowed := AuthenticateTimeAppUser(C,UserName,Hash,UserID,Reason);
 if (Allowed <> Expected) or (Reason <> ExpectedReason) then
   raise Exception.Create('FAIL Time: ' + Name + ' reason=' + Reason);
 Inc(Count); Writeln('PASS Time: ' + Name);
end;
begin
 try
 C := TFDConnection.Create(nil);
 try
  C.Params.Add('DriverID=SQLite');
  C.Params.Add('Database=:memory:');
  C.LoginPrompt := False;
  C.Connected := True;
  C.ExecSQL('CREATE TABLE Benutzer (ID INTEGER, Benutzer TEXT, Passwort TEXT, RestAPI BOOLEAN)');
  C.ExecSQL('CREATE TABLE time_user (ID INTEGER, Benutzer TEXT, Passwort TEXT, Zugriff_App BOOLEAN, Zurgiff_Web BOOLEAN)');
  C.ExecSQL('INSERT INTO Benutzer VALUES (1, ''pcm'', ?, 1)', [H]);
  C.ExecSQL('INSERT INTO Benutzer VALUES (2, ''disabled'', ?, 0)', [H]);
  C.ExecSQL('INSERT INTO Benutzer VALUES (0, ''invalid-id'', ?, 1)', [H]);
  C.ExecSQL('INSERT INTO Benutzer VALUES (3, ''duplicate'', ?, 1)', [H]);
  C.ExecSQL('INSERT INTO Benutzer VALUES (4, ''duplicate'', ?, 1)', [H]);
  C.ExecSQL('INSERT INTO time_user VALUES (11, ''time-app'', ?, 1, 0)', [H]);
  C.ExecSQL('INSERT INTO time_user VALUES (12, ''time-web'', ?, 0, 1)', [H]);
  C.ExecSQL('INSERT INTO time_user VALUES (13, ''time-disabled'', ?, 0, 0)', [H]);
  Check('PCM login', 'pcm', H, True);
  Check('wrong password', 'pcm', StringOfChar('f', 32), False);
  Check('unknown user', 'unknown', H, False);
  Check('API disabled', 'disabled', H, False);
  Check('invalid ID', 'invalid-id', H, False);
  Check('ambiguous account', 'duplicate', H, False);
  Check('blank username', '', H, False);
  Check('blank hash', 'pcm', '', False);
  Check('SQL injection username', ''' OR 1=1 --', H, False);
  Check('PCMTime app', 'time-app', H, True);
  Check('PCMTime web', 'time-web', H, True);
  Check('PCMTime denied', 'time-disabled', H, False);
  Check('PCMTime wrong password', 'time-app', StringOfChar('f',32), False);
  CheckTime('app allowed','time-app',H,'ok',True);
  CheckTime('web only denied','time-web',H,'permission_denied',False);
  CheckTime('wrong password','time-app',StringOfChar('f',32),'wrong_password',False);
  CheckTime('missing user','','','missing_credentials',False);
  CheckTime('unknown user','missing',H,'unknown_user',False);
  C.ExecSQL('UPDATE time_user SET ID=0 WHERE Benutzer=''time-app''');
  CheckTime('invalid ID','time-app',H,'invalid_user_id',False);
  C.ExecSQL('UPDATE time_user SET ID=11 WHERE Benutzer=''time-app''');
  C.ExecSQL('INSERT INTO time_user VALUES (99,''time-app'',?,1,0)',[H]);
  CheckTime('duplicate denied','time-app',H,'ambiguous_user',False);
  C.ExecSQL('DROP TABLE time_user');
  C.ExecSQL('CREATE TABLE time_user (ID INTEGER, Benutzer TEXT, Passwort TEXT, Zugriff_App VARCHAR(5))');
  C.ExecSQL('INSERT INTO time_user VALUES (11,''text-user'',?,''TRUE '')',[H]);
  CheckTime('padded string permission','text-user',UpperCase(H),'ok',True);
  C.ExecSQL('UPDATE time_user SET Zugriff_App=''FALSE''');
  CheckTime('disabled string permission','text-user',H,'permission_denied',False);
  C.ExecSQL('DROP TABLE time_user');
  Check('PCM works without optional Time table', 'pcm', H, True);
  Writeln(Count, ' authentication cases passed.');
 finally C.Free; end;
 except on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); Halt(1); end; end;
end.
