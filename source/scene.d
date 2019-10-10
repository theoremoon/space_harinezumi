module scene;

import std.algorithm;
import std.array;
import derelict.sdl2.sdl;
import gameobject;
import field;

class Scene
{
private:
    GameObject[] objects; // objects in scene ordered by its priority
public:
    void addObject(GameObject obj)
    {
        objects ~= obj;
    }

    void update()
    {
        // update each objects
        foreach (o; this.objects.sort!((a, b) => a.level < b.level))
        {
            o.update();
        }

        // check collision with field
        auto fields = this.objects.filter!(o => o.tags.canFind("field")).array;
        assert(fields.length <= 1);
        if (fields.length == 1)
        {
            if (auto field = cast(Field)(fields[0]))
            {
                foreach (o; this.objects.sort!((a, b) => a.level < b.level))
                {
                    auto collision = field.checkCollision(o.rect);
                    if (collision)
                    {
                        o.onCollide(field, collision);
                    }
                }
            }
        }
    }

    void draw(SDL_Renderer* renderer)
    {
        foreach (o; this.objects.sort!((a, b) => a.level < b.level))
        {
            auto img = o.getImage();
            SDL_Texture* t = SDL_CreateTextureFromSurface(renderer, img.img);
            if (t is null)
            {
                // TODO: logging
                return;
            }
            SDL_RenderCopy(renderer, t, &img.src, &img.dst);
            SDL_DestroyTexture(t);
        }
    }
}
