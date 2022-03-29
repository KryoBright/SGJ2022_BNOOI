require random
require strings

var seed_gene:int4

class Action
    lifetime: int = 2000    
    tp:int=1
    outcome:Action?
    first,second:Action?

    def apply(var bits: array<bool>&;var position:int&)
        return position

    def createCopy()
        return new Action()

    def getDescription()
        return ""

class flipBitAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        bits[position] = !bits[position]
        return position
    
    def override createCopy()
        return new flipBitAction()

    def override getDescription()
        return "FBT"

class moveLeftAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        position = (position+119)%120
        return position

    def override createCopy()
        return new moveLeftAction()

    def override getDescription()
        return "MVL"

class moveRightAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        position = (position+1)%120
        return position
    
    def override createCopy()
        return new moveRightAction()

    def override getDescription()
        return "MVR"

class conditionalAction : Action

    def conditionalAction(var outcome1: Action?&)
        tp = 4
        self.outcome = outcome1
        return <- self

    def override apply(var bits: array<bool>&;var position:int&)
        if (lifetime>0)
            lifetime=lifetime-1
            if (bits[position])
                position = self.outcome->apply(bits,position)
            return position
        else 
            outcome = mutate(outcome,seed_gene)
            lifetime = 1000
            return self->apply(bits,position)
    
    def override createCopy()
        var ac = new conditionalAction()
        ac.outcome = outcome->createCopy()
        return ac

    def override getDescription()
        return "CND "+outcome->getDescription()

class aggregatorAction : Action

    def aggregatorAction(var first,second:Action?&)
        tp=5
        self.first=first
        self.second=second
        return <- self

    def override apply(var bits: array<bool>&;var position:int&)
        position = self.first->apply(bits,position)
        position = self.second->apply(bits,position)
        return position

    def override createCopy()
        var ac = new aggregatorAction()
        ac.first = first->createCopy()
        ac.second = second->createCopy()
        return ac    
        
    def override getDescription()
        return "AGR "+first->getDescription()+" "+second->getDescription()

class loopAction : Action

    def loopAction(var outcome: Action?&)
        tp=6
        self.outcome = outcome
        return <- self

    def override apply(var bits: array<bool>&;var position:int&)
        
        while (bits[position])
            if (lifetime>0)
                lifetime=lifetime-1
                position = self.outcome->apply(bits,position)
            else 
                outcome = mutate(outcome,seed_gene)
                lifetime = 1000
                return self->apply(bits,position)
            
        return position

    def override createCopy()
        var ac = new loopAction()
        ac.outcome = outcome->createCopy()
        return ac    
        
    def override getDescription()
        return "LOP "+outcome->getDescription()

//---Logics--

class orAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        bits[position] = bits[(position+1)%120] || bits[(position+119)%120]
        return position
    
    def override createCopy()
        return new orAction()

    def override getDescription()
        return "ORA"

class andAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        bits[position] = bits[(position+1)%120] && bits[(position+119)%120]
        return position
    
    def override createCopy()
        return new andAction()

    def override getDescription()
        return "AND"

class xorAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        bits[position] = (bits[(position+1)%120] || bits[(position+119)%120])&& !(bits[(position+1)%60] && bits[(position+59)%60])
        return position
    
    def override createCopy()
        return new xorAction()

    def override getDescription()
        return "XOR"

class readAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        bits[102] = bits[position]
        return position
    
    def override createCopy()
        return new readAction()

    def override getDescription()
        return "RDD"

class writeAction : Action

    def override apply(var bits: array<bool>&;var position:int&)
        bits[position] = bits[102]
        return position
    
    def override createCopy()
        return new writeAction()

    def override getDescription()
        return "WRT"

class recursiveAction : Action

    pos_i: int = 0
    neg_i: int = 0

    def recursiveAction(var first,second:Action?&)
        tp=5
        self.first=first
        self.second=second
        return <- self

    def override apply(var bits: array<bool>&;var position:int&)
        lifetime = lifetime - 1
        if (bits[position])
            position = self.first->apply(bits,position)
            pos_i = pos_i + 1
        else 
            while(pos_i>0)&&(lifetime>0)
                lifetime = lifetime - 1
                position = self.second->apply(bits,position)
                pos_i = pos_i - 1
            neg_i = neg_i + 1
        if (pos_i>100)
            pos_i = 100
        if (neg_i>100)
            neg_i = 100
        if (lifetime == 0)
            first = mutate(first,seed_gene)
            second = mutate(second,seed_gene)
            lifetime = 100
        return position

    def override createCopy()
        var ac = new recursiveAction()
        ac.first = first->createCopy()
        ac.second = second->createCopy()
        return ac    
        
    def override getDescription()
        return "ARA "+first->getDescription()+" "+second->getDescription()
       
