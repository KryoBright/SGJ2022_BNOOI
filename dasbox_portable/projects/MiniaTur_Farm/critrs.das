require genes
require random
require fio

var seed_crit:int4
var save_file = fopen("savefile.txt","w")
var e_arr: array<int>

class Imap

    commonBits:array<bool>
    maxCriters:int
    mut_incr:bool

    def getFood(var x,y:int)
        return false

    def addCritr(var crit:critr?)
        return false

    def getAmount()
        return 0

    def getCritr(var n:int):critr?
        return null

    def eatFood(var x,y:int)
        return true

class critr
    memory:array<bool> 
    genome: array<Action?>
    unique_mutations:array<bool>
    position: int = 0
    food: int = 20
    energy: int = 0
    total_energy: int = 0
    total_energy2: int = 0
    lifetime : int = 1
    direction: int = 0
    x_loc: int = 0
    y_loc: int = 0
    color:uint = 0xFFFF0000
    name: string = ""
    phenotype_body:array<int>
    phenotype_body_color: uint = 0xFFFF0000

    def critr() 
        var i:int=0
        while (i<5) 
            push(genome, createRandomAction(seed_crit,2))
            i=i+1

        i = 120
        while (i>0)
            push(memory, false)
            i=i-1

        i = 0
        while (i<100)
            push(unique_mutations, false)
            i=i+1

        i = 0
        while(i<5)
            name = name + string(random_int(seed_crit)%10)
            i++
            
        i = 0
        while(i<8)
            push(phenotype_body, random_int(seed_crit)%36)
            i++
            
        phenotype_body_color = uint(random_int(seed_crit)%255+(random_int(seed_crit)%255)*256+(random_int(seed_crit)%255)*256*256+255*16777216)
        color = phenotype_body_color
        direction = random_int(seed_crit)%4
    
    def consumeGenome(var newGenome: array<Action?>&; pb:array<int>; pbc:uint; var logic:bool=false; var mem:bool=false; var mut_incr:bool = false)
        var i:int=0
        while (i<5) 
            erase(genome, 0)
            i=i+1
        i=0
        var base_chance = 200
        if (mut_incr)
            base_chance = 100
        while (i<length(newGenome)) 
            if (random_int(seed_crit)%(base_chance/20)==0)
                push(genome, mutate(newGenome[i]->createCopy(),seed_crit,logic,mem))
            else
                push(genome, newGenome[i]->createCopy())
            i=i+1
        color = 0xFFFFFF00
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[0]=true
            color = 0xFF00FFFF
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[1]=true
            color = 0xFF00FFFF
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[2]=true
            color = 0xFF00FF55
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[3]=true
            color = 0xFFFF009D
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[4]=true
            color = 0xFF747474
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[5]=true
            color = 0xFF0400FF
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[6]=true
            color = 0xFFE680FF
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[7]=true
            color = 0xFF32003F
            i=0
            while (i<5) 
                push(genome, createRandomAction(seed_crit,0,logic,mem))
                i=i+1
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[8]=true
            color = 0xFFFFFFFF
        if (random_int(seed_crit)%base_chance==0)
            if (!unique_mutations[8])
                unique_mutations[9]=true
                color = 0xFFEEFFEE
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[10]=true
            color = 0xFF33FF00
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[11]=true
            color = 0xFF00FFBF
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[12]=true
            color = 0xFFFF00DD
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[13]=true
            color = 0xFFFFD000
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[14]=true
            color = 0xFF2600FF
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[15]=true
            color = 0xFF959695
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[16]=true
            color = 0xFFD2FCC8
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[17]=true
            color = 0xFFBDC3F5
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[18]=true
            color = 0xFFF5DBBD
        // 19 - creative
        if (random_int(seed_crit)%base_chance==0)
            unique_mutations[20]=true
            color = 0xFFF5DBBD
        i = 0
        while(i<length(pb))
            phenotype_body[i] = pb[i]
            if (random_int(seed_crit)%10==0)
                phenotype_body[i] = phenotype_body[i]+(random_int(seed_crit)%2)*2-1
            phenotype_body[i] = (phenotype_body[i]+36)%36
            i++

        if (pbc!=0x00000000)
            phenotype_body_color = pbc
            if (random_int(seed_crit)%10==0)
                phenotype_body_color = phenotype_body_color + uint(4*4)
            if (random_int(seed_crit)%10==0)
                phenotype_body_color = phenotype_body_color + uint(1024*4)
            if (random_int(seed_crit)%10==0)
                phenotype_body_color = phenotype_body_color + uint(16384*4)
            if (random_int(seed_crit)%10==0)
                phenotype_body_color = phenotype_body_color - uint(4*4)
            if (random_int(seed_crit)%10==0)
                phenotype_body_color = phenotype_body_color - uint(1024*4)
            if (random_int(seed_crit)%10==0)
                phenotype_body_color = phenotype_body_color - uint(16384*4)
            color = phenotype_body_color
        else
            phenotype_body_color = color

    def execute()
        var i: int = 0
        while (i<length(genome)) 
            position = genome[i]->apply(memory,position)
            i=i+1

    def act(var map: Imap; var n:int = 0)
        var i:int = 120
        if (unique_mutations[0])
            while (i>0)
                memory[i-1] = false
                i=i-1
            position = 0
        
        memory[0]=false
        memory[1]=false
        memory[2]=false
        memory[3]=false
        if (unique_mutations[18])
            i = 0 
            var copy_n = n
            while (copy_n>0)
                memory[108-i] = copy_n%2 == 1
                i = i + 1
                copy_n = copy_n >> 1
        i = 0
        if (unique_mutations[10])
            if (length(map.commonBits)>4)
                while (i<5)
                    memory[115+i] = map.commonBits[i]
                    i=i+1
        if (unique_mutations[14])
            memory[114]=(random_int(seed_crit)%2==0)
        if (unique_mutations[17])
            memory[109]=(food>60)
        if (map->getFood(x_loc+1,y_loc))
            memory[direction%4]=true
        if (map->getFood(x_loc,y_loc+1))
            memory[(direction+1)%4]=true
        if (map->getFood(x_loc-1,y_loc))
            memory[(direction+2)%4]=true
        if (map->getFood(x_loc,y_loc-1))
            memory[(direction+3)%4]=true
        if (unique_mutations[20])
            var dist:int=0
            var direction_x:int=0
            var direction_y:int=0
            if (direction==0)
                direction_x=1
            if (direction==1)
                direction_y=1
            if (direction==2)
                direction_x=-1
            if (direction==3)
                direction_y=-1
            while (dist<7)&&!(map->getFood(x_loc+direction_x*dist,y_loc+direction_y*dist))
                dist = dist + 1
            i = 0 
            var divider:int = 1
            while (i<3)
                memory[102-i] = dist % 2 == 1
                i = i + 1
                dist = dist>>1
        i=0
        execute()
        if (unique_mutations[5])
            execute()
        if (!unique_mutations[19])
            lifetime = lifetime + 1
        var luck:int = random_int(seed_crit)%lifetime
        if (unique_mutations[4])
            luck = luck*4
        if (luck<(lifetime-256)*2)
            food = -10
            return
        food = food - 1
        if (unique_mutations[2])
            if (lifetime%2==0)
                food = food+1
        if (unique_mutations[19])
            food = 90
        if (map->getFood(x_loc,y_loc))
            food = food + 40
            map->eatFood(x_loc,y_loc)
        if (unique_mutations[3])
            var z:int = 0
            while (z<map->getAmount())
                var prey = map->getCritr(z)
                if (prey!=null)
                    if (!prey.unique_mutations[3])
                        if (prey.x_loc==x_loc)
                            if (prey.y_loc==y_loc)
                                food = food + prey.food/2
                                prey.lifetime = 9999
                z = z+1
        if (memory[5])
            direction=direction+2
        if (memory[6])
            direction=direction+1
        direction=direction%4
        if (memory[7])
            if (direction == 0)
                if (x_loc<49)
                    x_loc=x_loc+1
            if (direction == 1)
                if (y_loc<49)
                    y_loc=y_loc+1
            if (direction == 2)
                if (x_loc>0)
                    x_loc=x_loc-1
            if (direction == 3)
                if (y_loc>0)
                    y_loc=y_loc-1
        if (memory[8])
            if (!unique_mutations[19])
                food = food - 1
                if (!unique_mutations[1])
                    food = food - 4
                energy = energy + 1
                if (unique_mutations[8])
                    if (map->getAmount()<map.maxCriters/2)
                        energy = energy + 3
                        total_energy = total_energy + 3
                        total_energy2 = total_energy2 + 3
                if (unique_mutations[9])
                    if (map->getAmount()>(map.maxCriters*9)/10)
                        energy = energy + 1
                        total_energy = total_energy + 1
                        total_energy2 = total_energy2 + 1
                total_energy = total_energy + 1
                total_energy2 = total_energy2 + 1
            else
                lifetime = 9999
        if (memory[9])
            if (food > 60)
                if (map->getAmount()<map.maxCriters)
                    food = food - 30
                    var newSpec = new critr()
                    newSpec.x_loc = x_loc
                    newSpec.y_loc = y_loc
                    newSpec->consumeGenome(genome,phenotype_body,phenotype_body_color,unique_mutations[15],unique_mutations[16],map.mut_incr)
                    if (unique_mutations[6])
                        food=food/2
                        newSpec.food = newSpec.food + food
                    i = 0
                    while (i<100)
                        if (unique_mutations[i])
                            var chance:int = random_int(seed_crit)%29
                            if (chance>0)||(unique_mutations[19])
                                newSpec.unique_mutations[i]=true
                                if (i==9)
                                    newSpec.unique_mutations[i-1]=false
                                newSpec.color = color
                        i=i+1
                    map->addCritr(newSpec)
        i = 0
        if (unique_mutations[10])
            if (length(map.commonBits)>4)
                while (i<5)
                    map.commonBits[i] = memory[115+i]
                    i=i+1
            else
                while (i<5)
                    push(map.commonBits,memory[115+i])
                    i=i+1
        if (unique_mutations[11])&&(!unique_mutations[19])
            food = food + total_energy2/10
            total_energy2 = total_energy2%10

    def getCost()
        if (unique_mutations[19])
            return 0f
        if (unique_mutations[13])
            return (float(total_energy*3)/float(lifetime+1))/float(lifetime+1)
        return (float(total_energy)/float(lifetime+1))/float(lifetime+1)
    
    def serializeSelf()
        var r:string = ""
        var i:int = 0 
        while (i<length(memory))
            if (memory[i])
                r=r+"1"
            else 
                r=r+"0"
            i=i+1
        r = r + "\n"
        i = 0 
        while (i<length(genome))
            r = r + genome[i]->getDescription()+" "
            i=i+1
        r = r + "\n"
        i = 0 
        while (i<length(unique_mutations))
            if (unique_mutations[i])
                r=r+"1"
            else 
                r=r+"0"
            i=i+1
        r = r + "\n"
        r = r + string(position)+" "
        r = r + string(food)+" "
        r = r + string(energy)+" "
        r = r + string(total_energy)+" "
        r = r + string(total_energy2)+" "
        r = r + string(lifetime)+" "
        r = r + string(direction)+" "
        r = r + string(x_loc)+" "
        r = r + string(y_loc)+" \n"
        fprint(save_file,r)
        //fclose(save_file)
        return r

    def getColors()
        var i = 0
        var cl: array<uint>
        while (i<length(genome)) 
            getColorsG(genome[i],cl)
            i++
        return <- cl

def convertUMtoName(var i: int)
    if (i==0)
        return "Short-term memory"
    if (i==1)
        return "Photosyntesis"
    if (i==2)
        return "Chemosynthesis"
    if (i==3)
        return "Predators"
    if (i==4)
        return "Longevity"
    if (i==5)
        return "Cunning"
    if (i==6)
        return "Caring"
    if (i==7)
        return "Long genome"
    if (i==8)
        return "Soloists"
    if (i==9)
        return "Social"
    if (i==10)
        return "Communicative"
    if (i==11)
        return "Effective"
    if (i==12)
        return "Nutritious"
    if (i==13)
        return "Precious"
    if (i==14)
        return "Chaotic"
    if (i==15)
        return "Logical"
    if (i==16)
        return "Complex"
    if (i == 17)
        return "Hypothalamus"
    if (i == 18)
        return "Unique"
    if (i == 19)
        return "Creative"
    if (i == 20)
        return "Binocular vision"
    return "Unknown"