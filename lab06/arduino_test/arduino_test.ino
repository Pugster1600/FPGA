void setup() {
  // put your setup code here, to run once:

  Serial.begin(115200);
}

char rx;
char tx;
void loop() {
  // put your main code here, to run repeatedly:
  //1. do nothing when serial not available
  // Non blocking
  if (Serial.available()) {
    char rx = Serial.read();
    char tx = rx + 1;
    Serial.write(tx);
  }
}
