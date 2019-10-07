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
        return data[y * width + x];
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
                        auto src = SDL_Rect(map.mapinfo.tilewidth * chipindex,
                                0, map.mapinfo.tilewidth, map.mapinfo.tileheight);
                        auto dst = SDL_Rect(map.mapinfo.tilewidth * x, map.mapinfo.tileheight * y,
                                map.mapinfo.tilewidth, map.mapinfo.tileheight);
                        SDL_BlitSurface(map.chipsurface, &src, this.mapsurface, &dst);
                    }
                }
            }
        }
    }

    void update()
    {
    }

    Image getImage()
    {

        SDL_Rect pos = SDL_Rect(0, 0, this.mapsurface.w, this.mapsurface.h);
        return Image(this.mapsurface, pos, pos);
    }
}
