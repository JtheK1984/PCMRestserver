unit PCM.TimePush;
interface
uses System.JSON;
function TimePushRequest(const Request: TJSONObject; RegisterDevice: Boolean): TJSONObject;
implementation
uses System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Datasnap.DSSession, PCM.Firebase;

function TimePushRequest(const Request: TJSONObject; RegisterDevice: Boolean): TJSONObject;
var Conn: TFDConnection; Query: TFDQuery; Devices: TJSONArray; Item: TJSONValue;
    UserID, DeviceType: Integer; Token, DeviceID, UserName: string;
begin
  Conn := TFDConnection.Create(nil);
  Query := TFDQuery.Create(nil);
  try
    Conn.ConnectionDefName := 'PCM'; Conn.LoginPrompt := False; Conn.Connected := True;
    Query.Connection := Conn;
    Query.SQL.Text := 'SELECT ID FROM time_user WHERE Benutzer = :UserName';
    UserName := TDSSessionManager.GetThreadSession.GetData('Username');
    Query.ParamByName('UserName').AsString := UserName; Query.Open;
    if Query.IsEmpty then raise Exception.Create('Time-Benutzer nicht gefunden');
    UserID := Query.FieldByName('ID').AsInteger; Query.Close;
    Query.SQL.Text := 'SHOW TABLES LIKE ''time_app_devices'''; Query.Open;
    if Query.IsEmpty then
    begin
      Query.Close;
      Conn.ExecSQL('CREATE TABLE IF NOT EXISTS time_app_devices (' +
        'ID_Benutzer INT NOT NULL, DeviceID VARCHAR(255) NOT NULL, DeviceType INT NOT NULL,' +
        'DeviceToken TEXT NOT NULL, PRIMARY KEY (ID_Benutzer,DeviceID,DeviceType)) ENGINE=InnoDB');
    end
    else Query.Close;
    if Request = nil then raise Exception.Create('Anfrage fehlt');
    if RegisterDevice then
    begin
      if not Request.TryGetValue<TJSONArray>('Device',Devices) then raise Exception.Create('Device fehlt');
      for Item in Devices do
      begin
        Token := ''; DeviceID := ''; DeviceType := -1;
        Item.TryGetValue<string>('DeviceToken',Token);
        Item.TryGetValue<string>('DeviceID',DeviceID);
        Item.TryGetValue<Integer>('DeviceType',DeviceType);
        if (Trim(Token) = '') or (Trim(DeviceID) = '') then Continue;
        if DeviceType <> 0 then raise Exception.Create('Nur Android-Push wird unterstuetzt');
        Query.SQL.Text := 'INSERT INTO time_app_devices (ID_Benutzer,DeviceID,DeviceType,DeviceToken) ' +
          'VALUES (:UserID,:DeviceID,:DeviceType,:Token) ON DUPLICATE KEY UPDATE DeviceToken = VALUES(DeviceToken)';
        Query.ParamByName('UserID').AsInteger := UserID;
        Query.ParamByName('DeviceID').AsString := DeviceID;
        Query.ParamByName('DeviceType').AsInteger := DeviceType;
        Query.ParamByName('Token').AsString := Token; Query.ExecSQL;
      end;
      Result := TJSONObject.Create;
      Result.AddPair('HasError',TJSONBool.Create(False));
      Result.AddPair('ErrorCode',TJSONNumber.Create(0));
    end
    else
    begin
      if not Request.TryGetValue<string>('DeviceToken',Token) or (Trim(Token) = '') then
        raise Exception.Create('DeviceToken fehlt');
      Query.SQL.Text := 'SELECT DeviceID FROM time_app_devices WHERE ID_Benutzer = :UserID AND DeviceToken = :Token';
      Query.ParamByName('UserID').AsInteger := UserID; Query.ParamByName('Token').AsString := Token;
      Query.Open;
      if Query.IsEmpty then raise Exception.Create('Time-Geraet nicht registriert. Bitte zuerst synchronisieren.');
      Query.Close;
      Result := SendFirebaseNotification(Token, 'PCM - Time Test', 'PCM - Time Benachrichtigung erfolgreich',
        'PCM_TIME_GOOGLE_APPLICATION_CREDENTIALS');
    end;
  finally
    Query.Free; Conn.Free;
  end;
end;
end.

