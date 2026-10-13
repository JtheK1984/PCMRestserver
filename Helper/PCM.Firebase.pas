unit PCM.Firebase;

interface

uses System.JSON;

function SendFirebaseTest(const ADeviceToken: string): TJSONObject;
function SendFirebaseNotification(const ADeviceToken, ATitle, ABody: string): TJSONObject;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.DateUtils,
  System.NetEncoding, System.Hash, System.Net.HttpClient, System.Net.URLClient;

type
  TPaddingInfo = record
    Algorithm: PWideChar;
  end;

function NCryptOpenStorageProvider(out Provider: NativeUInt; Name: PWideChar;
  Flags: Cardinal): Longint; stdcall; external 'ncrypt.dll';
function NCryptImportKey(Provider, ImportKey: NativeUInt; BlobType: PWideChar;
  Parameters: Pointer; out Key: NativeUInt; Data: PByte; Size, Flags: Cardinal): Longint;
  stdcall; external 'ncrypt.dll';
function NCryptSignHash(Key: NativeUInt; Padding: Pointer; Hash: PByte;
  HashSize: Cardinal; Signature: PByte; SignatureSize: Cardinal;
  out ResultSize: Cardinal; Flags: Cardinal): Longint; stdcall; external 'ncrypt.dll';
function NCryptFreeObject(Handle: NativeUInt): Longint; stdcall; external 'ncrypt.dll';

procedure CheckCrypto(Status: Longint);
begin
  if Status <> 0 then
    raise Exception.CreateFmt('Firebase: RSA-Signatur fehlgeschlagen (%.8x)', [Cardinal(Status)]);
end;

