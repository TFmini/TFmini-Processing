import processing.serial.*;

Serial myPort;
TFmini tfmini;

int bgColor = 51;
color strokeColor = color(204, 102, 0);
color textColor = color(0, 102, 153);

void setup() {
  size(640, 480);
  background(bgColor);
  //myPort = new Serial(this, Serial.list()[1], 115200);
  myPort = new Serial(this, "COM12", 115200);
  myPort.buffer(9);
  tfmini = new TFmini(0, 0, false);
}

int count = 0;
float lastDist = 0;
int lastDistance = 0;

void draw() {

  //delay(10);
  if(tfmini.complete == true) {
    tfmini.complete = false;
    
    ++count;
    count = count >= width ? 0 : count;

    // clear
    float x1 = (count + 50) >= width ? (count + 50 - width) : (count + 50);
    stroke(bgColor);
    line(x1, 0, x1, height);

    // draw line
    float dist = map(tfmini.distance, 0, 1300, height, 0);
    stroke(strokeColor);
    line(count-1, lastDist, count, dist);

    //println(count + "(" + tfmini.distance + ", " + tfmini.strength + ")");
    
    // display distance: cm
    textSize(20);
    // clear old
    fill(bgColor);
    text(lastDistance, 20, 20);
    // display new
    fill(textColor);
    text(tfmini.distance, 20, 20);

    lastDist = dist;
    lastDistance = tfmini.distance;
  }
}

void serialEvent(Serial myPort) {
  tfmini.update(myPort);
}

class TFmini {
  int distance, strength;
  boolean complete;
  TFmini(int dist, int stre, boolean comp) {
    distance = dist;
    strength = stre;
    complete = comp;
  }
  void update(Serial port) {
    if(port.available() > 8) {
      //byte: [-128, 127]
      byte[] dataByte = port.readBytes();
      int[] data = new int[9];
      for(int i = 0; i < 9; i++) {
        //data[i]: [0, 255]
        data[i] = dataByte[i] >= 0 ? dataByte[i] : (dataByte[i] + 256);  
      }
      if(data[0] == 0x59 && data[1] == 0x59) {
        int checksum = 0;
        for(int i = 0; i < 8; i++) {
          checksum += data[i];
        }
        if(data[8] == checksum % 256) {
          distance = data[2] + data[3] * 256;
          strength = data[4] + data[5] * 256;
          complete = true;
        }
      }
    }
  }
}