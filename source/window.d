module window;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.string;
import gameobject;

class Window
{
private:
    static Window instance;

    SDL_Window* window;
    SDL_Renderer* renderer;
    uint width;
    uint height;
    const uint frame_rate = 60;
    const uint frame_ms = 1000 / frame_rate;
    uint last_tick;

    uint[256] keystate;

    this(string title, uint width, uint height)
    {
        // init SDL
        DerelictSDL2.load();
        DerelictSDL2Image.load();
        SDL_Init(SDL_INIT_EVERYTHING);
        IMG_Init(IMG_INIT_PNG);

        // create window, and default  renderer
        this.width = width;
        this.height = height;
        this.window = SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_ALLOW_HIGHDPI,);
        this.renderer = SDL_CreateRenderer(this.window, -1, SDL_RENDERER_ACCELERATED);
    }

    ~this()
    {
        SDL_DestroyRenderer(this.renderer);
        SDL_DestroyWindow(this.window);
        SDL_Quit();
    }

public:
    static void init(string title, uint width, uint height)
    {
        if (Window.instance !is null)
        {
            throw new Exception("Window has already been initialized");
        }
        Window.instance = new Window(title, width, height);
    }

    static void wait()
    {
        const now = SDL_GetTicks();
        const diff = now - instance.last_tick;
        instance.last_tick = now;
        if (instance.frame_ms > diff)
        {
            SDL_Delay(instance.frame_ms);
        }
    }

    /// Process Message
    static bool act()
    {
        Window.wait();
        SDL_Event e;
        while (SDL_PollEvent(&e) != 0)
        {
            switch (e.type)
            {
            case SDL_QUIT:
                return false;
            default:
                break;
            }
        }

        const state = SDL_GetKeyboardState(null);
        foreach (i, ref k; instance.keystate)
        {
            if (state[i])
            {
                k++;
            }
            else
            {
                k = 0;
            }
        }
        return true;
    }

    static uint key(long code)
    {
        return instance.keystate[code];
    }

    static void render()
    {
        SDL_RenderPresent(instance.renderer);
        SDL_RenderClear(instance.renderer);
    }

    static SDL_Renderer* getRenderer()
    {
        return instance.renderer;
    }

}
