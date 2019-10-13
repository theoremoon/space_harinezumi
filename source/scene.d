module scene;

import std.algorithm;
import std.array;
import derelict.sdl2.sdl;
import gameobject;
import field;
import tag;

enum
{
    COLLIDE_TOP = 1,
    COLLIDE_BOTTOM = 2,
    COLLIDE_LEFT = 4,
    COLLIDE_RIGHT = 8,
}

/// check if a collides with b,
/// returns direction of b from a
auto checkCollision(SDL_Rect a, SDL_Rect b)
{
    auto res = 0;
    // BUG
    if (a.x >= b.x && a.x + a.w <= b.x)
    {
        res |= COLLIDE_RIGHT;
    }
    if (b.x >= a.x && b.x + b.w <= a.x)
    {
        res |= COLLIDE_RIGHT;
    }
    if (a.y >= b.y && a.y + a.h <= b.y)
    {
        res |= COLLIDE_BOTTOM;
    }
    if (b.y >= a.y && b.y + b.h <= a.y)
    {
        res |= COLLIDE_TOP;
    }
    return res;
}

auto collideInverse(int collide)
{
    auto inv = 0;
    if (collide & COLLIDE_TOP)
    {
        inv |= COLLIDE_BOTTOM;
    }
    if (collide & COLLIDE_BOTTOM)
    {
        inv |= COLLIDE_TOP;
    }
    if (collide & COLLIDE_LEFT)
    {
        inv |= COLLIDE_RIGHT;
    }
    if (collide & COLLIDE_RIGHT)
    {
        inv |= COLLIDE_LEFT;
    }
    return inv;
}

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
        auto fields = this.objects.filter!(o => o.tags.canFind(Tag.FIELD)).array;
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

        // check collision object and object
        auto objects = this.objects.filter!(o => o.tags.canFind(Tag.OBJECT)).array;
        foreach (i; 0 .. objects.length)
        {
            foreach (j; (i + 1) .. objects.length)
            {
                auto c = objects[i].rect.checkCollision(objects[j].rect);
                if (c)
                {
                    objects[i].onCollide(objects[j], c);
                    objects[j].onCollide(objects[i], c.collideInverse);
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
