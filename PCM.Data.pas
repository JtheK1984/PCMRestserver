unit PCM.Data;

interface

uses
  {$Region Uses}
  Data.DB,
  Datasnap.DSAuth,
  Datasnap.DSCommonServer,
  Datasnap.DSHTTP,
  Datasnap.DSHTTPWebBroker,
  Datasnap.DSServer,
  Datasnap.DSSession,
  Datasnap.DSTCPServerTransport,
  DbxCompressionFilter,
  DbxSocketChannelNative,
  dxmdaset,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys,
  FireDAC.Phys.ADS,
  FireDAC.Phys.ADSDef,
  FireDAC.Phys.Intf,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  idHash,inifiles,
  IdHashMessageDigest,
  IPPeerServer,
  System.Classes,
  System.JSON,
  System.SysUtils,
  System.Variants;
  {$ENdRegion Uses}
type
  {$Region Type}
  TPCMRestparam = record
    sParam: string;
  end;
  TPCMRestParamter = array of TPCMRestparam;
type
  Tdm_PCM = class(TDataModule)
    con_PCM: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDPhysADSDriverLink1: TFDPhysADSDriverLink;
    qry_work: TFDQuery;
    FDManager: TFDManager;
    procedure con_PCMBeforeConnect(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    iDBType: integer;
    sServer: String;
    function ReadServerAdress: boolean;
  end;
  {$EndRegion Type}
var
  {$Region var}
  dm_PCM: Tdm_PCM;
  arRestParam: TPCMRestParamter;
  icode: integer;
  sMessage: String;
  procedure WriteLog(AProgram, ALogString: String; AError: integer);
  {$EndRegion var}
const
  {$Region const}
  DB_MYSQL = 0;
  DB_MSSQL = 1;
  DB_ADS = 2;
  DB_FB = 3;
  {$ifdef WIN64}
  PCM_Programmname =  'PCM - Restserver 64-Bit';
  {$else}
  PCM_Programmname =  'PCM - Restserver 32-Bit';
  {$endif}
  PCM_Logname =  'PCMRestserver';
  PCM_Connectionname =  'Restserver';
  PCM_Programmnummer =  14;
  {$EndRegion const}
implementation
{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
uses
  {$Region Uses}
  PCM.Strings,
  PCMService.vers0,
  RESTServer.Service.Version.vers1;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Datamodulfunctions                                                         //
////////////////////////////////////////////////////////////////////////////////
{$Region Datamodul}
procedure WriteLog(AProgram, ALogString: String; AError: integer);
var
  tfLog: TextFile;
  sTag,sError: String;
  sLogLine: String;
  sFilePath: String;
begin
  case DayOfWeek(Date) of
  1: sTag := 'So';
  2: sTag := 'Mo';
  3: sTag := 'Di';
  4: sTag := 'Mi';
  5: sTag := 'Do';
  6: sTag := 'Fr';
  7: sTag := 'Sa';
  end;

  case AError of
  0: sError := 'Hinweis: ';
  1: sError := 'Warnung: ';
  2: sError := 'Fehler: ';

  end;
  if not DirectoryExists(GetEnvironmentVariable('LOCALAPPDATA') + '\PCM') then
    CreateDir(GetEnvironmentVariable('LOCALAPPDATA') + '\PCM');

  if (AProgram = 'PCMRestserver') or (AProgram = 'PCMService') or (AProgram = 'PCMAppserver') or (AProgram = 'PCMBackupService')then
    sFilePath := ExtractFilePath(paramstr(0)) + AProgram + sTag + '.log'
  else
    sFilePath := GetEnvironmentVariable('LOCALAPPDATA') + '\PCM\'+ AProgram + sTag + '.log';
  sLogLine := DateTimeToStr(Now()) + ' ' + sError;
  AssignFile(tfLog, sFilePath);
  if FileExists(sFilePath) then
    Append(tfLog)
  else
    Rewrite(tfLog);
  Writeln(tfLog, sLogLine + ALogString);
  CloseFile(tfLog);
end;

procedure Tdm_PCM.con_PCMBeforeConnect(Sender: TObject);
begin
//  con_PCM.LoginPrompt := False;
//  con_PCM.Params.Clear;
//  case iDBType of
//    DB_MYSQL:
//    begin
////      con_PCM.Params.Add('Database=pcm');
////      con_PCM.Params.Add('User_Name=root');
////      con_PCM.Params.Add('Password=pcm');
////      con_PCM.Params.Add('Server='+ sServer);
////      con_PCM.Params.Add('Port=3307');
////      con_PCM.Params.Add('DriverID=MySQL');
////      con_PCM.Params.Add('Pooled=True');
////      con_PCM.Params.Add('POOL_MaximumItems=50');
////      con_PCM.Params.Add('POOL_ExpireTimeout=600000');
//    end;
//    DB_MSSQL:
//    begin
//      con_PCM.Params.Add('OSAuthent=No');
//      con_PCM.Params.Add('User_Name=sa');
//      con_PCM.Params.Add('Password=Nh2020+5');
//      con_PCM.Params.Add('Server='+ sServer);
//      con_PCM.Params.Add('Database=pcm');
//      con_PCM.Params.Add('DriverID=MSSQL');
////    con_PCM.Params.Add('Pooled=True');
////      con_PCM.Params.Add('POOL_MaximumItems=50');
////      con_PCM.Params.Add('POOL_ExpireTimeout=600000');
//    end;
//    DB_ADS:
//     begin
//      con_PCM.Params.Add('Alias=pcm');
//      con_PCM.Params.Add('ServerTypes=REMOTE|LOCAL');
//      con_PCM.Params.Add('User_Name=adssys');
//      con_PCM.Params.Add('Password=pcm');
//      con_PCM.Params.Add('DriverID=ADS');
//      con_PCM.Params.Add('Pooled=True');
////      con_PCM.Params.Add('POOL_MaximumItems=50');
////      con_PCM.Params.Add('POOL_ExpireTimeout=600000');
//     end;
//  end;
end;
function Tdm_PCM.ReadServerAdress: boolean;
  function ConnectionDefExists(const AName: string): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 0 to FDManager.ConnectionDefs.Count - 1 do
      if SameText(FDManager.ConnectionDefs[i].Name, AName) then
        Exit(True);
  end;
var
  ConnDef: IFDStanConnectionDef;
  Params: TStrings;
  iniFile: TIniFile;
begin

  result:= false;
  iniFile:=TIniFile.create(ExtractFilePath(ParamStr(0)) + 'PCMRestserver.ini');
  sServer:= iniFile.ReadString('Config','Server','localhost');
  iDBType:=iniFile.ReadInteger('Database','Type',0);
  iniFile.Free;
  try

    FDManager.ConnectionDefFileName :=  'FD.ini';
    FDManager.ConnectionDefFileAutoLoad := True;
    FDManager.Active := True;
    con_pcm.Params.Clear;
    con_PCM.ConnectionDefName := 'PCM';
    try
      WriteLog(PCM_logname, rs_Function_Helper_Verbindungsversuch1 + ' 1 PCM',0);
      con_PCM.Connected:= True;
      WriteLog(PCM_logname, rs_Function_Helper_Verbindungsversuch1 + ' 1 PCM ' + rs_Function_Helper_Verbindungsversuch2,0);
      result:= true;
    except
      Sleep(5000);
      try
        WriteLog(PCM_logname, rs_Function_Helper_Verbindungsversuch1 + ' 2 pcm',0);
        con_PCM.Connected:= True;
        WriteLog(PCM_logname, rs_Function_Helper_Verbindungsversuch1 + ' 2 PCM ' + rs_Function_Helper_Verbindungsversuch2,0);
        result:= true;
      except
        Sleep(5000);
        try
          WriteLog(PCM_logname, rs_Function_Helper_Verbindungsversuch1 + ' 3 PCM',0);
          con_PCM.Connected:= True;
          WriteLog(PCM_logname, rs_Function_Helper_Verbindungsversuch1 + ' 3 PCM ' + rs_Function_Helper_Verbindungsversuch2,0);
          result:= true;
        except
        end;
      end;
    end;
//		qry_work.Connection:= Con_PCM;
		WriteLog(PCM_LOGname,rs_Function_Helper_Verbindungerfolgreich,0);
  except
		Writelog(PCM_Logname,rs_Function_Helper_KeineVerbindung1 + sServer + rs_Function_Helper_KeineVerbindung2,2);
		Writelog(PCM_Logname,rs_Function_Helper_PCMINIPruefen + ExtractFilePath(ParamStr(0)) +'PCM.ini.',2);
  end;
end;
{$EndRegion Datamodul}
end.