function Base64URL(const Bytes: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
  Result := Result.Replace(#13, '').Replace(#10, '').Replace('+', '-').Replace('/', '_').Replace('=', '');
end;

function SignJWT(const Content, PEM: string): string;
var
  Provider, Key: NativeUInt;
  DER, Hash, Signature: TBytes;
  Size: Cardinal;
  Padding: TPaddingInfo;
  Encoded: string;
begin
  Encoded := PEM.Replace('-----BEGIN PRIVATE KEY-----', '').Replace('-----END PRIVATE KEY-----', '');
  Encoded := Encoded.Replace(#13, '').Replace(#10, '').Replace(' ', '');
  DER := TNetEncoding.Base64.DecodeStringToBytes(Encoded);
  if Length(DER) = 0 then
    raise Exception.Create('Firebase: privater Schluessel fehlt');
  Provider := 0;
  Key := 0;
  CheckCrypto(NCryptOpenStorageProvider(Provider, 'Microsoft Software Key Storage Provider', 0));
  try
    CheckCrypto(NCryptImportKey(Provider, 0, 'PKCS8_PRIVATEKEY', nil, Key, @DER[0], Length(DER), $40));
    try
      Hash := THashSHA2.GetHashBytes(Content);
      Padding.Algorithm := 'SHA256';
      CheckCrypto(NCryptSignHash(Key, @Padding, @Hash[0], Length(Hash), nil, 0, Size, 2));
      SetLength(Signature, Size);
      CheckCrypto(NCryptSignHash(Key, @Padding, @Hash[0], Length(Hash), @Signature[0], Size, Size, 2));
      SetLength(Signature, Size);
      Result := Content + '.' + Base64URL(Signature);
    finally
      NCryptFreeObject(Key);
    end;
  finally
    NCryptFreeObject(Provider);
  end;
end;

function PostJSON(Client: THTTPClient; const URL, Body: string;
  const Headers: TNetHeaders): TJSONObject;
var
  Stream: TStringStream;
  Response: IHTTPResponse;
  Value: TJSONValue;
begin
  Stream := TStringStream.Create(Body, TEncoding.UTF8);
  try
    Response := Client.Post(URL, Stream, nil, Headers);
    if (Response.StatusCode < 200) or (Response.StatusCode >= 300) then
      raise Exception.CreateFmt('Firebase HTTP %d: %s', [Response.StatusCode, Response.ContentAsString(TEncoding.UTF8)]);
    Value := TJSONObject.ParseJSONValue(Response.ContentAsString(TEncoding.UTF8));
    if not (Value is TJSONObject) then
    begin
      Value.Free;
      raise Exception.Create('Firebase: ungueltige Antwort');
    end;
    Result := TJSONObject(Value);
  finally
    Stream.Free;
  end;
end;

function SendFirebaseNotification(const ADeviceToken, ATitle, ABody: string): TJSONObject;
var
  Credentials, Claims, Header, OAuth, Payload, Message, Notification, Android, AndroidNotification: TJSONObject;
  Client: THTTPClient;
  FileName, ProjectID, Email, PEM, Assertion, AccessToken, MessageID: string;
  IssuedAt: Int64;
begin
  FileName := GetEnvironmentVariable('GOOGLE_APPLICATION_CREDENTIALS');
  if (FileName = '') or not TFile.Exists(FileName) then
    raise Exception.Create('Firebase nicht konfiguriert: GOOGLE_APPLICATION_CREDENTIALS muss auf die Service-Account-JSON-Datei zeigen');
  Credentials := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName, TEncoding.UTF8)) as TJSONObject;
  if Credentials = nil then
    raise Exception.Create('Firebase: ungueltige Service-Account-Datei');
  try
    if not Credentials.TryGetValue<string>('project_id', ProjectID) or
       not Credentials.TryGetValue<string>('client_email', Email) or
       not Credentials.TryGetValue<string>('private_key', PEM) then
      raise Exception.Create('Firebase: project_id, client_email oder private_key fehlt');
    if (ProjectID = '') or (Email = '') or (PEM = '') or
       (ProjectID.Contains('/')) then
      raise Exception.Create('Firebase: ungueltige Service-Account-Felder');
    Header := TJSONObject.Create;
    Claims := TJSONObject.Create;
    try
      Header.AddPair('alg', 'RS256');
      Header.AddPair('typ', 'JWT');
      IssuedAt := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now), True);
      Claims.AddPair('iss', Email);
      Claims.AddPair('scope', 'https://www.googleapis.com/auth/firebase.messaging');
      Claims.AddPair('aud', 'https://oauth2.googleapis.com/token');
      Claims.AddPair('iat', TJSONNumber.Create(IssuedAt));
      Claims.AddPair('exp', TJSONNumber.Create(IssuedAt + 3600));
      Assertion := SignJWT(Base64URL(TEncoding.UTF8.GetBytes(Header.ToJSON)) + '.' +
        Base64URL(TEncoding.UTF8.GetBytes(Claims.ToJSON)), PEM);
    finally
      Claims.Free;
      Header.Free;
    end;
    Client := THTTPClient.Create;
    try
      Client.ConnectionTimeout := 10000;
      Client.ResponseTimeout := 20000;
      OAuth := PostJSON(Client, 'https://oauth2.googleapis.com/token',
        'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + Assertion,
        [TNameValuePair.Create('Content-Type', 'application/x-www-form-urlencoded')]);
      try
        if not OAuth.TryGetValue<string>('access_token', AccessToken) or (AccessToken = '') then
          raise Exception.Create('Firebase: kein OAuth-Zugriffstoken erhalten');
      finally
        OAuth.Free;
      end;
      Payload := TJSONObject.Create;
      try
        Message := TJSONObject.Create;
        Payload.AddPair('message', Message);
        Message.AddPair('token', ADeviceToken);
        Notification := TJSONObject.Create;
        Message.AddPair('notification', Notification);
        Notification.AddPair('title', ATitle);
        Notification.AddPair('body', ABody);
        Android := TJSONObject.Create;
        Message.AddPair('android', Android);
        Android.AddPair('priority', 'HIGH');
        Android.AddPair('ttl', '900s');
        AndroidNotification := TJSONObject.Create;
        Android.AddPair('notification', AndroidNotification);
        AndroidNotification.AddPair('channel_id', 'pcm_push');
        OAuth := PostJSON(Client, 'https://fcm.googleapis.com/v1/projects/' + ProjectID + '/messages:send',
          Payload.ToJSON, [TNameValuePair.Create('Content-Type', 'application/json; charset=utf-8'),
          TNameValuePair.Create('Authorization', 'Bearer ' + AccessToken)]);
        try
          if not OAuth.TryGetValue<string>('name', MessageID) or (MessageID = '') then
            raise Exception.Create('Firebase: Versand wurde nicht bestaetigt');
          Result := TJSONObject.Create;
          Result.AddPair('success', TJSONBool.Create(True));
          Result.AddPair('name', MessageID);
        finally
          OAuth.Free;
        end;
      finally
        Payload.Free;
      end;
    finally
      Client.Free;
    end;
  finally
    Credentials.Free;
  end;
end;

function SendFirebaseTest(const ADeviceToken: string): TJSONObject;
begin
  Result := SendFirebaseNotification(ADeviceToken, 'App-Benachrichtigung Test',
    'App-Benachrichtigung Test erfolgreich');
end;
end.