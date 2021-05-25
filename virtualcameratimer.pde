// 参考
// https://qiita.com/reona396/items/337f1eda23d2e98c4b7e
import spout.*;
Spout spout;
import codeanticode.syphon.*;
SyphonServer server;

String OS_NAME = "";
enum OS_LIST {
  WIN, MAC, OTHER
};
OS_LIST myOS;

boolean lap = false; // ストップ状態か？
int c_millis = millis(); // 現在時刻
int up_millis = millis(); // 起動時間
int lap_millis = millis(); // ラップタイム(一時停止用)

void settings() {
  size(600, 400, P3D);
  PJOGL.profile=1;
}

void setup() {
  // OSの判定
  OS_NAME = System.getProperty("os.name").toLowerCase();
  if (isMac()) {
    myOS = OS_LIST.MAC;
  } else if (isWindows()) {
    myOS = OS_LIST.WIN;
  } else {
    // 判定できないOSを使用していた場合は起動させない
    println("OS判定エラー");
    exit();
  }

  // 映像送信用ライブラリのインスタンス化
  if (myOS == OS_LIST.MAC) {
    server = new SyphonServer(this, "Processing Syphon");
  } else if (myOS == OS_LIST.WIN) {
    spout = new Spout(this);
    spout.createSender("Processing Spout");
  }

  textFont(loadFont("DyoblogFont-Regular-120.vlw"));
}

void draw() {
  background(0);
  
  if(!lap)
    c_millis = millis();
  else
    lap_millis = millis();
  int diff = c_millis - up_millis;
  
  if(!lap || millis() % 1000 < 500){
    fill(255);
    text(String.format("%02d:%02d:%03d", (diff/1000/60)%60, (diff/1000)%60, diff%1000), width/2-155, height/2+20);
  }

  // 映像を送信
  if (myOS == OS_LIST.MAC) {
    server.sendScreen();
  } else if (myOS == OS_LIST.WIN) {
    spout.sendTexture();
  }
}

// キー押すイベント
void keyPressed() {
  if(key == 'q'){
    c_millis = millis();
    up_millis = millis();
    lap_millis = millis();
  }
  if(key == 'a'){
    lap = !lap;
    if(lap)
      lap_millis = millis();
    else
      up_millis -= c_millis - lap_millis;
  }
}

boolean isMac() {
  return OS_NAME.startsWith("mac");
}

boolean isWindows() {
  return OS_NAME.startsWith("windows");
}
