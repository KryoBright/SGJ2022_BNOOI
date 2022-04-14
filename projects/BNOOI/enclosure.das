require critrs
require random
require daslib/media

var seed_en:int4
var food_image: ImageHandle <- create_managed_image("texture.jpg")

class enclosure:Imap

    foodMap: array<bool>
    criters: array<critr?>
    foodCost: int = 0
    absEnergy: int = 0
    keepFood:bool = false
    
    def enclosure()
        loopy=false
        maxCriters = 500
        var i: int = 0
		lin_size = 50
        while (i<lin_size*lin_size)
            push(foodMap,false)
            i=i+1
            
    def act()
        var i: int = 0
        while (i<length(criters))
            if (criters[i]!=null)
                if (criters[i].food>0)
                    //unsafe
                    //    criters[i]->setMap(addr(self))
                    criters[i]->act(self,i)
                else
                    if (criters[i].unique_mutations[12])
                        foodMap[criters[i].y_loc*lin_size+criters[i].x_loc]=true
                    erase(criters,i)
            i=i+1

    def updateFood()
        if (length(foodMap)!=lin_size*lin_size)
            clear(foodMap)
            var i: int = 0
            while (i<lin_size*lin_size)
                push(foodMap,false)
                i=i+1

    def getEnergy()
        var totEnergy: int = 0
        var i: int = 0
        while (i<length(criters))
            if (criters[i]!=null)
                if (criters[i].energy>0)
                    totEnergy = totEnergy + criters[i].energy
                    criters[i].energy = 0
            i = i+1
        absEnergy = absEnergy + totEnergy
        return totEnergy
    
    def addFood(var chance,strategy:int)
        var i: int = 0
        while (i<lin_size*lin_size)
            var x = (i/lin_size)-lin_size/2
            var y = (i%lin_size)-lin_size/2
            var c:int = random_int(seed_en)
            var toPick = false
            if (strategy == 0)&&(c%chance==0)
                toPick = true
            if (x*x+y*y < ((lin_size/10) *8)*((lin_size/10) *3 + 1 - chance)) && (strategy == 1)
                toPick = true
            if (x*x+y*y > ((lin_size/10) *8)*chance) && (strategy == 2)
                toPick = true
            if (strategy==3)&&(((x-y)>chance*2)||((y-x)>chance*2))
                toPick = true
            if (strategy==4)
                x=x+lin_size/2
                y=y+lin_size/2
                var pxl:uint = food_image|>get_pixel((y*food_image.width)/lin_size,(x*food_image.height)/lin_size)
                toPick = ((pxl & 0x00F0F0F0) != 0x00000000)&&((pxl & 0x00F0F0F0) != 0x00F0F0F0)

            if (toPick)
                foodMap[i] = true
                foodCost = foodCost + 1
            else
                if (!keepFood)
                    foodMap[i] = false
            i=i+1

    def addRandCritersMess()
        var i: int = 0
        while(i<15)
            i=i+1
            if (length(criters)<15)
                foodCost=foodCost+100
                var critTmp = new critr()
                critTmp.x_loc = i+20
                critTmp.y_loc = i+20
                push(criters,critTmp)

    def getAvrgLifetime()
        var lifetime:int = 0
        var i: int = 0
        while (i<length(criters))
            if (criters[i]!=null)
                lifetime = lifetime + criters[i].lifetime
            i=i+1
        return float(lifetime)/float(i)

    def getAvrgCost()
        var lifetime:float = 0f
        var i: int = 0
        while (i<length(criters))
            if (criters[i]!=null)
                lifetime = lifetime + criters[i]->getCost()
            i=i+1
        return lifetime/float(i)
    
    def sellLeastExpensive()
        var minC:float = 10000f
        var id = 0
        if (length(criters)==maxCriters)
            var i: int = 0
            while (i<length(criters))
                if (criters[i]!=null)
                    if (criters[i]->getCost()<minC)
                        id = i
                        minC = criters[i] -> getCost()
                i=i+1
            foodCost = foodCost - int(minC*100f)
            erase(criters,id)
            
    def sellMostExpensive()
        var minC:float = -1f
        var id = 0
        if (length(criters)==maxCriters)
            var i: int = 0
            while (i<length(criters))
                if (criters[i]!=null)
                    if (criters[i]->getCost()>minC)
                        id = i
                        minC = criters[i] -> getCost()
                i=i+1
            erase(criters,id)  
            foodCost = foodCost - int(minC*100f)

    def sellOldest()
        var minC:int = -1
        var id = 0
        if (length(criters)==maxCriters)
            var i: int = 0
            while (i<length(criters))
                if (criters[i]!=null)
                    if (criters[i].lifetime>minC)
                        id = i
                        minC = criters[i].lifetime
                i=i+1
            foodCost = foodCost - int(criters[id]->getCost()*100f)
            erase(criters,id)

    def sell(var strategy:int)
        if (strategy==0)
            sellOldest()
        if (strategy==1)
            sellMostExpensive()
        if (strategy==2)
            sellLeastExpensive()

    def getCritAt(var x,y:int)
        var i=0
        while (i<length(criters))
            if (criters[i].x_loc==x)&&(criters[i].y_loc==y)
                return criters[i]
            i++
        return null
    
    def checkCrit(var spec:critr?)
        var i=0
        while (i<length(criters))
            if (criters[i]==spec)
                return true
            i++
        return false

    def removeCrit(var spec:critr?)
        var i=0
        while (i<length(criters))
            if (criters[i]==spec)
                erase(criters,i)
                return 
            i++
        return 

    def override getFood(var x,y:int)
        var x1 = (y+lin_size)%lin_size
        while (x1<0)
            x1 = (x1+lin_size)%lin_size
        var y1 = (x+lin_size)%lin_size
        while (y1<0)
            y1 = (y1+lin_size)%lin_size
        return foodMap[x1*lin_size+y1]

    def override eatFood(var x,y:int)
        var x1 = (y+lin_size)%lin_size
        var y1 = (x+lin_size)%lin_size
        foodMap[x1*lin_size+y1]=false
        return true

    def override addCritr(var crit:critr?)
        if (crit!=null) 
            if (length(criters)<maxCriters)
                push(criters,crit)
                return true
        return false

    def override getAmount()
        return length(criters)
    
    def override getCritr(var n:int)
        return criters[n]