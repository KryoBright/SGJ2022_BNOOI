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
var shelf_buttons: array<shelfButtonElement?>
var energy_amount:int = 6070
var chosen_crit:critr?
var lost = false

//Images
var image_bodies: ImageHandle <- create_managed_image("sprites/Creature_body_2.png")
var image_limbs: ImageHandle <- create_managed_image("sprites/Creature_limb.png")
var image_buttons: ImageHandle <- create_managed_image("sprites/Button.png")
var image_feed: ImageHandle <- create_managed_image("sprites/Button_feed.png")
var image_pause: ImageHandle <- create_managed_image("sprites/Pause.png")
var image_energy: ImageHandle <- create_managed_image("sprites/Energy.png")
var image_reset: ImageHandle <- create_managed_image("sprites/Reset.png")

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
    if (r == "ARA")
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

def createCustomCriter(var cr:critr?; var fname:string;var number:int) 
    var genes_file = fopen(fname,"r")
    var name=fgets(genes_file)
    var s1=fgets(genes_file)
    var s2=fgets(genes_file)+" TRM"
    var i = 1
    while (i<number)
        name=fgets(genes_file)
        s1=fgets(genes_file)
        s2=fgets(genes_file)+" TRM"
        i++
    var pos_i:int = 0
    while (pos_i<length(s1))
        cr.unique_mutations[int(readFileSection(s1,pos_i))]=true
    pos_i = 0
    var clrT=uint(random_int(seed_crit)%255+(random_int(seed_crit)%255)*256+(random_int(seed_crit)%255)*256*256+255*16777216)
    cr->consumeGenome(constructGenome(s2),e_arr,clrT,false,false,false,0,0)
    cr.name = name

    var base:string = "Base"
    cr.domainName = name
    cr.specName = base
    cr.idName = "001"
   // cr.name = "0001" 
    fclose(genes_file)
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

def drawInfoWindow(var spec: critr?)
    rect(900,0,400,900,0xFFFFFFFF)
    rect(900,0,150,150,0xFFFFFFFF)
    fill_rect(902,2,146,146,0xFF333333)
    enable_alpha_blend()
    make_image_color_transparent(image_bodies,0xFFFFFFFF)
    make_image_color_transparent(image_limbs,0xFFFFFFFF)
    draw_image_region(image_limbs,925f,25f,float4(50*(spec.phenotype_body[4]%18),200*(spec.phenotype_body[4]/18),50,50),spec.phenotype_body_color)
    draw_image_region(image_limbs,975f,25f,float4(50*(spec.phenotype_body[5]%18),50 + 200*(spec.phenotype_body[5]/18),50,50),spec.phenotype_body_color)
    draw_image_region(image_limbs,975f,75f,float4(50*(spec.phenotype_body[6]%18),100 + 200*(spec.phenotype_body[6]/18),50,50),spec.phenotype_body_color)
    draw_image_region(image_limbs,925f,75f,float4(50*(spec.phenotype_body[7]%18),150 + 200*(spec.phenotype_body[7]/18),50,50),spec.phenotype_body_color)
    
    draw_image_region(image_bodies,950f,50f,float4(25*(spec.phenotype_body[0]%18),100*(spec.phenotype_body[0]/18),25,25),spec.phenotype_body_color)
    draw_image_region(image_bodies,975f,50f,float4(25*(spec.phenotype_body[1]%18),25 + 100*(spec.phenotype_body[1]/18),25,25),spec.phenotype_body_color)
    draw_image_region(image_bodies,975f,75f,float4(25*(spec.phenotype_body[2]%18),50 + 100*(spec.phenotype_body[2]/18),25,25),spec.phenotype_body_color)
    draw_image_region(image_bodies,950f,75f,float4(25*(spec.phenotype_body[3]%18),75 + 100*(spec.phenotype_body[3]/18),25,25),spec.phenotype_body_color)
    
    text_out(1070,50,spec.domainName,0xFFFFFFFF)
    text_out(1070,85,spec.specName,0xFFFFFFFF)
    text_out(1070,120,spec->getInd(),0xFFFFFFFF)
    text_out(920,170,"Age:"+string(spec.lifetime),0xFFFF0000)
    text_out(990,170,"Cost:"+string(spec->getCost()),0xFF00FF00)
    text_out(1130,170,"Avrg.EP:"+string(float(spec.total_energy)/float(spec.lifetime)),0xFFa0a0FF)
    text_out(920,210,"Genome:",0xFFFF00FF)
    var cl: array<uint> <- spec->getColors()
    var i = 0
    while ((i<length(cl)))
        fill_rect(904+(i%80)*4,240+(i/80)*4,4,4,cl[i])
        i++
    var d = 0
    i=0
    text_out(920,270,"Unique mutations:",0xFFFFFF00)
    while (i<length(spec.unique_mutations))
        if (spec.unique_mutations[i])
            text_out(920,300+d*20,convertUMtoName(i),0xFFFFFF00)
            d++
        i++
    var en_x = 637-active_enclosure.lin_size*2
    var en_y = 325-active_enclosure.lin_size*2
    rect(en_x-6+spec.x_loc*4,en_y-6+spec.y_loc*4,16,16,0xFFFFFF00)

