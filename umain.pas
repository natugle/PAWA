unit umain;

{PAWA (PascalCoin Wallet) version 0.04 BETA TEST
Copyright (c) 2019 Preben Björn Biermann Madsen
email: natugle@gmail.com
http://pascalcoin.frizen.eu/
github: https://github.com/natugle/

*** THIS IS EXPERIMENTAL SOFTWARE. Use it for educational purposes only. ***

This wallet is for the Pascal Coin P2P Cryptocurrency copyright (c) 2016 Albert Molina.
It may also be compatible with clones of Pascal Coin.

Distributed under the MIT software license, see the accompanying file LICENSE
or visit http://www.opensource.org/licenses/mit-license.php.}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ComCtrls, Types,
  HSButton, HSButtons, httpsend, Process;

type

  { TfMain }

  TfMain = class(TForm)
    cbAccounts: TComboBox;
    cbRunDaemon: TCheckBox;
    edNumTrans: TEdit;
    edRecv: TEdit;
    edAmount: TEdit;
    edFee: TEdit;
    edUrl: TEdit;
    edPort: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    imLogo: TImage;
    lbPubKey: TLabel;
    lbNumTrans: TLabel;
    lbRecv: TLabel;
    lbAmount: TLabel;
    lbFee: TLabel;
    lbAcc: TLabel;
    lbBal: TLabel;
    lbTot: TLabel;
    lbUrl: TLabel;
    lbPort: TLabel;
    mmLog: TMemo;
    mmMsg: TMemo;
    mmTrans: TMemo;
    PageControl: TPageControl;
    pnHideTabs: TPanel;
    pnAbout: TPanel;
    pnHelp: TPanel;
    PpnSet: TPanel;
    pnTrans: TPanel;
    pnSend: TPanel;
   pnTop: TPanel;
    rgEncrypt: TRadioGroup;
    sbExit: TSpeedButton;
    sbMinimize: TSpeedButton;
    stAbout: TStaticText;
    stHelp: TStaticText;
    StatusBar1: TStatusBar;
    tsSend: TTabSheet;
    tsTrans: TTabSheet;
    tsSet: TTabSheet;
    tsHelp: TTabSheet;
    tsAbout: TTabSheet;
    edPubKey: TEdit;
    procedure cbAccountsChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbAboutClick(Sender: TObject);
    procedure lbExitClick(Sender: TObject);
    procedure lbHelpClick(Sender: TObject);
    procedure lbSendClick(Sender: TObject);
    procedure lbSetClick(Sender: TObject);
    procedure lbTransClick(Sender: TObject);
    procedure pnTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnTopMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure rgEncryptSelectionChanged(Sender: TObject);
    procedure sbExitClick(Sender: TObject);
    procedure sbMinimizeClick(Sender: TObject);
  private
    { private declarations }
    FMouseDownPt: TPoint;
    btnSend, btnSendCoins, btnTrans, btnSet, btnHelp, btnAbout, btnExit: THSButton;
    btnCancl, btnRetrieve, btnSave, btnConnect: THSButton;
    FProcess: TProcess;
    FSelectedAccount: string;
    FCurBalance: string;
    FPublicKey: string;
    procedure OnbtnSendClick(Sender: TObject);
    procedure OnbtnCanclClick(Sender: TObject);
    procedure OnbtnRetrieveClick(Sender: TObject);
    procedure OnbtnSaveClick(Sender: TObject);
    procedure OnbtnConnectClick(Sender: TObject);
    function SendRequest(method, params: string): String;
    function String2Hex(const Buffer: Ansistring): string;
    Function Hex2Str(const Buffer: Ansistring): String;
    function ParseJsonString(Str: string):string;
    function DecodePubKey(Pubkey: string): string;
  public
    { public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.lfm}

{$IFDEF UNIX}
const eol = #10;
{$ELSE}
const eol = #13#10;
{$ENDIF}

{ TfMain }

function TfMain.String2Hex(const Buffer: Ansistring): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Buffer) do
  Result := UpperCase(Result + IntToHex(Ord(Buffer[i]), 2));
end;

Function TfMain.Hex2Str(const Buffer: Ansistring): String;
var i: Integer;
begin
  Result:=''; i:=1;
  While i<Length(Buffer) Do Begin
    Result:=Result+Chr(StrToIntDef('$'+Copy(Buffer,i,2),0));
    Inc(i,2);
  End;
