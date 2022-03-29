require critrs
require random

var seed_en:int4

class enclosure:Imap

    foodMap: array<bool>
    criters: array<critr?>
    foodCost: int = 0
    absEnergy: int = 0
    
    def enclosure()
        maxCriters = 50
        var i: int = 0
        while (i<2500)
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
                        foodMap[criters[i].y_loc*50+criters[i].x_loc]=true
                    erase(criters,i)
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
        while (i<2500)
            var x = (i/50)-25
            var y = (i%50)-25
            var c:int = random_int(seed_en)
            var toPick = false
            if (strategy == 0)&&(c%chance==0)
                toPick = true
            if (x*x+y*y < 40*(16-chance)) && (strategy == 1)
                toPick = true
            if (x*x+y*y > 40*chance) && (strategy == 2)
                toPick = true
            if (strategy==3)&&(((x-y)>chance*2)||((y-x)>chance*2))
                toPick = true

            if (toPick)
                foodMap[i] = true
                foodCost = foodCost + 1
            else
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
        var minC:float = 1f
        var id = 0
        if (length(criters)==maxCriters)
            var i: int = 0
            while (i<length(criters))
                if (criters[i]!=null)
                    if (criters[i]->getCost()<minC)
                        id = i
                        minC = criters[i] -> getCost()
                i=i+1
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
            erase(criters,id)

    def sell(var strategy:int)
        if (strategy==0)
            sellOldest()
        if (strategy==1)
            sellMostExpensive()
        if (strategy==2)
            sellLeastExpensive()

    def override getFood(var x,y:int)
        var x1 = (y+50)%50
        while (x1<0)
            x1 = (x1+50)%50
        var y1 = (x+50)%50
        while (y1<0)
            y1 = (y1+50)%50
        return foodMap[x1*50+y1]

    def override eatFood(var x,y:int)
        var x1 = (y+50)%50
        var y1 = (x+50)%50
        foodMap[x1*50+y1]=false
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