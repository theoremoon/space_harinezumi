module gameobject;
import derelict.sdl2.sdl;
import std.typecons;
import tag;

struct Image
{
    SDL_Surface* img;
    SDL_Rect src;
    SDL_Rect dst;
}

interface GameObject
{
    void update();
    Image getImage();
    SDL_Rect rect();
    void onCollide(GameObject o, int direction);
    Tag[] tags();
    int level();
}
