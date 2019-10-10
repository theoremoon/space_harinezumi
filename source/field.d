module field;
import gameobject;
import derelict.sdl2.sdl;

struct MapLayer
{
public:
    int[] data;
    int width;
    int height;

    int opIndex(int y, int x) const pure
    {
        auto p = y * width + x;
        if (p < 0 || data.length <= p)
        {
            return -1;
        }
        return data[p];
    }
}

struct MapInfo
{
public:
    uint width;
    uint height;
    uint tilewidth;
    uint tileheight;
    MapLayer[] layers;

    uint mapwidth() const pure
    {
        return this.width * this.tilewidth;
    }

    uint mapheight() const pure
    {
        return this.height * this.tileheight;
    }
}

struct ChipInfo
{
public:
    bool rigid;
}

struct Map
{
public:
    SDL_Surface* chipsurface;
    MapInfo mapinfo;
    ChipInfo[] chipinfo;
public:
    this(SDL_Surface* chipsurface, MapInfo mapinfo, ChipInfo[] chipinfo)
    {
        this.chipsurface = chipsurface;
        this.mapinfo = mapinfo;
        this.chipinfo = chipinfo;
    }
}

class Field : GameObject
{
private:
    SDL_Surface* mapsurface;
    Map map;

    auto tileheight() const pure
    {
        return this.map.mapinfo.tileheight;
    }

    auto tilewidth() const pure
    {
        return this.map.mapinfo.tilewidth;
    }

public:
    this(Map map)
    {
        this.map = map;
        this.mapsurface = SDL_CreateRGBSurface(0, map.mapinfo.mapwidth,
                map.mapinfo.mapheight, 32, 0, 0, 0, 0);

        foreach (layer; map.mapinfo.layers)
        {
            foreach (y; 0 .. map.mapinfo.height)
            {
                foreach (x; 0 .. map.mapinfo.width)
                {
                    auto chipindex = layer[y, x];
                    if (chipindex > 0)
                    {
                        chipindex--;
                        auto src = SDL_Rect(this.tilewidth * chipindex, 0,
                                this.tilewidth, this.tileheight);
                        auto dst = SDL_Rect(this.tilewidth * x,
                                this.tileheight * y, this.tilewidth, this.tileheight);
                        SDL_BlitSurface(map.chipsurface, &src, this.mapsurface, &dst);
                    }
                }
            }
        }
    }

    void update()
    {
    }

    void onCollide(GameObject o, int direction)
    {
    }

    Image getImage()
    {
        SDL_Rect pos = SDL_Rect(0, 0, this.mapsurface.w, this.mapsurface.h);
        return Image(this.mapsurface, pos, pos);
    }

    SDL_Rect rect()
    {
        return SDL_Rect();
    }

    int level()
    {
        return -1;
    }

    string[] tags()
    {
        return ["field"];
    }

    enum
    {
        COLLIDE_TOP = 1,
        COLLIDE_BOTTOM = 2,
        COLLIDE_LEFT = 4,
        COLLIDE_RIGHT = 8,
    }

    /// check collision for rect and map
    auto checkCollision(SDL_Rect rect)
    {
        // get overlapping chips
        int y_start = rect.y / this.tileheight;
        int y_end = (rect.y + rect.h) / this.tileheight;
        int x_start = rect.x / this.tilewidth;
        int x_end = (rect.x + rect.w) / this.tilewidth;

        uint r = 0;
        foreach (l; this.map.mapinfo.layers)
        {
            foreach (x; x_start .. x_end)
            {

                auto chip = l[y_start, x];
                if (chip > 0)
                {
                    r |= COLLIDE_TOP;
                }

                chip = l[y_end, x];
                if (chip > 0)
                {
                    r |= COLLIDE_BOTTOM;
                }

                if (r & (COLLIDE_TOP | COLLIDE_BOTTOM))
                {
                    break;
                }
            }
            foreach (y; y_start .. y_end)
            {
                auto chip = l[y, x_start];
                if (chip > 0)
                {
                    r |= COLLIDE_LEFT;
                }

                chip = l[y, x_end];
                if (chip > 0)
                {
                    r |= COLLIDE_RIGHT;
                }
                if (r & (COLLIDE_LEFT | COLLIDE_RIGHT))
                {
                    break;
                }
            }
        }
        return r;
    }
}
