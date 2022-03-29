require daslib/media
require daslib/random
require daslib/fio

require genes
require critrs
require enclosure
require strings
require button

//options debugger            // uncomment for debug in VS Code
//require daslib/debug        // uncomment for debug in VS Code


var bits: array<bool>
var pos: int = 0
var seed:int4
var loop: int = 300
var loopAm: int = 2
var active = true
var save_file = fopen("savefile.txt","w")
var all_enclosures: array<enclosure?>
var all_buttons: array<buttonElement?>
var active_enclosure: enclosure?
var shop_buttons: array<shopButtonElement?>
var enclosure_position: int = 0
var enclosure_buttons: array<buttonElement?>

def readFileSection(var line:string;var startPos:int&)
    var i = startPos
    var section = ""
    while (i<length(line))&&(character_at(line,i)!=' ')
        if (character_at(line,i)!=' ')&&(character_at(line,i)!='\n')
            section = section + to_char(character_at(line,i))
        i = i + 1
    startPos = i + 1
    return section

def constructGene(var genomString:string;var startPos:int&)
    var r = readFileSection(genomString,startPos)
    while (startPos<length(genomString))&&(character_at(genomString,startPos)==' ')
        startPos=startPos+1
    var ac = getGeneByCode(r)
    if (r == "AGR")
        ac.first = constructGene(genomString,startPos)
        ac.second = constructGene(genomString,startPos)
    if (r == "CND")
        ac.outcome = constructGene(genomString,startPos)
    if (r == "LOP")
        ac.outcome = constructGene(genomString,startPos)
    return ac

var resGenom : array<Action?>

def constructGenome(var genomString:string)
    var i:int = 0
    var pos_i:int = 0
    while (i<5)
        push(resGenom,constructGene(genomString,pos_i))
        i = i + 1
    return <- resGenom

def createCustomCriter(var mutationString,genomString:string; var cr:critr?) 
    var pos_i:int = 0
    while (pos_i<length(mutationString))
        cr.unique_mutations[int(readFileSection(mutationString,pos_i))]=true
    pos_i = 0
    cr->consumeGenome(constructGenome(genomString),false,false,false)
    return <- cr

def setUpEnclosureCarousel()
    var i:int=0
    while (length(enclosure_buttons)>0) 
        erase(enclosure_buttons, 0)
        i=i+1
    i = 0
    while (i<5)
        if ((enclosure_position+i-2)>=0)&&((enclosure_position+i-2)<length(all_enclosures))
            var button = new buttonElement()
            button.x = 456 + 70*i
            button.y = 600
            button.x_scale = 50
            button.y_scale = 50
            button.color = 0xFF000000
            button.color_active = 0xFF008800
            button.text = string(enclosure_position+i-2)
            button.id = enclosure_position+i-2
            button.pressed = (i == 2)
            push(enclosure_buttons,button)
        i++
    var button = new buttonElement()
    button.x = 456 + 70*i
    button.y = 600
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "+"
    button.id = enclosure_position+i-2
    button.pressed = (i == 2)
    push(enclosure_buttons,button)
// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
/*    var genes_file = fopen("custom_gene.txt","r")
    var s1=fgets(genes_file)
    var s2=fgets(genes_file)+" TRM"
    var cr = createCustomCriter(s1,s2,new critr())
    cr.x_loc = 1
    cr.y_loc = 1*/
    randomize_seed(seed)
    seed_gene=seed
    seed_crit=seed
    seed_en=seed
    set_window_title("MiniaTur Farm")
    push(all_enclosures,new enclosure())
    active_enclosure = all_enclosures[0]

    var button = new buttonElement()
    button.x = 512
    button.y = 450
    button.x_scale = 200
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "Feed"
    button.id = 0
    push(all_buttons,button)

    button = new toggleButtonElement()
    button.x = 722
    button.y = 350
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "OM"
    button.id = 1
    push(all_buttons,button)

    var button1 = new radioButtonElement()
    button1.x = 722
    button1.y = 200
    button1.x_scale = 50
    button1.y_scale = 50
    button1.color = 0xFF000000
    button1.color_active = 0xFF008800
    button1.text = "MIN"
    button1.id = 2

    var button2 = new radioButtonElement()
    button2.x = 722
    button2.y = 250
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "MAX"
    button2.id = 3

    var button3 = new radioButtonElement()
    button3.x = 722
    button3.y = 300
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "AUTO"
    button3.id = 4
    button3.pressed = true

    push(button1.otherButtons,button2)
    push(button1.otherButtons,button3)
    push(button2.otherButtons,button1)
    push(button2.otherButtons,button3)
    push(button3.otherButtons,button2)
    push(button3.otherButtons,button1)

    push(all_buttons,button1)
    push(all_buttons,button2)
    push(all_buttons,button3)

    button1 = new radioButtonElement()
    button1.x = 452
    button1.y = 200
    button1.x_scale = 50
    button1.y_scale = 50
    button1.color = 0xFF000000
    button1.color_active = 0xFF008800
    button1.text = "RND"
    button1.id = 5

    button2 = new radioButtonElement()
    button2.x = 452
    button2.y = 250
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "O"
    button2.id = 6

    button3 = new radioButtonElement()
    button3.x = 452
    button3.y = 300
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "|O|"
    button3.id = 7
    
    var button4 = new radioButtonElement()
    button4.x = 452
    button4.y = 350
    button4.x_scale = 50
    button4.y_scale = 50
    button4.color = 0xFF000000
    button4.color_active = 0xFF008800
    button4.text = "CRN"
    button4.id = 8
    button4.pressed = true

    push(button1.otherButtons,button2)
    push(button1.otherButtons,button3)
    push(button2.otherButtons,button1)
    push(button2.otherButtons,button3)
    push(button3.otherButtons,button2)
    push(button3.otherButtons,button1)
    push(button4.otherButtons,button2)
    push(button4.otherButtons,button3)
    push(button4.otherButtons,button1)
    push(button1.otherButtons,button4)
    push(button2.otherButtons,button4)
    push(button3.otherButtons,button4)

    push(all_buttons,button1)
    push(all_buttons,button2)
    push(all_buttons,button3)
    push(all_buttons,button4)
    
    button = new toggleButtonElement()
    button.x = 512
    button.y = 140
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "|X|"
    button.id = 9
    push(all_buttons,button)

    button1 = new radioButtonElement()
    button1.x = 572
    button1.y = 140
    button1.x_scale = 50
    button1.y_scale = 50
    button1.color = 0xFF000000
    button1.color_active = 0xFF008800
    button1.text = "A$"
    button1.id = 10

    button2 = new radioButtonElement()
    button2.x = 622
    button2.y = 140
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "E$"
    button2.id = 11

    button3 = new radioButtonElement()
    button3.x = 672
    button3.y = 140
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "C$"
    button3.id = 12
    
    button4 = new radioButtonElement()
    button4.x = 722
    button4.y = 140
    button4.x_scale = 50
    button4.y_scale = 50
    button4.color = 0xFF000000
    button4.color_active = 0xFF008800
    button4.text = "No $"
    button4.id = 13
    button4.pressed = true

    push(button1.otherButtons,button2)
    push(button1.otherButtons,button3)
    push(button2.otherButtons,button1)
    push(button2.otherButtons,button3)
    push(button3.otherButtons,button2)
    push(button3.otherButtons,button1)
    push(button4.otherButtons,button2)
    push(button4.otherButtons,button3)
    push(button4.otherButtons,button1)
    push(button1.otherButtons,button4)
    push(button2.otherButtons,button4)
    push(button3.otherButtons,button4)

    push(all_buttons,button1)
    push(all_buttons,button2)
    push(all_buttons,button3)
    push(all_buttons,button4)

    var z = 0
    while (z<5)
        var sbutton = new shopButtonElement()
        sbutton.x = 10
        sbutton.y = 200
        sbutton.x_scale = 200
        sbutton.y_scale = 50
        sbutton.color = 0xFF000000
        sbutton.color_active = 0xFF008800
        sbutton.text = ""
        sbutton.id = z
        sbutton.spec = new critr()
        push(shop_buttons,sbutton)
        z++

    setUpEnclosureCarousel()
 /*   en = new enclosure()
    en -> addCritr(cr)
    en -> addRandCritersMess()
    en -> addFood(loopAm / 2)
    en1 = new enclosure()
    en1 -> addRandCritersMess()
    en1 -> addFood(loopAm / 2)
    en2 = new enclosure()
    en2 -> addRandCritersMess()
    en2 -> addFood(loopAm / 2)
    en3 = new enclosure()
    en3 -> addRandCritersMess()
    en3 -> addFood(loopAm / 2)
    return
*/

