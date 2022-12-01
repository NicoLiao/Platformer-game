//General player attributes
final static float MOVE_SPEED = 5;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = 0.6;
final static float JUMP_SPEED = 15;

//Direction
final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;

//Size
final static float WIDTH = SPRITE_SIZE * 16;
final static float HEIGHT = SPRITE_SIZE * 12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

//Margin
final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

//Declaration of entities
PImage snow, crate, red_brick, brown_brick, gold, spider, p;
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
ArrayList<Sprite> enemies;
float fastesttime = 999999;
Enemy enemy;
Player player;
float view_x;
float view_y;
boolean isGameOver;
int numCoins;
long startTime;
long elapsedTime;

//Initialization
void setup() {
  size(800, 600);
  imageMode(CENTER);

  platforms = new ArrayList<Sprite>();
  coins = new ArrayList<Sprite>();
  enemies = new ArrayList<Sprite>();
  numCoins = 0;
  isGameOver = false;

  p = loadImage("player.png");
  player = new Player(p, 0.8);
  //player.setBottom(GROUND_LEVEL);
  player.center_x = 100;
  player.change_y = GROUND_LEVEL;

  //Images load
  spider = loadImage("spider1.png");
  gold = loadImage("gold1.png");
  red_brick = loadImage("red_brick.png");
  brown_brick = loadImage("brown_brick.png");
  crate = loadImage("crate.png");
  snow = loadImage("snow.png");
  createPlatforms("map.csv");
  view_x = 0;
  view_y = 0;
  startTime = System.currentTimeMillis();
}

