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

class AssetLoader
{
public:
    SDL_Surface* loadImage(string path)
    {
        import std.string : toStringz;

        return IMG_Load(path.toStringz);
    }
}

class Sprite
{
private:
    SDL_Surface* img;
    uint sprite_width;
    uint animation_frame;
    uint current_frame;
public:
    this(SDL_Surface* img, uint sprite_width, uint animation_frame)
    {
        this.img = img;
        this.sprite_width = sprite_width;
        this.animation_frame = animation_frame;
        this.current_frame = 0;
    }

    int sprite_number()
    {
        return this.img.w / this.sprite_width;
    }

    /// Return sprite with empty dst
    Image getImage()
    {
        int x = this.sprite_width * cast(int)(
                (this.current_frame / this.animation_frame) % this.sprite_number);
        return Image(this.img, SDL_Rect(x, 0, this.sprite_width, this.img.h),
                SDL_Rect(0, 0, 0, 0));
    }

    /// step one frame
    void step(int count)
    {
        this.current_frame += count;
    }
}

class Player : GameObject
{
private:
    Sprite sprite;
    SDL_Rect rigid;
    int last_x;
    int last_y;
public:
    this(int x, int y, AssetLoader loader)
    {
        this.sprite = new Sprite(loader.loadImage("res/hog.png"), 32, 8);
        this.rigid = SDL_Rect(x, y, 32, 32);
    }

    override int level()
    {
        return 1;
    }

    override string[] tags()
    {
        return [];
    }

    /// task on every frame
    override void update()
    {
        this.sprite.step(1);
        this.last_x = this.rigid.x;
        this.last_y = this.rigid.y;

        if (Window.key(SDL_SCANCODE_LEFT) > 0)
        {
            this.rigid.x -= 3;
            this.sprite.step(5);
        }
        if (Window.key(SDL_SCANCODE_RIGHT) > 0)
        {
            this.rigid.x += 3;
            this.sprite.step(5);
        }

        this.rigid.y += 5;
    }

    override Image getImage()
    {
        auto img = this.sprite.getImage();
        img.dst = this.rigid;
        return img;
    }

    override SDL_Rect rect()
    {
        return this.rigid;
    }

    void onCollide(GameObject o, int direction)
    {
        // do nothing
        if (o.tags.canFind("field"))
        {
            if (direction & Field.COLLIDE_BOTTOM)
            {
                this.rigid.y = this.last_y;
            }
            if (direction & (Field.COLLIDE_RIGHT | Field.COLLIDE_LEFT))
            {
                this.rigid.x = this.last_x;
            }
        }
    }
}

void main()
{
    Window.init("Hedgehog", 800, 600);
    auto mainscene = new Scene();
    auto loader = new AssetLoader();
    mainscene.addObject(new Player(0, 0, loader));
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