end;

function TfMain.ParseJsonString(Str: string): string;
var
  i, j: Integer;
  s, t: string;
begin
  Result := '';
  for i := 1 to Length(str) do
  begin
    t := Str[i];
    if t = ',' then t := eol
    else if t = '{' then t := eol
    else if t = '}' then t := eol;
    s := s + t;
  end;
  Result := s;
end;

function TfMain.DecodePubKey(Pubkey: string): string;
var
  params, str: string;
  i, j: integer;
begin
  Result := '';
  params := '"enc_pubkey":"' + Pubkey +'"';
  str := SendRequest('getwalletpubkey', params);

  i := Pos('b58_pubkey', str);
  j := Pos('"},', str);
  if ((i > 0 ) and (j > i)) then
  begin
    i := i + 13;
    str := copy(str, i, j - i);
  end
  else str := '';
  Result := str;
end;

procedure TfMain.FormActivate(Sender: TObject);
begin
//*  OnbtnConnectClick(self);
end;

procedure TfMain.cbAccountsChange(Sender: TObject);
var
    s, str, method, params: string;
    i, f: integer;
begin
  FSelectedAccount := Trim(cbAccounts.Items[cbAccounts.ItemIndex]);
  params := '"account":' + FSelectedAccount;
  str := SendRequest('getaccount', params);
  i := Pos('"balance":', str);
  if i > 0 then
  begin
    s := copy(str, i + 10, 10);
    s := copy(s, 1, pos(',', s)-1);
    if Pos('.',s) > 0 then lbBal.Caption := 'Balance ' + s
    else lbBal.Caption := 'Balance ' + s + '.0000';
    FCurBalance := s;
  end
  else
  begin
    lbBal.Caption := 'Balance 0.0000';
    FCurBalance := '0';
  end;
  FPublicKey := '';
  i := Pos('"enc_pubkey":"', str);
  if i > 0 then
  begin
    s := copy(str, i + 14, 160);
    FPublicKey := copy(s, 1, pos('",', s)-1);
  end;
  edPubKey.Text := DecodePubKey(FPublicKey); //Hex2Str(FPublicKey);
end;

function TfMain.SendRequest(method, params: string): String;
var
    response: TMemoryStream;
    request, str, url: string;
begin
  request := '{"jsonrpc":"2.0","method":"' + method + '","params":{' + params + '},"id":123}';
  mmLog.Lines.Add('send: ' + request);
  str := '';
  result := '';
  url := 'http://' + Trim(edUrl.Text) + ':' + Trim(edPort.Text);
  response := TMemoryStream.Create;
  try
    if HttpPostURL(url, request, response) then
    begin
         SetLength(str, response.Size);
         Move(response.memory^, str[1], response.size);
    end;
  finally
    response.Free;
  end;
  result := str;
end;

procedure TfMain.pnTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseDownPt := Point(X, Y);
end;

procedure TfMain.lbExitClick(Sender: TObject);
begin
  Application.terminate;
end;

procedure TfMain.lbAboutClick(Sender: TObject);
begin
  PageControl.ActivePage := tsAbout;
end;

procedure TfMain.lbHelpClick(Sender: TObject);
begin
  PageControl.ActivePage := tsHelp;
end;

procedure TfMain.lbSendClick(Sender: TObject);
begin
  PageControl.ActivePage := tsSend;
end;

procedure TfMain.lbSetClick(Sender: TObject);
begin
  PageControl.ActivePage := tsSet;
end;

procedure TfMain.lbTransClick(Sender: TObject);
begin
  PageControl.ActivePage := tsTrans;
  OnbtnRetrieveClick(self);
end;

procedure TfMain.OnbtnConnectClick(Sender: TObject);
var
  str, st, s: string;
  i: integer;
