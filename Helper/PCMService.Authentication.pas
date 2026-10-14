unit PCMService.Authentication;

interface

uses FireDAC.Comp.Client;

function AuthenticateTimeAppUser(const Conn: TFDConnection;
  const UserName, PasswordHash: string; out UserID: Integer;
  out Reason: string): Boolean;
function AuthenticateAPIUser(const Conn: TFDConnection;
  const UserName, PasswordHash: string): Boolean;

implementation

uses System.SysUtils, Data.DB, FireDAC.Stan.Param;

function PermissionGranted(const Field: TField): Boolean;
var Value: string;
begin
  if Field.IsNull then Exit(False);
  if Field.DataType = ftBoolean then Exit(Field.AsBoolean);
  Value := Trim(Field.AsString);
  Result := SameText(Value, 'True') or (Value = '1');
end;

function AuthenticateTable(const Conn: TFDConnection;
  const TableName, PermissionName, UserName, PasswordHash: string;
  out UserID: Integer; out Reason: string): Boolean;
var Query: TFDQuery;
begin
  Result := False;
  UserID := 0;
  Reason := 'missing_credentials';
  if (Trim(UserName) = '') or (PasswordHash = '') then Exit;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := Conn;
    Query.SQL.Text := 'SELECT ID, Passwort, ' + PermissionName +
      ' FROM ' + TableName + ' WHERE Benutzer = :User';
    Query.ParamByName('User').AsString := UserName;
    Query.Open;
    Reason := 'unknown_user';
    if Query.IsEmpty then Exit;
    UserID := Query.FieldByName('ID').AsInteger;
    Reason := 'wrong_password';
    if not SameText(Trim(Query.FieldByName('Passwort').AsString), PasswordHash) then Exit;
    Reason := 'permission_denied';
    if not PermissionGranted(Query.FieldByName(PermissionName)) then Exit;
    Reason := 'invalid_user_id';
    if UserID <= 0 then Exit;
    Query.Next;
    Reason := 'ambiguous_user';
    if not Query.Eof then Exit;
    Reason := 'ok';
    Result := True;
  finally
    Query.Free;
  end;
end;

function AuthenticateTimeAppUser(const Conn: TFDConnection;
  const UserName, PasswordHash: string; out UserID: Integer;
  out Reason: string): Boolean;
begin
  Result := AuthenticateTable(Conn, 'time_user', 'Zugriff_App',
    UserName, PasswordHash, UserID, Reason);
end;

function AuthenticateAPIUser(const Conn: TFDConnection;
  const UserName, PasswordHash: string): Boolean;
var UserID: Integer; Reason: string;
begin
  Result := AuthenticateTable(Conn, 'Benutzer', 'RestAPI',
    UserName, PasswordHash, UserID, Reason);
  if Result then Exit;
  try
    Result := AuthenticateTimeAppUser(Conn, UserName, PasswordHash, UserID, Reason);
    if not Result then
      Result := AuthenticateTable(Conn, 'time_user', 'Zurgiff_Web',
        UserName, PasswordHash, UserID, Reason);
  except
    // PCM-only installations need not contain the optional Time table.
    Result := False;
  end;
end;

end.
