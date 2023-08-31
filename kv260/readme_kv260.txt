* KV260での実行方法

実行するには、PC用のUSBシリアルケーブル (FTDI TTL-232R-3V3など)か、Raspberry Pi等UARTを使用できる環境が必要です。
ホストPCはLinux上にVivadoとVitis IDEをインストールしているものとします。

1. このディレクトリでmakeコマンドを実行します。

$ make

2. 以下のページの方法で project_1/project_1.xpr をVivadoで開いてビットストリームを出力、XSAファイルにエクスポートします。

Xilinx (AMD) VivadoでVitisプロジェクト作成用のXSAファイルを出力する方法
http://cellspe.matrix.jp/zerofpga/memo00002.html

3. 以下のページに記載の方法でPCやRaspberry PiのUART端子とKV260のGPIOを接続します。
http://cellspe.matrix.jp/zerofpga/mini16_manycore.html

このプロジェクトでのKV260側のUART端子のピン配置は以下のように設定しています。
(PMOD#はDigilentの12ピンPMODの仕様上のピン番号、Board#はKV260のボード上に印字されているピン番号です。)
KV260 PMOD J2
---------------
UART TXD: PMOD#2 (Board#3)
UART RXD: PMOD#3 (Board#5)
GND:      PMOD#5 (Board#9)

4. ホストPCとKV260をUSB mini-Bケーブルで接続します。KV260のHDMI端子を他のモニタ等に接続し、KV260の電源を入れます。

5a. Vitis IDEのXSCT Consoleタブで以下のコマンドを入力し、Vitisプロジェクトを自動作成します。

(現在のディレクトリを確認)
xsct% pwd
(このディレクトリに移動)
xsct% cd このディレクトリのパス/mini16_manycore/kv260
(プロジェクト作成スクリプトを実行)
xsct% source vitisprj.tcl

5b. もしくは、以下のページの方法で XSAファイルから Vitisアプリケーション・プロジェクトを作成し、vitis_src ディレクトリ以下のプログラムをプロジェクトに追加します。

Xilinx (AMD) VitisでVivadoのXSAファイルからアプリケーション・プロジェクトを作成する方法 (Stand alone, Bare metal編)
http://cellspe.matrix.jp/zerofpga/memo00001.html

6. 上記のページに記載の方法でビルド、実行します。(5a.でプロジェクトを自動作成した場合は「実行方法」までスキップします。)
（この時点ではまだ完全には走りません）

7. このディレクトリで
$ make run
を実行します。マンデルブロ集合のプログラムが転送されてHDMI端子から720pで映像出力されます。
(「bad device」エラーが出た場合は、環境変数 UART_DEVICE に有効なUARTデバイス名をセットしてから実行します。)
$ export UART_DEVICE=/dev/ttyUSB0
$ make run