def drawMiniInfoWindow(var spec: critr?; var x,y:float)
    rect(int(x),int(y),400,150,0xFFFFFFFF)
    fill_rect(int(x)-1,int(y)+1,398,148,0xFF000000)
    rect(int(x),int(y),150,150,0xFFFFFFFF)
    fill_rect(int(x)+2,int(y)+2,146,146,0xFF333333)
    enable_alpha_blend()
    make_image_color_transparent(image_bodies,0xFFFFFFFF)
    make_image_color_transparent(image_limbs,0xFFFFFFFF)
    draw_image_region(image_limbs,x+25f,y+25f,float4(50*(spec.phenotype_body[4]%18),200*(spec.phenotype_body[4]/18),50,50),spec.phenotype_body_color)
    draw_image_region(image_limbs,x+75f,y+25f,float4(50*(spec.phenotype_body[5]%18),50 + 200*(spec.phenotype_body[5]/18),50,50),spec.phenotype_body_color)
    draw_image_region(image_limbs,x+75f,y+75f,float4(50*(spec.phenotype_body[6]%18),100 + 200*(spec.phenotype_body[6]/18),50,50),spec.phenotype_body_color)
    draw_image_region(image_limbs,x+25f,y+75f,float4(50*(spec.phenotype_body[7]%18),150 + 200*(spec.phenotype_body[7]/18),50,50),spec.phenotype_body_color)
    
    draw_image_region(image_bodies,x+50f,y+50f,float4(25*(spec.phenotype_body[0]%18),100*(spec.phenotype_body[0]/18),25,25),spec.phenotype_body_color)
    draw_image_region(image_bodies,x+75f,y+50f,float4(25*(spec.phenotype_body[1]%18),25 + 100*(spec.phenotype_body[1]/18),25,25),spec.phenotype_body_color)
    draw_image_region(image_bodies,x+75f,y+75f,float4(25*(spec.phenotype_body[2]%18),50 + 100*(spec.phenotype_body[2]/18),25,25),spec.phenotype_body_color)
    draw_image_region(image_bodies,x+50f,y+75f,float4(25*(spec.phenotype_body[3]%18),75 + 100*(spec.phenotype_body[3]/18),25,25),spec.phenotype_body_color)
    
    text_out(int(x)+170,int(y)+50,spec.domainName,0xFFFFFFFF)
    text_out(int(x)+170,int(y)+85,spec.specName,0xFFFFFFFF)
    text_out(int(x)+170,int(y)+120,spec->getInd(),0xFFFFFFFF)
    var en_x = 637-active_enclosure.lin_size*2
    var en_y = 325-active_enclosure.lin_size*2
    rect(en_x-6+spec.x_loc*4,en_y-6+spec.y_loc*4,16,16,0xFF00FFFF)

def drawEnergy()
    var en = energy_amount
    var postf = ""
    if (en>10000)
        en = en/1000
        postf = "K"
        if (en>10000)
            en = en/1000
            postf = "M"
    text_out(320,20,"E:"+string(en)+postf,0xFFFFFF00)
    draw_image_region(image_energy,290f,15f,float4(0,0,20,30))
    if (lost)
        text_out(320,40,"You have lost!\nWe allow you to keep playing tho.",0xFFFF0000)