//Building platforms
//Different numbers represent different structure
void createPlatforms(String filename) {
  String[] lines = loadStrings(filename);
  for (int row = 0; row < lines.length; row++) {
    String[] values = split(lines[row], ",");
    for (int col = 0; col < values.length; col++) {
      if (values[col].equals("1")) {
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col*SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row*SPRITE_SIZE;
        platforms.add(s);
      } else if (values[col].equals("2")) {
        Sprite s = new Sprite(snow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col*SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row*SPRITE_SIZE;
        platforms.add(s);
      } else if (values[col].equals("3")) {
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col*SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row*SPRITE_SIZE;
        platforms.add(s);
      } else if (values[col].equals("4")) {
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col*SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row*SPRITE_SIZE;
        platforms.add(s);
      } else if (values[col].equals("5")) {
        Coin c = new Coin(gold, SPRITE_SCALE);
        c.center_x = SPRITE_SIZE/2 + col*SPRITE_SIZE;
        c.center_y = SPRITE_SIZE/2 + row*SPRITE_SIZE;
        coins.add(c);
      } else if (values[col].equals("6")) {
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + 4*SPRITE_SIZE;
        enemy = new Enemy(spider, 50/72.0, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col*SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row*SPRITE_SIZE;
        enemies.add(enemy);
      }
    }
  }
}

//Draw background and text
void draw() {
  background(255);
  scroll();
  displayAll();
  if (!isGameOver) {
    updateAll();
    collectCoins();
    elapsedTime = System.currentTimeMillis() - startTime;
    text("Time: " + elapsedTime/1000.0 + "s", view_x + 50, view_y + 150);
  }
}

//Update enemies and coins states
void updateAll() {
  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  for (Sprite enemy : enemies) {
    enemy.update();
    ((AnimatedSprite)enemy).updateAnimation();
  }
  collectCoins();
  checkDeath();
}

//Let screen follow player
void scroll() {
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if (player.getRight() > right_boundary) {
    view_x += player.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if (player.getLeft() < left_boundary) {
    view_x -= left_boundary - player.getLeft();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if (player.getBottom() > bottom_boundary) {
    view_y += player.getBottom() - bottom_boundary;
  }
  float top_boundary = view_y + VERTICAL_MARGIN;
  if (player.getTop() < top_boundary) {
    view_y -= top_boundary -player.getTop();
  }
  translate(-view_x, -view_y);
}

//Display coins and enemies
void displayAll() {
  player.display();

  for (Sprite s : platforms)
    s.display();

  for (Sprite c : coins) {
    c.display();
    ((AnimatedSprite)c).updateAnimation();
  }
  for (Sprite enemy : enemies) {
    enemy.display();
    ((AnimatedSprite)enemy).updateAnimation();
  }
  fill(255, 0, 0);
  textSize(32);
  
  //Text coins lives and time
  text("Coin:" + numCoins, view_x + 50, view_y + 50);
  text("Lives:" + player.lives, view_x + 50, view_y + 100);
  text("Fastest time: " + fastesttime + "s", view_x + 50, view_y + 200);



  //GameOver condition
  if (isGameOver) {
    fill(0, 0, 255);
    text("GAME OVER!", view_x + width/2 - 100, view_y + height/2);
    if (player.lives == 0)
      text("You lose!", view_x + width/2 - 100, view_y + height/2 + 50);
    else
    text("You win!", view_x + width/2 - 100, view_y + height/2 + 50);
    text("Press R to restart!", view_x + width/2 - 100, view_y + height/2 + 100);
    text("Elapsed seconds: " + elapsedTime/1000.0 + "s", view_x + width/2 - 100, view_y + height/2 + 150);
  }
}

//Collect coins
void collectCoins() {
  ArrayList<Sprite> coin_list = checkCollisionList(player, coins);
  if (coin_list.size()>0) {
    for (Sprite coin : coin_list) {
      numCoins++;
      coins.remove(coin);
    }
  }
  if (coins.size() == 0) {
    elapsedTime = System.currentTimeMillis() - startTime;
    if (elapsedTime/1000.0 < fastesttime) {
      fastesttime = elapsedTime/1000.0;
    }
    isGameOver = true;
  }
}

//Death condition
void checkDeath() {
  ArrayList<Sprite> enemy_list = checkCollisionList(player, enemies);
  boolean fallOffCliff = player.getBottom()> GROUND_LEVEL;
  if (enemy_list.size()>0 || fallOffCliff) {
    player.lives--;
    if (player.lives == 0) {
      isGameOver = true;
    } else {
      player.center_x = 100;
      player.setBottom(GROUND_LEVEL);
    }
  }
}

//Check if player is on platforms
public boolean isOnPlatforms (Sprite s, ArrayList<Sprite> walls) {
  s.center_y += 5;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  s.center_y -= 5;
  if (col_list.size() > 0) {
    return true;
  } else return false;
}

//Collision against wall
public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls) {
  s.change_y += GRAVITY;
  s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    if (s.change_y > 0) {
      s.setBottom(collided.getTop());
    } else if (s.change_y < 0) {
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }
  s.center_x += s.change_x;
  col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    if (s.change_x > 0) {
      s.setRight(collided.getLeft());
    } else if (s.change_x < 0) {
      s.setLeft(collided.getRight());
    }
    s.change_y = 0;
  }
}

//Collision against enemies
boolean checkCollision(Sprite s1, Sprite s2) {
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if (noXOverlap || noYOverlap) {
    return false;
  } else {
    return true;
  }
}

//Collision against multiple enemies
public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list) {
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for (Sprite p : list) {
    if (checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}

//Check key pressed
void keyPressed() {
  if (keyCode == RIGHT) {
    player.change_x = MOVE_SPEED;
  } else if (keyCode == LEFT) {
    player.change_x = -MOVE_SPEED;
  } else if (key == ' ' && isOnPlatforms (player, platforms)) {
    player.change_y = -JUMP_SPEED;
  } else if (isGameOver && key == 'r')
    setup();
}

//Check key released
void keyReleased() {
  if (keyCode == RIGHT) {
    player.change_x = 0;
  } else if (keyCode == LEFT) {
    player.change_x = 0;
  } else if (keyCode == UP) {
    player.change_y = 0;
  } else if (keyCode == DOWN) {
    player.change_y = 0;
  }
}
