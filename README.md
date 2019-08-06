# TFmini(Plus)-Processing
TFmini(Plus)'s Processing Examples.   

- [tfmini(Plus)Console](#tfminiconsole)  
- [tfmini(Plus)GUI](#tfminigui)  

## tfminiConsole  

Link TFmini(Plus) and PC using CP210x, CH341 etc USB to Serial (Maybe you need install their chip driver for OS):  

![USB2Serial](/Assets/USB2Serial.png)  

`myPort = new Serial(this, "COM12", 115200);`  
Change "COM12" to tfmini serial from device manager;   

>TFmini 9 bytes output:   
>[0x59, 0x59, distanceL, distanceH, strengthL, strengthH, Mode, 0x00, checksum]  

We define a TFmini class:  

```Processing
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
```

update() can be used in serialEvent(). Output is (distance: cm, strength).  



## tfminiGUI  
`myPort = new Serial(this, "COM12", 115200);`  
Change "COM12" to tfmini serial from device manager;   

![tfminiGUI](/Assets/tfminiGUI.png)  