begin
  str := SendRequest('nodestatus', '');
  mmLog.Lines.Add(str);
  if Pos('"ready":true', str) < 1 then
  begin
    showmessage('No Connection - Wait a little and try again' + eol +
    'Still no connection - check Url and Port Settings');
    Exit;
  end;

  str := SendRequest('getwalletaccounts', '');
  mmLog.Lines.Add(str);
  st := str;
  cbAccounts.Items. Clear;
  while Pos('"account":', st) > 0 do
  begin
    i := Pos('"account":', st);
    if i > 0 then
    begin
      s := copy(st, i + 10, 10);
      cbAccounts.Items.Add(copy(s, 1, pos(',', s)-1));
    end;
    delete(st, 1, i + 20);
  end;
  cbAccounts.ItemIndex := 0;
  cbAccountsChange(self);
  str := SendRequest('getwalletcoins', '');
  i := Pos('"result":', str);
  if i > 0 then
  begin
    s := copy(str, i + 9, Pos(',', str)-(i+10));
    if Pos('.', s)>0 then lbTot.Caption := 'Total all accounts ' + s
    else lbTot.Caption := 'Total all accounts ' + s + '.0000';
    mmLog.Lines.Add(str);
  end;
  StatusBar1.SimpleText:= 'Ready';
end;

procedure TfMain.OnbtnCanclClick(Sender: TObject);
begin
  edRecv.Text := '';
  edAmount.Text := '0.0000';
  edFee.Text := '0.0000';
  rgEncrypt.ItemIndex := 0;
  mmMsg.Lines.Clear;
end;

procedure TfMain.OnbtnSendClick(Sender: TObject);
var
  str, s, params: string;
begin
  //* add some checking
  if Pos('-', edRecv.Text) > 0 then s :=  Trim(Copy(edRecv.Text, 1, Pos('-', edRecv.Text)-1))
  else s := Trim(edRecv.Text);
  s := IntToStr(StrToIntDef(s, 0));
  if s = '0' then
  begin
    showmessage('Error in reciever account');
    Exit;
  end;

  if StrToFloat(FCurBalance) < StrToFloat(edAmount.Text) + StrToFloat(edFee.Text) then
  begin
    showmessage('Not enough PASCs in your account');
    Exit;
  end;

  params := '"sender":' + FSelectedAccount +
  ',"target":' + s +
  ',"amount":' + Trim(edAmount.Text) +
  ',"fee":' + Trim(edFee.Text) +
  ',"payload":"' + String2Hex(Trim(mmMsg.Text))+ '","payload_method":"none","pwd":""';

  if MessageDlg('Question', 'Do you wish to Send '+ edAmount.Text + ' Pasc to account ' + edRecv.Text +'?', mtConfirmation,
   [mbYes, mbNo],0) = mrYes then
  begin
    str := SendRequest('sendto', params);
    OnbtnCanclClick(self);
    cbAccountsChange(self);
  end;
  mmLog .Lines.Add(str);
end;

procedure TfMain.OnbtnRetrieveClick(Sender: TObject);
var
  str, s: string;
  i: integer;
begin
  i := StrToIntDef(edNumTrans.Text,10);
  mmTrans.Lines.Clear;
  str := SendRequest('getaccountoperations', '"account":' + FSelectedAccount + ', "max":' + IntToStr(i));
  mmTrans.Lines.Add(ParseJsonString(str));
//* Decode payload
  for i := 0 to mmTrans.Lines.Count -1 do
  begin
    if ((pos('payload', mmTrans.Lines[i]) > 0) and (Length(mmTrans.Lines[i]) > 12)) then
    begin
      s := Hex2Str(copy(mmTrans.Lines[i], 12, Length(mmTrans.Lines[i])-12));
      mmTrans.Lines[i] := '"payload":"' + s + '"';
    end;
  end;
end;

