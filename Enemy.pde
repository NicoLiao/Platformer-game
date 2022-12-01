public class Enemy extends AnimatedSprite {
  float boundaryLeft, boundaryRight;
  public Enemy(PImage img, float scale, float bLeft, float bRight) {
    super(img, scale);
    //Setting images in array
    moveLeft = new PImage[3];
    moveLeft[0] = loadImage("spider1.png");
    moveLeft[1] = loadImage("spider2.png");
    moveLeft[2] = loadImage("spider3.png");
    moveRight = new PImage[3];
    moveRight[0] = loadImage("spider4.png");
    moveRight[1] = loadImage("spider5.png");
    moveRight[2] = loadImage("spider6.png");
    currentImages = moveRight;  
    direction = RIGHT_FACING;
    boundaryLeft = bLeft;
    boundaryRight = bRight;
    change_x = 2;
  }
  
  //Movement
  void update() {
    super.update();
    if (getLeft() <= boundaryLeft) {
      setLeft(boundaryLeft);
      change_x *= -1;
    } else if (getRight() >= boundaryRight) {
      setRight(boundaryRight);
      change_x *= -1;
    }
  }
}
