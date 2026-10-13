unit PCM.CalendarPush;

interface

uses System.Classes, System.SyncObjs;

type
  TCalendarPushWorker = class(TThread)
  private
    FWake: TEvent;
    FSchemaReady: Boolean;
    procedure CheckAppointments;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Stop;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, System.Hash, System.JSON,
  FireDAC.Comp.Client, FireDAC.Stan.Param, PCM.ReminderRules,
  PCM.Firebase, PCM.Data, PCM.Restserver.Strings;

const LedgerSQL =
  'CREATE TABLE IF NOT EXISTS manager_calendar_push_delivery (' +
  'calendar_id BIGINT NOT NULL, occurrence_start DATETIME NOT NULL,' +
  'token_hash CHAR(64) NOT NULL, sent_at DATETIME NOT NULL,' +
  'PRIMARY KEY (calendar_id, occurrence_start, token_hash)) ENGINE=InnoDB';

procedure LogCalendar(const Text: string; Level: Integer);
begin
  try
    WriteLog(PCM_Logname, Text, Level);
  except
    // A temporarily locked log file must not stop the reminder worker.
  end;
end;
constructor TCalendarPushWorker.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FWake := TEvent.Create(nil, True, False, '');
  Start;
end;

procedure TCalendarPushWorker.Stop;
begin
  Terminate;
  FWake.SetEvent;
  WaitFor;
end;

destructor TCalendarPushWorker.Destroy;
begin
  Stop;
  FWake.Free;
  inherited;
end;

procedure TCalendarPushWorker.Execute;
begin
  while not Terminated do
  begin
    try
      CheckAppointments;
    except
      on E: Exception do
        LogCalendar('Kalender-Push: ' + E.Message, 2);
    end;
    if FWake.WaitFor(60000) = wrSignaled then Break;
  end;
end;

procedure TCalendarPushWorker.CheckAppointments;
var
  Conn: TFDConnection;
  Events, Devices, Ledger, LockQuery: TFDQuery;
  Occurrence, CheckTime, FinishTime: TDateTime;
  Token, TokenHash, Body, Caption: string;
  Response: TJSONObject;
  Locked: Boolean;
  EventID: Int64;
