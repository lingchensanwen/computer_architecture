# Computer Architecture Note

## Aisatsu
This is merely a partial collection / analysis of exam questions in the past 6 years (as of 2017)  
Meaning, everything here needs to be memorized if you want to score A+, else try to understand and memorize as much as possible.  
Translation is not necessary fully accurate but should be good enough in most cases, for those non-trivial I will be adding Japanese translation for reference.  
(if you don't have the software to render this document, google markdown pdf converter or simply upload this to github)
Author : EEIC 2017 @CeleuC  


### **Bold : Appeared in past exam as fill in the blank**
## Introduction to Computer architecture
2 different design philosopies
1. __Transparency__  
you only need to understand the __Instruction set architecture__ to fully program a computer. (without knowing what exactly every components do)  
Related concepts includes: __Compatability__

2. __VLIW__ (very large instruction word)  
Scarifying transparency, and opt for higher performance

### __Superscalar processor__  
Superscalar processor -> can do out of order processing, needs Re-order buffer(ROB)
> __Out of order Process__  
> Handling instructions in a different order as it is written in program to parallelize it, without changing the meaning of the program, static scheduling  
> Realized by __Instruction window__  

>__*Instruction Window*__  
> Buffer that stores multiple decoded instruction. Fire instructions with no dependency and competing resource  
> The processor need to prepare some TAGs indicating whether all of the operants are ready. Once all operants of an instruction is ready, the instruction will be executed.  
> More Instruction Windows →　Higher concurrency, clock speed ↓ (Latency↑)
> 1. __Centralized Instruction Window__  
>    One Instruction Window for all processors, send instruction to processing unity once possible.  
>    Pros: Memory size ↓  
>    Cons: Circuit Complexity ↑, Latency ↑    
> 2. __Distributed Instruction Window__  
>  Intruction buffer are called Reservation station (mostly found in ARM processor nowaday), locate at the entrance of every processing unit. Every reservation station can fire their own instruction →Multiple instructions in parallel   

Modern CPU stores only register reference in ROB
1.	__Fetching__ : take Instruction out of memory  
2.	__Rename__ : read Operant from register file and reorder buffer, make it a Instruction and write it back to reorder buffer  
    Renaming solves __anti dependency__ and __output dependency__ (逆依存、出力依存)  
    (optional) Remark : A more accurate description of "Rename" will be the following    
    > the register renamer analyses data dependency, to identify dependency chains in a single sequence of
    instructions then the namer renames the registers when mapping to hardware registers so as to enable concurrency, that's why modern CPU cores has a way larger PRF than the architectural registers (16 for x86-64, 32 for ARMv8)  
    
    > Implementation : 
    > 1. __Mapping Table__   
    > prepare physical address for every logical address in the fetched Instruction. Once the logical address is called, the physical address instead will be written into.  

    > 2. __software__  
    > 3. __Reorder buffer__

3.	Decode : Send ready Instructions in reorder buffer to the next step
4.	Execution : Execute Instructions in parallel
5.	Write back : put execution result back to register  

## Cache
computer data have the property of locality
1. __Temporal locality__
2. __Spatial locality__   

Cache -> faster access  
> 3 types
>1.	Instruction cache
>2.	Data cache
>3.    TBL (detailed in later section)

> ### Cache associativity
> 1.	Direct mapped cache  
>    aka one-way set associative  
>    unique mapping from index  
>    conflict miss ↑  
>2.	Set associative cache  
>3.	Full associative cache

> ### Writing to main memory
> 1. Write through  
> Write through the cache to the main memory
> 2. Write back  
> Write to the main memory only when replacement happens

> ### Cache Miss
>> 3 Misses possible: '3Cs':  
>> - Compulsory miss(初期参照ミス)   
>>    On the first access to a block; the block must be brought into the cache; also called cold start misses, or first reference misses.
>>    Reduced by: Nop, its constant
>> - Capacity miss (容量性ミス)  
>>    Occur because blocks are being discarded from cache because cache cannot contain all blocks needed for program execution (program working set is much larger than cache capacity).
>>    Reduced by: Higher capacitor (well...
>>- Conflict miss (競合性ミス)  
>>    Only on Direct mapped or Set associative  
>>    occur when several blocks are mapped to the same set or block frame
>>    Reduced by: Higher associativity
>
>> #### Handling Cache miss
>>- __Write through__  
>>    (apart from compulsory miss) -> write current cache back to main memory -> foreach miss, read from main memory
>>- __Write back__   
>>     foreach miss, read from main memory

> ### Cache Capacity  
> Max cache capacity = cache line * cache line size
> cache line = N way of associativity * (page offset - log2(number of word in cache) - log2(number of bytes in a word))  
> Solving this :  
> 1. Series physical cache -> fetch physical page address, create physical address from TLB -> search from cache --> slow  
> 2. Virtual address cache -> Duplicated Mapping issue -> Need enforce coherency



> ### Replacement policies
> LRU (Least Recent used)


## Virtual Memory
### __Page table__
Mapping between Virtual address to physical address    
Locate at main memory  
main memory -> slow -> wanna cache right? -> TLB  
Max cache capacity = page.size * N(way associative)


> ### Translation lookaside buffe (TLB), not BLT  
>>1. __TLB__ -> Data and instruction  
>>2. ITLB -> instruction TLB  
>>3. DTLB -> Data TLB  
>
>>If TLB doesn't have the requested page, 2 things can happen  
>>    1.  if physical memory *does* contains the requested page   
>>            Raise __TLB Miss__ Exception  
>>            after that, TBL will reference page table and copy the physical page address to the virtual page address. (__LRU__ can kick in if there is no space in TLB)
>>    2.  else physical memory does *NOT* contains the requested page  
>>           Throw __Page fault__  
>>          CPU process throw expection, reference the main memory page table, write the physical page address into TLB (replace some old entries if no empty entry), setting effective bit to 1  
>
>>    #### Some additional info asked in past exam  
>>    TLB.size = TLB.entrySize(given) * {Effective bit = 1 + TAG = Virtual page address size + physical page address}  
>>    Virtual | Physical page address = virtual | Physical address(given) - page offset  
>>    page offset = log(N Kbit) = 12 in past exam

## Instruction Pipeline
>#### Pipeline Hazards
>>1. __Control hazards__  
>>  Attempt to make a decision about program control flow before the condition has been evaluated and the new PC target address calculated  
>>  Resolved by:  
>>    1. delayed branch (make the branch operation as late as possible)  
>>    2. branch prediction  
>>        You might be ask to design a predictor with logic gates, refer to 2016 pastpaper for detail and ans.  
>>    3. Instruction scheduling  
>>        Avoid pipeline stalls by rearranging the order of instructions.  
>>        Avoid subtle instruction pipeline timing issues and non-interlocked resources  
>>    4. __Loop unrolling__  
>>        Pros:  
>>        1. Also able to resolve data hazard by rearranging Instructions in the same loop  
>>
>>        Cons:  
>>        1. Source code size ↑
>>        2. Readability  ↓　
>>        3. Memory Acess ↑
>
>>2. __Data hazards__  
>>     3 types of Dependency  
>>      - Anti dependency  
>>      Reading from a registry that is later written by another instruction  
>>      - flow dependency   
>>      Depending on the result of previous computatiion, can't be helped logically  
>>      - output dependency  
>>      Writing into a registry that will later be written again by another instruction  
>>
>>
>>    Resolved by :  
>>    1. Forwarding  
>>        Forward execution result to the next operation, whether it is possible is checked by
>
>>3. __Structure hazards__  
>>    Attempt to use the same resource by two different instructions at the same time.  
>>    Resolved by :  
>>    1. separating the component into orthogonal units (such as separate caches)  
>>    2. bubbling the pipeline
>
> And of course, all hazards can be simply resolved by, you guessed it, waiting.

## Concurrency P  
Forwarding = O(P^2)  



## IO
>Computer IO can be managed in 2 ways.
>1. __Polling__  
>    having a routine that checks all the peripherals
>    Pros : Easy implementation, low processing requirement
>    Cons : Async, need an extra routine
>2. __Interrupt__  
>    send interrupt request (IRQ) to CPU, request an EXCEPTION, get interrupt handler 

>### DMA (Direct memory access)
>Access (main) memory directly from peripherals without going through CPU.  
>#### Steps
>1. CPU send the memory address and length of transfer to DMA controller (DMAC).
>2. DMAC gains control of the DMA bus 
>3. DMAC communicate with the peripheral and start the transfer  
>4. DMAC send finish signal to CPU and return control of the bus 

>### Reading from disk
> Reading from disk takes time, the exact time estimated to read SIZE data from disk is given by  
> Average Sync Time (given) + Average Rotation Time + Disk Controller Overhead (given) + Transfer time (trivial)  
>
> Average Rotation Time = __*0.5*__  * period of one rotation  
>
>as you never know where your head will start from, so it is fair to take average


## Reference:  
Quite a bit from Wiki  
Many from Anders Ha  
[Forwarding][http://www.cs.utexas.edu/users/mckinley/352/lectures/12.pdf]

and best luck mate.