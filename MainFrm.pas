{**********************************************************}
{                                                          }
{  Windows Password Shortcut                               }
{                                                          }
{  Author: Xiaowen Zhang                                   }
{  Email: xiaowen.z@outlook.com                            }
{  URL: http://www.shaynez.com                             }
{  Last Modified Date: 2016-01-07                          }
{                                                          }
{**********************************************************}

unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, Clipbrd, IniFiles;


type
  TMainForm = class(TForm)
    GroupBox1: TGroupBox;
    ActionList: TActionList;
    CopyAction: TAction;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    _HotKey, _HotKey2, _HotKey3 :Integer;
    procedure HotKey(var Msg:Tmessage);message WM_HOTKEY;
  end;
Const
  cfgFile = 'Pwd.ini';
  version = '1.0';
var
  MainForm: TMainForm;
  inifile:Tinifile;
  itms : TStringlist; // store passwords
  ids : TStringlist; // store IDs
  glAppPath : String;

implementation

{$R *.DFM}

{ Misc Routines }
{ ***************************** }
{ * Stay on Top Procedure       }
{ ***************************** }
procedure SetStayOnTop(Form: TForm; Value: Boolean);
const
  Flag: array[Boolean] of Cardinal = (HWND_NOTOPMOST, HWND_TOPMOST);
begin
  SetWindowPos(Form.Handle, Flag[Value], 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
end;

{ ***************************** }
{ * Init Config File            }
{ ***************************** }
procedure InitConfig();
begin
  glAppPath := ExtractFilePath(Application.ExeName);
  inifile:=Tinifile.create(glAppPath + cfgFile);
  inifile.WriteString('Version','Version',version);

  inifile.Free;
end;

{ ***************************** }
{ * HotKey Implementation       }
{ ***************************** }
procedure TMainForm.HotKey(var msg: TMessage);
begin

  // Alt + F1
  // Hide or Show the Form
  if (msg.LParamLo=mod_alt) and ( msg.LParamHi = VK_F1) then
  begin
    if self.Visible then
    begin
      //doNotifyIconData('del');
      self.Visible:=false;
      MainForm.ComboBox1.DroppedDown := false;
    end
    else
    begin
      //doNotifyIconData('add');
      self.Visible:=true;
      MainForm.ComboBox1.DroppedDown := true;
    end;
  end;

  // Alt + F2
  // Copy current selection's ID
  if (msg.LParamLo=mod_alt) and ( msg.LParamHi = VK_F2) then
  begin
    Clipboard.AsText := ids[MainForm.ComboBox1.ItemIndex];
  end;

  // Alt + F3
  // Copy current selection's ID
  if (msg.LParamLo=mod_alt) and ( msg.LParamHi = VK_F3) then
  begin
    Clipboard.AsText := itms[MainForm.ComboBox1.ItemIndex];
  end;

end;

{ ***************************** }
{ * Load passwords              }
{ ***************************** }
procedure RefreshPasswords();
var
  i,j:integer;
begin
  // Clear the ID desc in the combo and passwords in the list
  MainForm.ComboBox1.Clear;
  itms.Free;
  itms:=TStringList.Create;
  ids.Free;
  ids:=TStringList.Create;

  // Get file path, load ini file
  glAppPath := ExtractFilePath(Application.ExeName);
  inifile:=Tinifile.create(glAppPath + cfgFile);

  // Load the values into Combo
  inifile.ReadSectionValues('Passwords',MainForm.ComboBox1.Items);

  // Create a list to store passwords
  for i:=0 to MainForm.ComboBox1.Items.count-1 do
  begin
      // Calculate = position
      j:=pos('=',MainForm.ComboBox1.Items[i]);
      // Add the password to list
      itms.add(copy(MainForm.ComboBox1.Items[i],j+1,length(MainForm.ComboBox1.Items[i])-j))   ;
      // Save only the ID desc to combo
      MainForm.ComboBox1.Items[i] :=  copy(MainForm.ComboBox1.Items[i],0,j-1)   ;
      // Add ID to list
      j:=pos(',',MainForm.ComboBox1.Items[i]);
      ids.Add(copy(MainForm.ComboBox1.Items[i],j+1,length(MainForm.ComboBox1.Items[i])-j))
  end;

  // Combo style
  Mainform.combobox1.Style := csOwnerDrawFixed ;

  inifile.Free;
end;

{ ***************************** }
{ * Save password to ini file   }
{ ***************************** }
procedure SavePassword(Idx: integer; password: String);
begin
  glAppPath := ExtractFilePath(Application.ExeName);
  inifile:=Tinifile.create(glAppPath + cfgFile);
  inifile.WriteString('Version','Version',version);
  inifile.WriteString('Passwords', MainForm.ComboBox1.Items[Idx], password);

  inifile.Free;
end;


{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  R: TRect;
begin
  // Get screen size
  R := Screen.WorkAreaRect;

  // Set start up position
  Left := R.Right - Width;
  Top := R.Top + Height;

  // Set always on Top
  SetStayOnTop(Self, True);

  // Init Config ini file, correct version
  InitConfig();

  // Load passwords from ini
  RefreshPasswords();

  // Register all the hotkeys
  // Hotkey alt + F1
  _HotKey := GlobalAddAtom('PwdHotKey');
  RegisterHotKey(handle, _HotKey, mod_alt, VK_F1);
  // Hotkey alt + F2
  _HotKey2 := GlobalAddAtom('PwdHotKeyID');
  RegisterHotKey(handle, _HotKey2, mod_alt, VK_F2);
  // Hotkey alt + F3
  _HotKey3 := GlobalAddAtom('PwdHotKeyCp');
  RegisterHotKey(handle, _HotKey3, mod_alt, VK_F3);
end;

{ ***************************** }
{ * Form cannot resize          }
{ ***************************** }
procedure TMainForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if NewHeight <> Height then
    Resize := False;
end;

{ ***************************** }
{ * Drop Down box copy          }
{ ***************************** }
procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
    Clipboard.AsText := itms[MainForm.ComboBox1.ItemIndex];
end;

{ ***************************** }
{ * Edit Password Button        }
{ ***************************** }
procedure TMainForm.Button1Click(Sender: TObject);
var
  str: string;
begin
  str := InputBox('Input Password','Input New Password','');
  SavePassword(MainForm.ComboBox1.ItemIndex, str)  ;
  RefreshPasswords();
end;

{ ***************************** }
{ * Copy ID Button              }
{ ***************************** }
procedure TMainForm.Button2Click(Sender: TObject);
begin
  Clipboard.AsText := ids[MainForm.ComboBox1.ItemIndex];
end;

end.