var deltaT:float = 1f
var mouseCd = 0
// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    deltaT = deltaT + dt
    if (mouseCd>0)
        mouseCd--
    if (deltaT>1f/60f)
        if (active_enclosure!=null)
            active_enclosure.mut_incr=all_buttons[9].pressed
            if (active)
                active_enclosure->act()
            var i=0
            while (i<length(all_buttons))
                all_buttons[i]->reset()
                i++
            i=0
            while (i<length(shop_buttons))
                shop_buttons[i]->reset()
                shop_buttons[i].id = i
                i++
            i=0
            while (i<length(enclosure_buttons))
                enclosure_buttons[i]->reset()
                i++
            if (get_mouse_button(MB_LEFT)&&(mouseCd==0))
                mouseCd = 20
                i=0
                while (i<length(all_buttons))
                    all_buttons[i]->process()
                    i++
                i=0
                while (i<length(shop_buttons))
                    shop_buttons[i]->process()
                    i++
                
                i=0
                while (i<length(enclosure_buttons))
                    enclosure_buttons[i]->process()
                    i++

            if (all_buttons[2].pressed)
                loopAm = 15
            if (all_buttons[3].pressed)
                loopAm = 1
            
            var strat = 0
            if (all_buttons[5].pressed)
                strat = 0
            if (all_buttons[6].pressed)
                strat = 1
            if (all_buttons[7].pressed)
                strat = 2
            if (all_buttons[8].pressed)
                strat = 3

            if (all_buttons[0].pressed)
                active_enclosure->addFood(loopAm,strat) 
                if (all_buttons[4].pressed)
                    var critAm = active_enclosure->getAmount()
                    if (critAm<20)&&(loopAm>1)
                        loopAm--
                    else 
                        if (critAm>30)&&(loopAm<15)
                            loopAm++
            if (!all_buttons[1].pressed)&&(active)
                loop++
                if (loop>300)
                    active_enclosure->addFood(loopAm,strat)
                    loop = 0     
                    if (all_buttons[4].pressed)
                        var critAm = active_enclosure->getAmount()
                        if (critAm<20)&&(loopAm>1)
                            loopAm--
                        else 
                            if (critAm>30)&&(loopAm<15)
                                loopAm++
            if (all_buttons[10].pressed)
                active_enclosure->sell(0)
            if (all_buttons[11].pressed)
                active_enclosure->sell(1)
            if (all_buttons[12].pressed)
                active_enclosure->sell(2)

            i = 0
            while (i<length(shop_buttons))
                if (shop_buttons[i].pressed)
                    var cr = shop_buttons[i].spec
                    cr.x_loc = random_int(seed)%50
                    cr.y_loc = random_int(seed)%50
                    active_enclosure->addCritr(cr)
                    erase(shop_buttons,i)
                    var sbutton = new shopButtonElement()
                    sbutton.x = 10
                    sbutton.y = 200
                    sbutton.x_scale = 200
                    sbutton.y_scale = 50
                    sbutton.color = 0xFF000000
                    sbutton.color_active = 0xFF008800
                    sbutton.text = ""
                    sbutton.id = 4
                    sbutton.spec = new critr()
                    push(shop_buttons,sbutton)
                i++
            
            i = 0
            while (i<length(enclosure_buttons))
                if (enclosure_buttons[i].pressed)
                    /*if (enclosure_position>1)*/

                    enclosure_position=enclosure_buttons[i].id
                    debug(enclosure_position,"en")
                   /* else
                        enclosure_position=enclosure_buttons[i].id*/ 
                i++
        deltaT=0f

    var msd=int(get_mouse_scroll_delta())+enclosure_position
    if (msd<0)
        msd = 0
    if (msd<length(all_enclosures))
        active_enclosure =all_enclosures[msd]
    else
        push(all_enclosures,new enclosure())
        active_enclosure = all_enclosures[length(all_enclosures)-1]
        msd=length(all_enclosures)-1
    enclosure_position=msd
    setUpEnclosureCarousel()
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    if get_key(VK_R)
        loopAm = 0
    if get_key(VK_SPACE)
        active = !active
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    var en_x=512
    rect(en_x, 200, 200, 200, 0xFFF0F0F0)

    if (active_enclosure!=null)
        var i:int = 0
        while (i<length(active_enclosure.foodMap))
            if (active_enclosure.foodMap[i])
                rect(en_x+(i%50)*4,200+(i/50)*4,4,4,0xFF00FF00)
            i++
        i=0
        while (i<length(active_enclosure.criters))
            var crit = active_enclosure.criters[i]
            rect(en_x+crit.x_loc*4,200+crit.y_loc*4,4,4,crit.color)
            i++
        i=0
        while (i<length(all_buttons))
            all_buttons[i]->drawSelf()
            i++
        i=0
        while (i<length(shop_buttons))
            shop_buttons[i]->drawSelf()
            i++
        i=0
        while (i<length(enclosure_buttons))
            enclosure_buttons[i]->drawSelf()
            i++
    return