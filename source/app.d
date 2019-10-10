import std.stdio;
import std.file;
import std.algorithm;
import asdf;
import window;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import gameobject;
import scene;
import field;

class Sprite : GameObject
{
private:
    SDL_Surface* img;

    int width; /// width of one sprite image
    int number; /// number of images in a sprite
    int speed; /// animation speed
    long counter;

    int last_x;
    int last_y;

public:
    int x; /// x position
    int y; /// y position
    this(int x, int y, SDL_Surface* img, int width, int speed)
    {
        this.img = img;
        this.number = img.w / width;
        this.width = width;
        this.speed = speed;
        this.counter = 0;

        this.x = x;
        this.y = y;
    }

    void update()
    {
        this.last_x = x;
        this.last_y = y;
        if (Window.key(SDL_SCANCODE_LEFT) > 0)
        {
            this.x -= 3;
            this.counter += 5;
        }
        if (Window.key(SDL_SCANCODE_RIGHT) > 0)
        {
            this.x += 3;
            this.counter += 5;
        }
        this.y += 5;
        this.counter++;
    }

    Image getImage()
    {
        SDL_Rect src;
        src.x = this.width * cast(int)((this.counter / this.speed) % this.number);
        src.y = 0;
        src.w = this.width;
        src.h = this.img.h;

        SDL_Rect dst;
        dst.x = this.x;
        dst.y = this.y;
        dst.w = this.width;
        dst.h = this.img.h;
        return Image(this.img, src, dst);
    }

    int level()
    {
        return 1;
    }

    string[] tags()
    {
        return [];
    }

    SDL_Rect rect()
    {
        return SDL_Rect(this.x, this.y, this.width, this.img.h);
    }

    void onCollide(GameObject o, int direction)
    {
        if (o.tags.canFind("field"))
        {
            if (direction & Field.COLLIDE_BOTTOM)
            {
                this.y = this.last_y;
            }
            if (direction & (Field.COLLIDE_RIGHT | Field.COLLIDE_LEFT))
            {
                this.x = this.last_x;
            }
        }
        else
        {
        }
    }
}

void main()
{
    Window.init("Hedgehog", 800, 600);
    auto mainscene = new Scene();
    mainscene.addObject(new Sprite(0, 0, IMG_Load("res/hog.png"), 32, 60));
    mainscene.addObject(new Field(Map(IMG_Load("res/chipset.png"), readText("res/maps/map1.json")
            .deserialize!MapInfo, readText("res/chips/chip1.json").deserialize!(ChipInfo[]))));
    while (Window.act())
    {
        if (Window.key(SDL_SCANCODE_Q))
        {
            break;
        }
        mainscene.update();
        mainscene.draw(Window.getRenderer);
        Window.render();
    }
}