procedure TfMain.OnbtnSaveClick(Sender: TObject);
begin
  showmessage('Save - not implementet');
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  fn: string;
begin
  {$IFDEF WIN32}
    fn := 'pascalcoin_daemon.exe'; //
  {$ENDIF}
  {$IFDEF LINUX}
    fn := 'pascalcoin_daemon';
  {$ENDIF}

  if ((FileExists(fn)) and (cbRunDaemon.Checked)) then
  begin
    FProcess := TProcess.Create(nil);
    FProcess.Executable := fn;
    FProcess.Parameters.Add('-r');
    FProcess.Options := [poNoConsole];
    FProcess.Execute;
  end;

  pnTop.Font.Color := clWhite;
  stAbout.Font.Color := clWhite;
  stHelp.Font.Color := clWhite;
  lbAcc.Font.Color := clWhite;
  lbBal.Font.Color := clWhite;
  lbTot.Font.Color := clWhite;
  lbRecv.Font.Color := clWhite;
  lbAmount.Font.Color := clWhite;
  lbFee.Font.Color := clWhite;
  rgEncrypt.Font.Color := clWhite;
  lbNumtrans.Font.Color := clWhite;
  StatusBar1.Font.Color := clWhite;

  btnConnect := THSButton.Create(fMain);
  with btnConnect do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(745,150,125,40);
    Caption:='Connect      ';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := image6.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @OnbtnConnectClick;
  end;

  btnSendCoins := THSButton.Create(fMain);
  with btnSendCoins do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(20,225,125,40);
    Caption:='Send Coins  ';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := image5.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @lbSendClick;
  end;

  btnTrans := THSButton.Create(fMain);
  with btnTrans do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(20,270,125,40);
    Caption:='Transactions';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := image4.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @lbTransClick;
  end;

  btnSet := THSButton.Create(fMain);
  with btnSet do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(20,315,125,40);
    Caption:='Settings         ';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := image3.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @lbSetClick;
  end;

  btnHelp := THSButton.Create(fMain);
  with btnHelp do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(20,360,125,40);
    Caption:='Help              ';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := image2.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @lbHelpClick;
  end;

  btnAbout := THSButton.Create(fMain);
  with btnAbout do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(20,405,125,40);
    Caption:='About             ';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := image1.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @lbAboutClick;
  end;

  btnExit := THSButton.Create(fMain);
  with btnExit do
  begin
    Parent:=fMain;
    Color:= clBlack;
    SetBounds(20,450,125,40);
    Caption:='Exit                 ';
    NumGlyphs:=2;
    {$IFDEF UNIX} Glyph := Image7.picture.bitmap; {$ENDIF}
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphLeft;
    Style:=THSButtonStyle(bsModern);
    OnClick := @sbExitClick;
  end;

  btnSend := THSButton.Create(tsSend);
  with btnSend do
  begin
    Parent:=tsSend;
    Color:= clBlack;
    SetBounds(420,300,100,40);
    Caption:='Send';
    NumGlyphs:=2;
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphTop;
    Style:=THSButtonStyle(bsModern);
    OnClick := @OnbtnSendClick;
  end;

  btnCancl := THSButton.Create(tsSend);
  with btnCancl do
  begin
    Parent:=tsSend;
    Color:= clBlack;
    SetBounds(525,300,100,40);
    Caption:='Cancel';
    NumGlyphs:=2;
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphTop;
    Style:=THSButtonStyle(bsModern);
    OnClick := @OnbtnCanclClick;
  end;

  btnRetrieve := THSButton.Create(tsTrans);
  with btnRetrieve do
  begin
    Parent:=tsTrans;
    Color:= clBlack;
    SetBounds(590,290,100,40);
    Caption:='Retrieve';
    NumGlyphs:=2;
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphTop;
    Style:=THSButtonStyle(bsModern);
    OnClick := @OnbtnRetrieveClick;
  end;

  btnSave := THSButton.Create(tsSet);
  with btnSave do
  begin
    Parent:=tsSet;
    Color:= clBlack;
    SetBounds(590,80,100,40);
    Caption:='Save';
    NumGlyphs:=2;
    Smooth:=2;
    Border:=8;
    Layout:=blGlyphTop;
    Style:=THSButtonStyle(bsModern);
    OnClick := @OnbtnSaveClick;
  end;
  PageControl.ActivePage := tsSend;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  freeandnil(btnConnect);
  freeandnil(btnSend);
  freeandnil(btnCancl);
  freeandnil(btnRetrieve);
  freeandnil(btnSave);
  freeandnil(btnSendCoins);
  freeandnil(btnTrans);
  freeandnil(btnSet);
  freeandnil(btnHelp);
  freeandnil(btnAbout);
  freeandnil(btnExit);
  FProcess.Terminate(0);
  FreeAndNil(FProcess);
end;

procedure TfMain.pnTopMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (ssLeft in Shift) then
  begin
    Left := Left + (X - FMouseDownPt.X);
    Top := Top + (Y - FMouseDownPt.Y);
  end;
end;

procedure TfMain.rgEncryptSelectionChanged(Sender: TObject);
begin
  ShowMessage('Encryption is not implementet');
end;

procedure TfMain.sbExitClick(Sender: TObject);
begin
  Application.terminate;
end;

procedure TfMain.sbMinimizeClick(Sender: TObject);
begin
  WindowState:=wsMinimized;
end;


end.