begin
  if GetEnvironmentVariable('GOOGLE_APPLICATION_CREDENTIALS') = '' then Exit;
  Conn := TFDConnection.Create(nil);
  Events := TFDQuery.Create(nil);
  Devices := TFDQuery.Create(nil);
  Ledger := TFDQuery.Create(nil);
  LockQuery := TFDQuery.Create(nil);
  Locked := False;
  try
    Conn.ConnectionDefName := 'PCM';
    Conn.LoginPrompt := False;
    Conn.Connected := True;
    Events.Connection := Conn; Devices.Connection := Conn;
    Ledger.Connection := Conn; LockQuery.Connection := Conn;
    LockQuery.SQL.Text := 'SELECT GET_LOCK(''pcm_calendar_push'', 0) AS acquired';
    LockQuery.Open;
    Locked := LockQuery.FieldByName('acquired').AsInteger = 1;
    LockQuery.Close;
    if not Locked then Exit;
    if not FSchemaReady then
    begin
      LockQuery.SQL.Text := 'SHOW TABLES LIKE ''manager_calendar_push_delivery''';
      LockQuery.Open;
      if LockQuery.IsEmpty then Conn.ExecSQL(LedgerSQL);
      LockQuery.Close;
      FSchemaReady := True;
    end;
    CheckTime := Now;
    Events.SQL.Text := 'SELECT ID, ID_Benutzer, Caption, Start, Finish, CompleteDay, ' +
      'ReminderMinutesBeforeStart, wiederholung_text FROM manager_kalender ' +
      'WHERE LOWER(CAST(Reminder AS CHAR)) IN (''1'',''true'') AND ' +
      '(Start >= :Earliest OR COALESCE(wiederholung_text,'''') <> '''') ORDER BY Start';
    Events.ParamByName('Earliest').AsDateTime := IncMinute(CheckTime,-15);
    Events.Open;
    Devices.SQL.Text := 'SELECT DISTINCT DeviceToken FROM manager_devices ' +
      'WHERE ID_Benutzer = :UserID AND DeviceType = 0 AND COALESCE(DeviceToken,'''') <> ''''';
    while not Events.Eof and not Terminated do
    begin
      EventID := Events.FieldByName('ID').AsLargeInt;
      try
        if FindDueOccurrence(Events.FieldByName('Start').AsDateTime, CheckTime,
          Events.FieldByName('ReminderMinutesBeforeStart').AsInteger,
          Events.FieldByName('wiederholung_text').AsString, Occurrence) then
        begin
          Caption := Events.FieldByName('Caption').AsString;
          if Caption = '' then Caption := 'Terminerinnerung';
          if Events.FieldByName('CompleteDay').AsBoolean then
            Body := FormatDateTime('dd.mm.yyyy',Occurrence) + ' (ganztags)'
          else
          begin
            FinishTime := Occurrence + Events.FieldByName('Finish').AsDateTime - Events.FieldByName('Start').AsDateTime;
            Body := FormatDateTime('dd.mm.yyyy hh:nn',Occurrence) + ' - ' + FormatDateTime('dd.mm.yyyy hh:nn',FinishTime);
          end;
          Devices.ParamByName('UserID').AsInteger := Events.FieldByName('ID_Benutzer').AsInteger;
          Devices.Open;
          try
            while not Devices.Eof and not Terminated do
            begin
              Token := Trim(Devices.FieldByName('DeviceToken').AsString);
              TokenHash := THashSHA2.GetHashString(Token);
              Ledger.SQL.Text := 'SELECT calendar_id FROM manager_calendar_push_delivery ' +
                'WHERE calendar_id = :ID AND occurrence_start = :Occurrence AND token_hash = :Hash';
              Ledger.ParamByName('ID').AsLargeInt := EventID;
              Ledger.ParamByName('Occurrence').AsDateTime := Occurrence;
              Ledger.ParamByName('Hash').AsString := TokenHash;
              Ledger.Open;
              if Ledger.IsEmpty then
              begin
                Ledger.Close;
                try
                  Response := SendFirebaseNotification(Token, Caption, Body);
                  Response.Free;
                  Ledger.SQL.Text := 'INSERT INTO manager_calendar_push_delivery (calendar_id,occurrence_start,token_hash,sent_at) ' +
                    'VALUES (:ID,:Occurrence,:Hash,:SentAt)';
                  Ledger.ParamByName('ID').AsLargeInt := EventID;
                  Ledger.ParamByName('Occurrence').AsDateTime := Occurrence;
                  Ledger.ParamByName('Hash').AsString := TokenHash;
                  Ledger.ParamByName('SentAt').AsDateTime := Now;
                  Ledger.ExecSQL;
                  LogCalendar('Kalender-Push angenommen, Termin ' + IntToStr(EventID), 0);
                except
                  on E: Exception do
                    LogCalendar('Kalender-Push Termin ' + IntToStr(EventID) + ': ' + E.Message, 2);
                end;
              end
              else Ledger.Close;
              Devices.Next;
            end;
          finally
            Devices.Close;
          end;
        end;
      except
        on E: Exception do
          LogCalendar('Kalender-Push Termin ' + IntToStr(EventID) + ': ' + E.Message, 2);
      end;
      Events.Next;
    end;
  finally
    if Locked then
    begin
      try
        LockQuery.Close;
        LockQuery.SQL.Text := 'SELECT RELEASE_LOCK(''pcm_calendar_push'')';
        LockQuery.Open;
      except
        // Closing the connection also releases the named lock.
      end;
    end;
    LockQuery.Free; Ledger.Free; Devices.Free; Events.Free; Conn.Free;
  end;
end;

end.