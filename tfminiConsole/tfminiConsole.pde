import processing.serial.*;

Serial myPort;
TFmini tfmini;

void setup() {
	//size(320, 240);
	//myPort = new Serial(this, Serial.list()[1], 115200);
	myPort = new Serial(this, "COM12", 115200);
	myPort.buffer(9);
	tfmini = new TFmini(0, 0, false);
}

void draw() {
	if(tfmini.complete == true) {
		tfmini.complete = false;
		println("(" + tfmini.distance + ", " + tfmini.strength + ")");
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