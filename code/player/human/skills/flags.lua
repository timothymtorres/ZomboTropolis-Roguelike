local skill_flags = {
  
  --ap_bonus skill for a later game?  need to enable it on player:getStat() 
  
  
  -------------
  --- HUMAN ---
  -------------
   
  -- Classes 
  military =             1,
  research =             2,
  engineering =          4,  
    
  -- General
  hp_bonus =             1,  -- hp_bonus MUST remain flag 1 b/c it's used for both zombies & humans on the bitflag 1 slot
  cutting =              2,
  swinging =             4,
  martial_arts =         8,
  martial_arts_adv =    16,
  ranged =              32,
  roof_travel =         64,
  melee =              128,
  ip_bonus =           256,
  looting =            512,
  diagnosis =         1024,
  graffiti =          2048,

  -- Military
  ranged_adv =           1,
  guns =                 2,
  light_guns =           4,
  heavy_guns =           8,
  archery =             16,
  archery_adv =         32,
  melee_adv =           64,
  smacking =           128,
  chopping =           256,
  slicing =            512,
  smashing =          1024,
  explosives =        2048,

  -- Research
  healing =              1,
  major_healing =        2,
  minor_healing =        4,
  diagnosis_adv =        8,
  gadgets =             16,
  scanner =             32,
  syringe =             64,
  syringe_adv =        128,
  terminal =           256,
  terminal_adv =       512,
  
  -- Engineering
  repair =              1,
  repair_adv =          2,
  barricade =            4,
  barricade_adv =        8,
  reinforce =           16,
  renovate =            32,
  tech =                64,
  power_tech =         128,
  radio_tech =         256,
  computer_tech =      512,
}

return skill_flags