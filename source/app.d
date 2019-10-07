import std.stdio;
import std.file;
import asdf;
import window;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import gameobject;
import field;

class Sprite : GameObject
{
private:
    SDL_Surface* img;

    int width; /// width of one sprite image
    int number; /// number of images in a sprite
    int speed; /// animation speed
    long counter;

    int x; /// x position
    int y; /// y position
public:
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
        if (Window.key(SDL_SCANCODE_LEFT) > 0)
        {
            this.x--;
            this.counter += 5;
        }
        if (Window.key(SDL_SCANCODE_RIGHT) > 0)
        {
            this.x++;
            this.counter += 5;
        }
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
}

void main()
{
    Window.init("Hedgehog", 800, 600);
    auto player = new Sprite(0, 0, IMG_Load("res/hog.png"), 32, 60);
    auto field = new Field(Map(IMG_Load("res/chipset.png"), readText("res/maps/map1.json")
            .deserialize!MapInfo, readText("res/chips/chip1.json").deserialize!(ChipInfo[])));
    while (Window.act())
    {
        if (Window.key(SDL_SCANCODE_Q))
        {
            break;
        }
        player.update();
        field.update();
        Window.draw(field);
        Window.draw(player);
        Window.render();
    }
}
