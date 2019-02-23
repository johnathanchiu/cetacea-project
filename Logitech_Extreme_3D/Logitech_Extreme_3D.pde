import processing.net.*;
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

String host = "10.0.0.12" ;
Client c = null;

ControlIO control;
ControlDevice device;
ControlHat hatSwitch;
ControlButton button1, button2, button3;
ControlSlider xAxis, yAxis, bSlider, zSlider;

static final int syncByte = 200;  
static final int openByte = 100;
static final int closeByte = 300;
int x, y, by, z; 
boolean trailOn;
boolean b1, b2;
int value = 0;
boolean pressed = false;

void setup() {
  if (key == 'o')
  {
    c = new Client(this, host, 25565);
    System.out.println("new socket");
  } else if (key == 'p')
  {
    c = null;
  }
  control = ControlIO.getInstance(this);   // Initialise the ControlIO  
  device = control.getDevice("Logitech Extreme 3D");
  //System.out.print(device.toText(""));
  button1 = device.getButton("0");
  if (button1 == null) System.out.println("Button1 not initialized");
  button2 = device.getButton("1");
  if (button2 == null) System.out.println("Button2 not initialized");
  //hatSwitch = device.getHat("pov");
  //if (hatSwitch == null) System.out.println("Hat Switch not initialized.");
  xAxis = device.getSlider("x");
  if (xAxis == null) System.out.println("xAxis not initialized.");
  yAxis = device.getSlider("y");
  if (yAxis == null) System.out.println("yAxis not initialized.");
  zSlider = device.getSlider("rz");
  if (zSlider == null) System.out.println("zSlider not initialized.");
  bSlider = device.getSlider("slider");
  if (bSlider == null) System.out.println("bSlider not initialized.");
  yAxis.setTolerance(0.01); 
  xAxis.setTolerance(0.01); 
  zSlider.setTolerance(0.1);
  bSlider.setTolerance(0.2);
  /**tolerance dependent on delay
   *Any value in the range -0.1 to 0.1 will be returned as zero
   */
}
// Need to set up the ControlIO/Device
// See http://lagers.org.uk/gamecontrol/api.html for sample code

void draw() {
  x = Math.round(xAxis.getTotalValue() * 100);
  y = Math.round(yAxis.getTotalValue() * 100); 
  z = Math.round(bSlider.getTotalValue() * 100);
  by = Math.round(zSlider.getTotalValue() * 100);
  b1 = button1.pressed();
  b2 = button2.pressed();
  xAxis.reset();
  yAxis.reset();
  bSlider.reset();
  zSlider.reset();

  delay(10);

  if (x > 100 || x < -100) x = x / 2;  //logarithmic curves for joystick input
  if (y > 100 || y < -100) y = y / 2;
  if (by > 100 || by < -100) by = by / 2;
  if (z > 100 || z < -100) z = z / 2;

  z = -z;
  y = -y;

  System.out.println("x = " + x + ", y = " + y + ", button1: " + b1 + ", button2:" + b2 + ", by:" + by + ", z:" + z);

  try
  {
    if (b1 == true)
    {
      System.out.println("opened");
      c.write(syncByte);
      c.write(y);
      c.write(x);
      c.write(by);
      c.write(z);
      c.write(openByte);
    } else if (b1 == false)
    {
      System.out.println("closed");
      c.write(syncByte);
      c.write(y);
      c.write(x);
      c.write(by);
      c.write(z);
      c.write(closeByte);
    }
  }

  catch(Exception e)
  {
    //System.out.println("err opening socket");
  }
}


void keyPressed() {
  if (pressed == false) {  
    if (value == 0) {
      value = 255; 
      pressed = true;
      try
      {           
        System.out.println(key);
        c.write(key);
      }
      catch(Exception e)
      {
        System.out.println("err opening socket");
      }
    }
  }
} 

void keyReleased()
{
  pressed = false;
  value = 0; 
  c.write('x');
  System.out.println('x');
}