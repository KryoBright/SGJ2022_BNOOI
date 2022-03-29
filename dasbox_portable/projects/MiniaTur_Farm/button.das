require daslib/media
require critrs

class buttonElement
    x:int
    y:int
    x_scale:int
    y_scale:int
    color:uint
    color_active:uint
    text:string
    pressed:bool
    id:int

    def drawSelf()
        rect(x, y, x_scale, y_scale, 0xFFFFFFFF)
        if (pressed)
            fill_rect(x+2, y+2, x_scale-4, y_scale-4, color_active)
            text_out(x+10, y+10, text, 0xFF000000)
        else
            fill_rect(x+2, y+2, x_scale-4, y_scale-4, color)
            text_out(x+10, y+10, text, 0xFFFFFFFF)
    
    def process()
        var mp = get_mouse_position()
        var mx = int(mp[0])
        var my = int(mp[1])
        if (mx>x)&&(mx<x+x_scale)
            if (my>y)&&(my<y+y_scale)
                pressed = true

    def reset()
        pressed = false

class toggleButtonElement: buttonElement

    def override process()
        var mp = get_mouse_position()
        var mx = int(mp[0])
        var my = int(mp[1])
        if (mx>x)&&(mx<x+x_scale)
            if (my>y)&&(my<y+y_scale)
                pressed = !pressed
    
    def override reset()
        return

class radioButtonElement: buttonElement

    otherButtons: array<buttonElement?>

    def override process() 
        var mp = get_mouse_position()
        var mx = int(mp[0])
        var my = int(mp[1])
        if (mx>x)&&(mx<x+x_scale)
            if (my>y)&&(my<y+y_scale)
                pressed = true
                var i = 0
                while (i< length(otherButtons))
                    otherButtons[i].pressed = false
                    i++
    
    def override reset()
        return

class shopButtonElement: buttonElement

    spec: critr?

    def override process()
        var mp = get_mouse_position()
        var mx = int(mp[0])
        var my = int(mp[1])
        if (mx>x)&&(mx<x+x_scale)
            if (my>y+id*y_scale)&&(my<y+y_scale+id*y_scale)
                pressed = true

    def override drawSelf()
        text = spec.name
        rect(x, y+id*y_scale, x_scale, y_scale, 0xFFFFFFFF)
        if (pressed)
            fill_rect(x+2, y+2+id*y_scale, x_scale-4, y_scale-4, color_active)
            text_out(x+10, y+10+id*y_scale, text, 0xFF000000)
        else
            fill_rect(x+2, y+2+id*y_scale, x_scale-4, y_scale-4, color)
            text_out(x+10, y+10+id*y_scale, text, 0xFFFFFFFF)

        var cl: array<uint> <- spec->getColors()
        var i = 0
        while ((i<length(cl))&&(i<99))
            fill_rect(x+2+i*2,y+40+id*y_scale,2,2,cl[i])
            i++