def saveGenome(var spec:critr?)
    if (spec!=null)
        var g_file=fopen("genomes/genome_"+spec.name+".txt","w")
        var r = ""
        var i = 0
        while (i<length(spec.genome))
            r = r + spec.genome[i]->getDescription()+" "
            i++
        fprint(g_file,r)
        fclose(g_file)


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
    set_window_title("BNOOI")
    push(all_enclosures,new enclosure())
    active_enclosure = all_enclosures[0]

    var button = new feedButtonElement()
    button.x = 512
    button.y = 450
    button.x_scale = 200
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "Feed"
    button.id = 0
    button.ih = image_feed
    button.img_index = 1
    button.hover_text = "Manually feed creatures"
    push(all_buttons,button)

    button = new toggleButtonElement()
    button.x = 722
    button.y = 450
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "OM"
    button.id = 1
    button.ih = image_buttons
    button.img_index = 8
    button.hover_text = "Feed creatures on schedule"
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
    button1.ih = image_buttons
    button1.hover_text = "Minimise amount of food"
    button1.img_index = 5

    var button2 = new radioButtonElement()
    button2.x = 722
    button2.y = 250
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "MAX"
    button2.id = 3
    button2.ih = image_buttons
    button2.hover_text = "Maximise amount of food"
    button2.img_index = 6

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
    button3.ih = image_buttons
    button3.hover_text = "Amount of food is relative \n to number of creatures"
    button3.img_index = 7

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
    button1.ih = image_buttons
    button1.img_index = 1
    button1.hover_text = "Randomise feeding pattern"

    button2 = new radioButtonElement()
    button2.x = 452
    button2.y = 250
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "O"
    button2.id = 6
    button2.ih = image_buttons
    button2.img_index = 2
    button2.hover_text = "Place food in circle pattern"

    button3 = new radioButtonElement()
    button3.x = 452
    button3.y = 300
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "|O|"
    button3.id = 7
    button3.ih = image_buttons
    button3.img_index = 3
    button3.hover_text = "Place food in inverse circle pattern"
    
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
    button4.ih = image_buttons
    button4.img_index = 4
    button4.hover_text = "Place food in two opposing corners"
    
    var button5 = new radioButtonElement()
    button5.x = 452
    button5.y = 400
    button5.x_scale = 50
    button5.y_scale = 50
    button5.color = 0xFF000000
    button5.color_active = 0xFF008800
    button5.text = "IMG"
    button5.id = 8
    button5.pressed = false
    button5.hover_text = "Place food according to image file"

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

    push(button5.otherButtons,button2)
    push(button5.otherButtons,button3)
    push(button5.otherButtons,button4)
    push(button5.otherButtons,button1)
    push(button1.otherButtons,button5)
    push(button2.otherButtons,button5)
    push(button4.otherButtons,button5)
    push(button3.otherButtons,button5)

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
    button.ih = image_buttons
    button.img_index = 13
    button.hover_text = "Induce mutations"
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
    button1.ih = image_buttons
    button1.img_index = 9
    button1.hover_text = "Autosell oldest creatures"

    button2 = new radioButtonElement()
    button2.x = 622
    button2.y = 140
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "E$"
    button2.id = 11
    button2.ih = image_buttons
    button2.img_index = 10
    button2.hover_text = "Autosell most expensive creatures"

    button3 = new radioButtonElement()
    button3.x = 672
    button3.y = 140
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "C$"
    button3.id = 12
    button3.ih = image_buttons
    button3.hover_text = "Autosell cheapest creatures"
    button3.img_index = 11
    
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
    button4.ih = image_buttons
    button4.img_index = 12
    button4.hover_text = "Disable autosell"

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

    button = new buttonElement()
    button.x = 950
    button.y = 500
    button.x_scale = 300
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "^Shelve^"
    button.id = 14
    push(all_buttons,button)

    button = new buttonElement()
    button.x = 950
    button.y = 580
    button.x_scale = 300
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008800
    button.text = "Save genome to file"
    button.id = 15
    push(all_buttons,button)

    button = new toggleButtonElement()
    button.x = 50
    button.y = 50
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008844
    button.text = "||"
    button.id = 16
    button.ih = image_pause
    button.img_index = 1
    button.hover_text = "Pause / Resume"
    push(all_buttons,button)

    button = new buttonElement()
    button.x = 105
    button.y = 50
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008844
    button.text = "R"
    button.id = 17
    button.ih = image_reset
    button.img_index = 1
    button.hover_text = "Reset"
    push(all_buttons,button)

    button1 = new radioButtonElement()
    button1.x = 210
    button1.y = 200
    button1.x_scale = 50
    button1.y_scale = 50
    button1.color = 0xFF000000
    button1.color_active = 0xFF008800
    button1.text = "S"
    button1.pressed = true
    button1.id = 18
    button1.hover_text = "Small enclosure"

    button2 = new radioButtonElement()
    button2.x = 210
    button2.y = 250
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "L"
    button2.id = 19
    button2.hover_text = "Average enclosure"

    button3 = new radioButtonElement()
    button3.x = 210
    button3.y = 300
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "XL"
    button3.id = 20
    button3.hover_text = "Big enclosure"

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
    button1.x = 260
    button1.y = 200
    button1.x_scale = 50
    button1.y_scale = 50
    button1.color = 0xFF000000
    button1.color_active = 0xFF008800
    button1.text = "x50"
    button1.pressed = true
    button1.id = 21
    button1.hover_text = "Limit to 50 creatures"

    button2 = new radioButtonElement()
    button2.x = 260
    button2.y = 250
    button2.x_scale = 50
    button2.y_scale = 50
    button2.color = 0xFF000000
    button2.color_active = 0xFF008800
    button2.text = "x100"
    button2.id = 22
    button2.hover_text = "Limit to 100 creatures"

    button3 = new radioButtonElement()
    button3.x = 260
    button3.y = 300
    button3.x_scale = 50
    button3.y_scale = 50
    button3.color = 0xFF000000
    button3.color_active = 0xFF008800
    button3.text = "x500"
    button3.id = 23
    button3.hover_text = "Limit to 500 creatures"

    push(button1.otherButtons,button2)
    push(button1.otherButtons,button3)
    push(button2.otherButtons,button1)
    push(button2.otherButtons,button3)
    push(button3.otherButtons,button2)
    push(button3.otherButtons,button1)

    push(all_buttons,button1)
    push(all_buttons,button2)
    push(all_buttons,button3)
    
    button = new toggleButtonElement()
    button.x = 310
    button.y = 200
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008844
    button.text = ">-<"
    button.id = 24
    button.hover_text = "Loop enclosure"
    push(all_buttons,button)

    button = new toggleButtonElement()
    button.x = 310
    button.y = 250
    button.x_scale = 50
    button.y_scale = 50
    button.color = 0xFF000000
    button.color_active = 0xFF008844
    button.text = "/|\\"
    button.id = 25
    button.hover_text = "Keep food"
    push(all_buttons,button)

    push(all_buttons,button5)

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
        sbutton.spec.x_loc = random_int(seed)%50
        sbutton.spec.y_loc = random_int(seed)%50
        push(shop_buttons,sbutton)
        z++
    var iMTmp = 1
    var mTmpSpec = createCustomCriter(new critr(),"custom_gene.txt",iMTmp)
    while (mTmpSpec.name!="")
        var sbutton = new shopButtonElement()
        sbutton.x = 10
        sbutton.y = 200
        sbutton.x_scale = 200
        sbutton.y_scale = 50
        sbutton.color = 0xFF000000
        sbutton.color_active = 0xFF008800
        sbutton.text = ""
        sbutton.id = z
        sbutton.spec = mTmpSpec
        sbutton.spec.x_loc = random_int(seed)%50
        sbutton.spec.y_loc = random_int(seed)%50
        push(shop_buttons,sbutton)
        iMTmp++
        mTmpSpec = createCustomCriter(new critr(),"custom_gene.txt",iMTmp)
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
            if (energy_amount<0)
                lost = true
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

                i=0
                while (i<length(shelf_buttons))
                    shelf_buttons[i]->process()
                    i++

                
                var en_x = 637-active_enclosure.lin_size*2
                var en_y = 325-active_enclosure.lin_size*2
                var critTmp1 = active_enclosure->getCritAt((int(get_mouse_position()[0])-en_x)/4,(int(get_mouse_position()[1])-en_y)/4)
                if (chosen_crit==null)||(critTmp1!=null)
                    chosen_crit = critTmp1
            if (all_buttons[2].pressed)
                loopAm = (active_enclosure.lin_size/10) *3
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
            if (all_buttons[26].pressed)
                strat = 4

            if (all_buttons[0].pressed)
                active_enclosure->addFood(loopAm,strat) 
                if (all_buttons[4].pressed)
                    var critAm = active_enclosure->getAmount()
                    if (critAm<(active_enclosure.maxCriters/10)*4)&&(loopAm>1)
                        loopAm--
                    else 
                        if (critAm>(active_enclosure.maxCriters/10)*6)&&(loopAm<(active_enclosure.lin_size/10) *3)
                            loopAm++
            if (all_buttons[1].pressed)&&(active)
                loop++
                if (loop>300)
                    active_enclosure->addFood(loopAm,strat)
                    loop = 0     
                    if (all_buttons[4].pressed)
                        var critAm = active_enclosure->getAmount()
                        if (critAm<(active_enclosure.maxCriters/10)*4)&&(loopAm>1)
                            loopAm--
                        else 
                            if (critAm>(active_enclosure.maxCriters/10)*6)&&(loopAm<(active_enclosure.lin_size/10) *3)
                                loopAm++
            if (all_buttons[10].pressed)
                active_enclosure->sell(0)
            if (all_buttons[11].pressed)
                active_enclosure->sell(1)
            if (all_buttons[12].pressed)
                active_enclosure->sell(2)
            if (all_buttons[14].pressed)
                if (chosen_crit!= null)
                    var sbutton = new shelfButtonElement()
                    sbutton.x = 500
                    sbutton.y = 10
                    sbutton.x_scale = 60
                    sbutton.y_scale = 60
                    sbutton.color = 0xFF000000
                    sbutton.color_active = 0xFF008800
                    sbutton.text = ""
                    sbutton.id = 177013
                    sbutton.spec = chosen_crit
                    push(shelf_buttons,sbutton)
                    active_enclosure->removeCrit(chosen_crit)
            
            if (all_buttons[15].pressed)
                if (chosen_crit!= null)
                    saveGenome(chosen_crit)
            
            if (all_buttons[16].pressed)&&(active)
                all_buttons[16].text="|>"
                active = false

            if (!all_buttons[16].pressed)&&(!active)
                all_buttons[16].text="||"
                active = true

            if (all_buttons[17].pressed)
                clear(all_enclosures)
                clear(all_buttons)
                clear(shop_buttons)
                energy_amount = 2000
                lost = false
                initialize()
            if (all_buttons[18].pressed)
                active_enclosure.lin_size=50
                active_enclosure->updateFood()
            if (all_buttons[19].pressed)
                active_enclosure.lin_size=75
                active_enclosure->updateFood()
            if (all_buttons[20].pressed)
                active_enclosure.lin_size=100
                active_enclosure->updateFood()
            if (all_buttons[21].pressed)
                active_enclosure.maxCriters = 50
            if (all_buttons[22].pressed)
                active_enclosure.maxCriters = 100
            if (all_buttons[23].pressed)
                active_enclosure.maxCriters = 500
            active_enclosure.loopy = all_buttons[24].pressed
            active_enclosure.keepFood = all_buttons[25].pressed
            i = 0
            while (i<length(shop_buttons))
                if (shop_buttons[i].pressed)
                    energy_amount = energy_amount - 1
                    var cr = shop_buttons[i].spec
                    active_enclosure->addCritr(cr)
                    erase(shop_buttons,i)
                    if (length(shop_buttons)<5)
                        var sbutton = new shopButtonElement()
                        sbutton.x = 10
                        sbutton.y = 200
                        sbutton.x_scale = 200
                        sbutton.y_scale = 50
                        sbutton.color = 0xFF000000
                        sbutton.color_active = 0xFF008800
                        sbutton.text = ""
                        sbutton.id = 4
                        if (random_int(seed)%20==0)
                            sbutton.spec = createCustomCriter(new critr(),"genetic_presets.txt",random_int(seed)%12)
                            sbutton.spec.x_loc = random_int(seed)%50
                            sbutton.spec.y_loc = random_int(seed)%50
                        else
                            sbutton.spec = new critr()
                            sbutton.spec.x_loc = random_int(seed)%50
                            sbutton.spec.y_loc = random_int(seed)%50
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

            i = 0
            while (i<length(shelf_buttons))
                if (shelf_buttons[i].pressed) 
                    active_enclosure->addCritr(shelf_buttons[i].spec)
                    erase(shelf_buttons,i)
                i++

            energy_amount = energy_amount + active_enclosure->getEnergy()
            energy_amount = energy_amount - active_enclosure.foodCost
            active_enclosure.foodCost = 0
            if (!active_enclosure->checkCrit(chosen_crit))
                chosen_crit=null
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

    
    all_buttons[18].pressed = (active_enclosure.lin_size == 50)
    all_buttons[19].pressed = (active_enclosure.lin_size == 75)
    all_buttons[20].pressed = (active_enclosure.lin_size == 100)
    all_buttons[21].pressed = (active_enclosure.maxCriters == 50)
    all_buttons[22].pressed = (active_enclosure.maxCriters == 100)
    all_buttons[23].pressed = (active_enclosure.maxCriters == 500)
    all_buttons[24].pressed = active_enclosure.loopy
    all_buttons[25].pressed = active_enclosure.keepFood 

    enclosure_position=msd
    setUpEnclosureCarousel()
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    if get_key(VK_R)
        loopAm = 0
    if get_key(VK_SPACE)
        all_buttons[16].pressed = !all_buttons[16].pressed
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    drawEnergy()
    if (active_enclosure!=null)
        var en_x = 637-active_enclosure.lin_size*2
        var en_y = 325-active_enclosure.lin_size*2
		rect(en_x, en_y, active_enclosure.lin_size*4, active_enclosure.lin_size*4, 0xFFF0F0F0)
        if (chosen_crit!=null)
            drawInfoWindow(chosen_crit)
        var i:int = 0
        while (i<length(active_enclosure.foodMap))
            if (active_enclosure.foodMap[i])
                rect(en_x+(i%active_enclosure.lin_size)*4,en_y+(i/active_enclosure.lin_size)*4,4,4,0xFF00FF00)
            i++
        i=0
        while (i<length(active_enclosure.criters))
            var crit = active_enclosure.criters[i]
            rect(en_x+crit.x_loc*4,en_y+crit.y_loc*4,4,4,crit.color)
            i++
        i=0
        while (i<length(all_buttons))
			if (all_buttons[i].id==0)
				all_buttons[i].x = 412 + 100 - 25 
			if (all_buttons[i].id<2)
				all_buttons[i].y = 140 + 100 * 4
            else 
                if (all_buttons[i].id<5)
				    all_buttons[i].x =  452 + 100*4 
                else 
                    if (all_buttons[i].id<9)
                        all_buttons[i].x =  452-75
                    else   
                        if (all_buttons[i].id<14)
                            all_buttons[i].y = 150-75
            if ((i!=14)&&(i!=15))||(chosen_crit!=null)
                all_buttons[i]->drawSelf()
            i++
        i=0
        while (i<length(all_buttons))
            if ((i!=14)&&(i!=15))||(chosen_crit!=null)
                all_buttons[i]->onHover()
            i++
        i=0
        while (i<length(shop_buttons))
            shop_buttons[i]->drawSelf()
            i++
        i=0
        while (i<length(shop_buttons))
            if (shop_buttons[i]->onHover())     
                var mp = get_mouse_position()
                var mx = mp[0]
                var my = mp[1]
                drawMiniInfoWindow(shop_buttons[i].spec,mx,my)
            i++
        i=0
        while (i<length(enclosure_buttons))
            enclosure_buttons[i]->drawSelf()
            i++
        i=0
        while (i<length(shelf_buttons))
            shelf_buttons[i].id = i
            shelf_buttons[i]->drawSelf()
            i++
        i=0
        while (i<length(shelf_buttons))
            shelf_buttons[i].id = i
            if (shelf_buttons[i]->onHover())     
                var mp = get_mouse_position()
                var mx = mp[0]
                var my = mp[1]
                drawMiniInfoWindow(shelf_buttons[i].spec,mx,my)
            i++
	else	
		rect(200, 200, 200, 200, 0xFFF0F0F0)
    return