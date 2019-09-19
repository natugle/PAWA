program pawa;
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
{$DEFINE UseCThreads}
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, umain
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

