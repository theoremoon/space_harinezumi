module gameobject;
import derelict.sdl2.sdl;
import std.typecons;

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
}
