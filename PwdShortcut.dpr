program PwdShortcut;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Pwd Shortcut 0.1';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