def createRandomAction(var seed; var complexity:int = 0; var logic:bool=false; var mem:bool=false)
    var i:int = 6
    if (logic)
        i=i+3
    if (mem)
        i=i+2  
    var case_ = random_int(seed_gene)%i
    if (mem)
        case_ = case_ - 2
    if (complexity>0) 
        case_ = random_int(seed_gene)%1+5
    if (case_ == -2)
        return new readAction()
    if (case_ == -1)
        return new writeAction()
    if (case_ == 1)
        return new flipBitAction()
    if (case_ == 2)
        return new moveLeftAction()
    if (case_ == 3)
        var ac=new conditionalAction()
        ac.outcome = createRandomAction(seed,complexity-1,logic,mem)
        return ac
    if (case_ == 4)
        var ac=new loopAction()
        ac.outcome = createRandomAction(seed,complexity-1,logic,mem)
        return ac
    if (case_ == 5)
        var ac=new aggregatorAction()
        if (random_int(seed_gene)%2==1)
            ac = new recursiveAction()
        ac.first = createRandomAction(seed,complexity-1,logic,mem)
        ac.second = createRandomAction(seed,complexity-1,logic,mem)
        return ac
    if (case_ == 6)
        return new orAction()
    if (case_ == 7)
        return new andAction()
    if (case_ == 8)
        return new xorAction()
    return new moveLeftAction()

def mutate(var gene, seed; var logic:bool=false; var mem:bool=false)
    var case_ = random_int(seed_gene)%24

    if (case_ == 0)
        return createRandomAction(seed,0,logic,mem)
    if (case_ == 1)
        if (gene.tp==6)
            gene.outcome = mutate(gene.outcome,seed)
        if (gene.tp==4)
            gene.outcome = mutate(gene.outcome,seed)
    
    if (case_ == 2)
        if (gene.tp==5)
            gene.first = mutate(gene.first,seed)

    if (case_ == 3)
        if (gene.tp==5)
            gene.second = mutate(gene.second,seed)
    
    if (case_ == 4)
        if (gene.tp==5)
            gene.first = mutate(gene.first,seed)
            gene.second = mutate(gene.second,seed)

    if (case_ == 5)
        if (gene.tp==5)
            var c = gene.first
            gene.first = mutate(gene.second,seed)
            gene.second = mutate(c,seed)
    if (case_ == 6)
        if (gene.tp==5)
            return gene.first   
        if (gene.tp==6)
            return gene.outcome
        if (gene.tp==4)
            return gene.outcome
    if (case_ == 7)
        if (gene.tp==5)
            return gene.second
    if (case_ == 8)
        var c = new aggregatorAction()
        c.first = gene
        c.second = createRandomAction(seed,0,logic,mem)
        return c
    if (case_ == 9)
        var c = new conditionalAction()
        c.outcome = gene
        return c
    if (case_ == 10)
        var c = new loopAction()
        c.outcome = gene
        return c
    if (case_ == 11)
        return mutate(mutate(gene,seed,logic,mem),seed,logic,mem)
    
    if (case_ == 12)
        if (gene.tp==5)
            return gene.first   
        if (gene.tp==6)
            return gene.outcome
        if (gene.tp==4)
            return gene.outcome
    if (case_ == 13)
        if (gene.tp==5)
            return gene.second
    if (case_ == 14)
        if (gene.tp==5)
            return gene.first   
        if (gene.tp==6)
            return gene.outcome
        if (gene.tp==4)
            return gene.outcome
    if (case_ == 15)
        if (gene.tp==5)
            return gene.second
    
    if (gene.tp==5)
        return gene.first   
    if (gene.tp==6)
        return gene.outcome
    if (gene.tp==4)
        return gene.outcome
    return gene

def getGeneByCode(var code:string)
    if (code=="MVL")
        return new moveLeftAction()
    if (code=="MVR")
        return new moveRightAction()
    if (code=="FBT")
        return new flipBitAction()
    if (code=="CND")
        return new conditionalAction()
    if (code=="LOP")
        return new loopAction()
    if (code=="AGR")
        return new aggregatorAction()
    if (code=="ORA")
        return new orAction()
    if (code=="AND")
        return new andAction()
    if (code=="XOR")
        return new xorAction()
    if (code=="RDD")
        return new readAction()
    if (code=="WRT")
        return new writeAction()
    if (code=="ARA")
        return new recursiveAction()
    return createRandomAction(seed_gene)

def getColorsG(var gene:Action?; var crs:array<uint>)
    var c = gene->getDescription()
    var code = ""
    var i = 0
    while (i<3)
        code = code +  to_char(character_at(c,i))
        i++
    if (code=="MVL")
        push(crs,0xFFFF0000)
    if (code=="MVR")
        push(crs,0xFF00FF00)
    if (code=="FBT")
        push(crs,0xFF0000FF)
    if (code=="CND")
        push(crs,0xFFFF00FF)
        getColorsG(gene.outcome,crs)
    if (code=="LOP")
        push(crs,0xFFFFFF00)
        getColorsG(gene.outcome,crs)
    if (code=="AGR")
        push(crs,0xFF00FFFF)
        getColorsG(gene.first,crs)
        getColorsG(gene.second,crs)
    if (code=="ORA")
        push(crs,0xFF00FF90)
    if (code=="AND")
        push(crs,0xFFFF9100)
    if (code=="XOR")
        push(crs,0xFFFF0066)
    if (code=="RDD")
        push(crs,0xFF8A8A8A)
    if (code=="WRT")
        push(crs,0xFFFFFFFF)
    if (code=="ARA")
        push(crs,0xFF9900FF)
        getColorsG(gene.first,crs)
        getColorsG(gene.second,crs)
    return 