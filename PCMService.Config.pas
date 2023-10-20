unit PCMService.Config;

interface

type
  TRESTServerConfig = record
    Port: Integer;
    TokenTimeout: Integer;
    SSL_PublicKey: String;
    SSL_PrivateKey: String;
    SSL_CA_Key: String;
    RestSwagger: boolean;
    procedure Init;
    procedure LoadData;
  end;

implementation

uses
  System.SysUtils, System.IniFiles;

procedure TRESTServerConfig.Init;
begin
  Self := Default(TRESTServerConfig);
end;
procedure TRESTServerConfig.LoadData;
var
  iniRESTServer: TIniFile;
  sIniFile: String;
begin
  sIniFile := ExtractFilePath(ParamStr(0)) + 'PCMService.ini';
  iniRESTServer := TIniFile.Create(sIniFile);
//  DebugMsg('Ini suchen: ' + sIniFile);
  try
    if FileExists(sIniFile) then
    begin
//      DebugMsg('Ini laden in: ' + sIniFile);
      Self.Port := iniRESTServer.ReadInteger('Config', 'HTTP-Port', 8081);
      Self.Port := iniRESTServer.ReadInteger('Config', 'HTTPS-Port', 8443);
      Self.TokenTimeout := iniRESTServer.ReadInteger('Config', 'TokenTimeout', 60);
      Self.RestSwagger:= iniRESTServer.ReadBool('Config', 'Swagger', false);
      Self.SSL_PublicKey := iniRESTServer.ReadString('Zertifikate', 'PublicKey', 'c:\ZMI\Zertifikate\ZMIapp.pem');
      Self.SSL_PrivateKey := iniRESTServer.ReadString('Zertifikate', 'PrivateKey', 'c:\ZMI\Zertifikate\ZMIapp.key');
      Self.SSL_CA_Key := iniRESTServer.ReadString('Zertifikate', 'CA_Key', '');
    end
    else
    begin
      iniRESTServer.WriteInteger('Config', 'HTTP-Port', 8081);
      iniRESTServer.WriteInteger('Config', 'HTTP-Port', 8443);
      iniRESTServer.WriteInteger('Config', 'TokenTimeout', 60);
      iniRESTServer.WriteBool('Config', 'Swagger', false);
      iniRESTServer.WriteString('Zertifikate', 'PublicKey', 'c:\Windows\PCM.pem');
      iniRESTServer.WriteString('Zertifikate', 'PrivateKey', 'c:\Windows\PCM.key');
      iniRESTServer.WriteString('Zertifikate', 'CA_Key', '');

    end;
  finally
    iniRESTServer.Free;
  end;
end;

end.
